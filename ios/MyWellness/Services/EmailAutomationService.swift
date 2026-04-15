import Foundation

@MainActor
class EmailAutomationService {
    static let shared = EmailAutomationService()

    private let welcomeSentKey = "emailAutomation_welcomeSent"
    private let renewalScheduledKey = "emailAutomation_renewalScheduled"
    private let cartAbandonSentKey = "emailAutomation_cartAbandonSent"
    private let firstAccessDateKey = "emailAutomation_firstAccessDate"

    private let planRenewalTemplateId = "733fa33f-c065-4fd0-801d-9a56e4b8af99"

    private let welcomeTemplateIds: [String: String] = [
        "it": "529aef28-1384-456c-943b-a0ab841918e6",
        "en": "22974573-57d0-4d9f-98ca-6391b2b2e09b",
        "es": "1cbfcac8-56e8-49c8-a4de-d9e6328572a4",
        "fr": "e1458e62-9831-4636-913e-2525e60b1319",
        "de": "e8dcac29-e27d-47f1-9e84-2d88033c0878",
        "pt": "4de4adb4-1861-43c4-9ebe-df0eefb41663"
    ]

    private let caTemplateIds: [String: String] = [
        "it": "aca1f873-3063-48db-bec8-3ab3c5a79b4b",
        "en": "c04f6d33-a8c8-4e46-86b8-f32c36ee0e53",
        "es": "95beec35-9339-4887-8136-c8276c3c277d",
        "fr": "e78548fe-189d-4d59-a0ae-03d8b7449dac",
        "de": "3c352309-b5e4-440f-95a6-e229f4ff5b23",
        "pt": "785881ea-f854-47a5-89e7-06a20ae15f09"
    ]

    // MARK: - 1. Welcome Email

    func sendWelcomeEmail(email: String, name: String?) {
        guard !UserDefaults.standard.bool(forKey: welcomeSentKey) else { return }
        guard !email.isEmpty else { return }

        UserDefaults.standard.set(true, forKey: welcomeSentKey)
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: firstAccessDateKey)

        let lang = Lang.current
        let templateId = welcomeTemplateIds[lang] ?? welcomeTemplateIds["en"]!

        let variables: [String: String]
        if let name, !name.isEmpty {
            variables = ["name": name]
        } else {
            variables = [:]
        }

        Task {
            await ResendService.shared.sendWithTemplate(
                to: email,
                templateId: templateId,
                variables: variables.isEmpty ? nil : variables
            )
        }
    }

    // MARK: - 2. Plan Renewal Reminder (48h after first access)

    func scheduleRenewalReminder(email: String, name: String?) {
        guard !UserDefaults.standard.bool(forKey: renewalScheduledKey) else { return }
        guard !email.isEmpty else { return }

        UserDefaults.standard.set(true, forKey: renewalScheduledKey)

        let variables: [String: String]
        if let name, !name.isEmpty {
            variables = ["name": name]
        } else {
            variables = [:]
        }

        Task {
            do {
                try await Task.sleep(for: .seconds(48 * 60 * 60))
            } catch {
                return
            }
            guard !Task.isCancelled else { return }
            await ResendService.shared.sendWithTemplate(
                to: email,
                templateId: planRenewalTemplateId,
                variables: variables.isEmpty ? nil : variables
            )
        }
    }

    private var cartAbandonmentTask: Task<Void, Never>?

    // MARK: - 3. Cart Abandonment (1h after paywall reached, if no action taken)

    func scheduleCartAbandonmentEmail(email: String, name: String?) {
        guard !UserDefaults.standard.bool(forKey: cartAbandonSentKey) else { return }
        guard !email.isEmpty else { return }
        guard cartAbandonmentTask == nil else { return }

        let lang = Lang.current
        let templateId = caTemplateIds[lang] ?? caTemplateIds["en"]!

        let variables: [String: String]
        if let name, !name.isEmpty {
            variables = ["name": name]
        } else {
            variables = [:]
        }

        cartAbandonmentTask = Task {
            do {
                try await Task.sleep(for: .seconds(1 * 60 * 60))
            } catch {
                return
            }
            guard !Task.isCancelled else { return }
            UserDefaults.standard.set(true, forKey: cartAbandonSentKey)
            await ResendService.shared.sendWithTemplate(
                to: email,
                templateId: templateId,
                variables: variables.isEmpty ? nil : variables
            )
        }
    }

    func cancelCartAbandonment() {
        cartAbandonmentTask?.cancel()
        cartAbandonmentTask = nil
    }

    // MARK: - Reset (for testing / account deletion)

    func resetAll() {
        UserDefaults.standard.removeObject(forKey: welcomeSentKey)
        UserDefaults.standard.removeObject(forKey: renewalScheduledKey)
        UserDefaults.standard.removeObject(forKey: cartAbandonSentKey)
        UserDefaults.standard.removeObject(forKey: firstAccessDateKey)
    }


}
