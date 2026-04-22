import Foundation
import AuthenticationServices
import RevenueCat
import GoogleSignIn
import UIKit

@Observable
@MainActor
class AuthService: NSObject {
    static let shared = AuthService()

    var isSignedIn: Bool = false
    var appleUserID: String?
    var userEmail: String?
    var userFullName: String?
    var errorMessage: String?
    var isGoogleSigningIn: Bool = false
    var isAppleSigningIn: Bool = false

    private let userIDKey = "appleUserID"
    private let emailKey = "appleUserEmail"
    private let fullNameKey = "appleUserFullName"
    private let signedInKey = "isSignedInWithApple"

    private var appleSignInCompletion: ((Bool) -> Void)?

    override init() {
        super.init()
        appleUserID = UserDefaults.standard.string(forKey: userIDKey)
        userEmail = UserDefaults.standard.string(forKey: emailKey)
        userFullName = UserDefaults.standard.string(forKey: fullNameKey)
        isSignedIn = UserDefaults.standard.bool(forKey: signedInKey)
    }

    func performAppleSignIn(completion: @escaping (Bool) -> Void) {
        isAppleSigningIn = true
        appleSignInCompletion = completion

        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }

    func handleAppleSignIn(result: Result<ASAuthorization, any Error>) {
        switch result {
        case .success(let auth):
            processAppleCredential(auth)
        case .failure(let error):
            let nsError = error as NSError
            if nsError.code != ASAuthorizationError.canceled.rawValue {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func processAppleCredential(_ auth: ASAuthorization) {
        guard let credential = auth.credential as? ASAuthorizationAppleIDCredential else { return }
        let userID = credential.user

        appleUserID = userID
        UserDefaults.standard.set(userID, forKey: userIDKey)

        if let email = credential.email {
            userEmail = email
            UserDefaults.standard.set(email, forKey: emailKey)
        }

        if let fullName = credential.fullName {
            let name = [fullName.givenName, fullName.familyName]
                .compactMap { $0 }
                .joined(separator: " ")
            if !name.isEmpty {
                userFullName = name
                UserDefaults.standard.set(name, forKey: fullNameKey)
            }
        }

        isSignedIn = true
        UserDefaults.standard.set(true, forKey: signedInKey)

        Task {
            try? await Purchases.shared.logIn(userID)
        }

        triggerWelcomeAutomations()
    }

    func handleGoogleSignIn() async {
        guard let clientID = Config.EXPO_PUBLIC_GOOGLE_IOS_CLIENT_ID.nilIfEmpty else {
            errorMessage = "Google Sign-In not configured"
            return
        }

        isGoogleSigningIn = true
        defer { isGoogleSigningIn = false }

        let reversedClientID = clientID.components(separatedBy: ".").reversed().joined(separator: ".").lowercased()
        guard Self.isURLSchemeRegistered(reversedClientID) else {
            errorMessage = "Google Sign-In URL scheme missing. Contact support."
            return
        }

        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        guard let presentingVC = Self.topViewController() else {
            errorMessage = "Unable to present Google Sign-In"
            return
        }

        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presentingVC)
            let user = result.user
            let userID = user.userID ?? UUID().uuidString

            appleUserID = userID
            UserDefaults.standard.set(userID, forKey: userIDKey)

            if let email = user.profile?.email {
                userEmail = email
                UserDefaults.standard.set(email, forKey: emailKey)
            }

            if let name = user.profile?.name, !name.isEmpty {
                userFullName = name
                UserDefaults.standard.set(name, forKey: fullNameKey)
            }

            isSignedIn = true
            UserDefaults.standard.set(true, forKey: signedInKey)

            _ = try? await Purchases.shared.logIn(userID)

            triggerWelcomeAutomations()
        } catch {
            let nsError = error as NSError
            if nsError.domain == "com.google.GIDSignIn" && nsError.code == GIDSignInError.canceled.rawValue {
                return
            }
            errorMessage = error.localizedDescription
        }
    }

    private static func isURLSchemeRegistered(_ scheme: String) -> Bool {
        guard let urlTypes = Bundle.main.object(forInfoDictionaryKey: "CFBundleURLTypes") as? [[String: Any]] else {
            return false
        }
        return urlTypes.flatMap { ($0["CFBundleURLSchemes"] as? [String]) ?? [] }
            .contains { $0.lowercased() == scheme }
    }

    private static func topViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) ?? windowScene.windows.first,
              var topVC = window.rootViewController else {
            return nil
        }
        while let presented = topVC.presentedViewController {
            topVC = presented
        }
        return topVC
    }

    private func triggerWelcomeAutomations() {
        guard let email = userEmail, !email.isEmpty else { return }
        EmailAutomationService.shared.sendWelcomeEmail(email: email, name: userFullName)
        EmailAutomationService.shared.scheduleRenewalReminder(email: email, name: userFullName)
    }

    func handleEmailSignIn(email: String, password: String) async {
        let userID = "email_" + email.lowercased().replacingOccurrences(of: "@", with: "_at_").replacingOccurrences(of: ".", with: "_")

        appleUserID = userID
        UserDefaults.standard.set(userID, forKey: userIDKey)

        userEmail = email
        UserDefaults.standard.set(email, forKey: emailKey)

        isSignedIn = true
        UserDefaults.standard.set(true, forKey: signedInKey)

        _ = try? await Purchases.shared.logIn(userID)

        triggerWelcomeAutomations()
    }

    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        appleUserID = nil
        userEmail = nil
        userFullName = nil
        isSignedIn = false
        UserDefaults.standard.removeObject(forKey: userIDKey)
        UserDefaults.standard.removeObject(forKey: emailKey)
        UserDefaults.standard.removeObject(forKey: fullNameKey)
        UserDefaults.standard.set(false, forKey: signedInKey)

        Task {
            try? await Purchases.shared.logOut()
        }
    }
}

extension AuthService: ASAuthorizationControllerDelegate {
    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        Task { @MainActor in
            isAppleSigningIn = false
            processAppleCredential(authorization)
            appleSignInCompletion?(true)
            appleSignInCompletion = nil
        }
    }

    nonisolated func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: any Error) {
        Task { @MainActor in
            isAppleSigningIn = false
            let nsError = error as NSError
            if nsError.code != ASAuthorizationError.canceled.rawValue {
                errorMessage = error.localizedDescription
            }
            appleSignInCompletion?(false)
            appleSignInCompletion = nil
        }
    }
}

extension AuthService: ASAuthorizationControllerPresentationContextProviding {
    nonisolated func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return MainActor.assumeIsolated {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                  let window = windowScene.windows.first(where: { $0.isKeyWindow }) ?? windowScene.windows.first else {
                return ASPresentationAnchor()
            }
            return window
        }
    }
}

extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
