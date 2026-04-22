import Foundation

nonisolated struct ResendSendRequest: Codable, Sendable {
    let from: String
    let to: [String]
    let subject: String?
    let html: String?
    let template: ResendTemplate?

    init(from: String, to: [String], subject: String? = nil, html: String? = nil, template: ResendTemplate? = nil) {
        self.from = from
        self.to = to
        self.subject = subject
        self.html = html
        self.template = template
    }
}

nonisolated struct ResendTemplate: Codable, Sendable {
    let id: String
    let variables: [String: String]?

    init(id: String, variables: [String: String]? = nil) {
        self.id = id
        self.variables = variables
    }
}

nonisolated struct ResendResponse: Codable, Sendable {
    let id: String?
}

@MainActor
class ResendService {
    static let shared = ResendService()

    private let baseURL = "https://api.resend.com"
    private let fromEmail = "MyWellnessAIBodyScanner <noreply@notifications.projectmywellness.com>"

    private var apiKey: String {
        Config.EXPO_PUBLIC_RESEND_API_KEY
    }

    func sendWithTemplate(to email: String, templateId: String, variables: [String: String]? = nil) async {
        let request = ResendSendRequest(
            from: fromEmail,
            to: [email],
            template: ResendTemplate(id: templateId, variables: variables)
        )
        await send(request)
    }

    func sendHTML(to email: String, subject: String, html: String) async {
        let request = ResendSendRequest(
            from: fromEmail,
            to: [email],
            subject: subject,
            html: html
        )
        await send(request)
    }

    private func send(_ payload: ResendSendRequest) async {
        guard !apiKey.isEmpty else { return }

        guard let url = URL(string: "\(baseURL)/emails") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        guard let body = try? JSONEncoder().encode(payload) else { return }
        request.httpBody = body

        _ = try? await URLSession.shared.data(for: request)
    }
}
