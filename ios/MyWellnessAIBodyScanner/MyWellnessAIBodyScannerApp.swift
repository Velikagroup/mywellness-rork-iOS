import SwiftUI
import RevenueCat
import GoogleSignIn

@main
struct MyWellnessAIBodyScannerApp: App {
    @State private var appViewModel = AppViewModel()
    @State private var storeViewModel = StoreViewModel()
    @Environment(\.scenePhase) private var scenePhase

    init() {
        initEnvBridge()
        #if DEBUG
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: Config.EXPO_PUBLIC_REVENUECAT_TEST_API_KEY)
        #else
        Purchases.configure(withAPIKey: Config.EXPO_PUBLIC_REVENUECAT_IOS_API_KEY)
        #endif

        if let userID = UserDefaults.standard.string(forKey: "appleUserID"), !userID.isEmpty {
            Task {
                try? await Purchases.shared.logIn(userID)
            }
        }

        WatchConnectivityService.shared.activate()
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appViewModel)
                .environment(storeViewModel)
                .preferredColorScheme(.light)
                .onTapGesture {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                }
                .onOpenURL { url in
                    GIDSignIn.sharedInstance.handle(url)
                }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                appViewModel.checkDayRollover()
            }
        }
    }
}
