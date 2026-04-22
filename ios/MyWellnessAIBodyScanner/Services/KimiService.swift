import Foundation

nonisolated struct KimiService: Sendable {
    private static let apiKey = Config.EXPO_PUBLIC_KIMI_API_KEY
    private static let baseURL = "https://api.moonshot.ai/v1/chat/completions"
    private static let model = "moonshot-v1-8k"
    private static let largeModel = "moonshot-v1-32k"
    private static let visionModel = "moonshot-v1-8k-vision-preview"

    static var isConfigured: Bool {
        !apiKey.isEmpty
    }

    static func chatCompletion(prompt: String, timeout: TimeInterval = 120) async throws -> String {
        guard isConfigured else {
            throw AIServiceError.networkError("Kimi API key not configured.")
        }
        guard let url = URL(string: baseURL) else {
            throw AIServiceError.invalidURL
        }

        let body: [String: Any] = [
            "model": model,
            "messages": [
                ["role": "system", "content": "You are a nutrition and fitness expert AI. Always respond with ONLY raw JSON, no markdown, no explanation. Start with { end with }."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.3,
            "max_tokens": 4096
        ]

        return try await sendRequest(url: url, body: body, timeout: timeout)
    }

    static func chatCompletionLarge(prompt: String, maxTokens: Int = 8192, timeout: TimeInterval = 180) async throws -> String {
        guard isConfigured else {
            throw AIServiceError.networkError("Kimi API key not configured.")
        }
        guard let url = URL(string: baseURL) else {
            throw AIServiceError.invalidURL
        }

        let body: [String: Any] = [
            "model": largeModel,
            "messages": [
                ["role": "system", "content": "You are a nutrition and fitness expert AI. Always respond with ONLY raw JSON, no markdown, no explanation. Start with { end with }."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.3,
            "max_tokens": maxTokens
        ]

        return try await sendRequest(url: url, body: body, timeout: timeout)
    }

    static func visionCompletionLarge(prompt: String, imageBase64Strings: [String], maxTokens: Int = 8192, timeout: TimeInterval = 180) async throws -> String {
        guard isConfigured else {
            throw AIServiceError.networkError("Kimi API key not configured.")
        }
        guard let url = URL(string: baseURL) else {
            throw AIServiceError.invalidURL
        }

        var contentArray: [[String: Any]] = [
            ["type": "text", "text": prompt]
        ]
        for base64 in imageBase64Strings {
            contentArray.append([
                "type": "image_url",
                "image_url": ["url": "data:image/jpeg;base64,\(base64)"]
            ])
        }

        let body: [String: Any] = [
            "model": visionModel,
            "messages": [
                ["role": "system", "content": "You are a nutrition and fitness expert AI. Always respond with ONLY raw JSON, no markdown, no explanation. Start with { end with }."],
                ["role": "user", "content": contentArray]
            ],
            "temperature": 0.3,
            "max_tokens": maxTokens
        ]

        return try await sendRequest(url: url, body: body, timeout: timeout)
    }

    static func multiTurnChat(messages: [[String: Any]], systemPrompt: String, timeout: TimeInterval = 60) async throws -> String {
        guard isConfigured else {
            throw AIServiceError.networkError("Kimi API key not configured.")
        }
        guard let url = URL(string: baseURL) else {
            throw AIServiceError.invalidURL
        }

        var allMessages: [[String: Any]] = [
            ["role": "system", "content": systemPrompt]
        ]
        allMessages.append(contentsOf: messages)

        let body: [String: Any] = [
            "model": model,
            "messages": allMessages,
            "temperature": 0.5,
            "max_tokens": 2048
        ]

        return try await sendRequest(url: url, body: body, timeout: timeout)
    }

    static func visionCompletion(prompt: String, imageBase64Strings: [String], timeout: TimeInterval = 120) async throws -> String {
        guard isConfigured else {
            throw AIServiceError.networkError("Kimi API key not configured.")
        }
        guard let url = URL(string: baseURL) else {
            throw AIServiceError.invalidURL
        }

        var contentArray: [[String: Any]] = [
            ["type": "text", "text": prompt]
        ]
        for base64 in imageBase64Strings {
            contentArray.append([
                "type": "image_url",
                "image_url": ["url": "data:image/jpeg;base64,\(base64)"]
            ])
        }

        let body: [String: Any] = [
            "model": visionModel,
            "messages": [
                ["role": "system", "content": "You are a nutrition and fitness expert AI. Always respond with ONLY raw JSON, no markdown, no explanation. Start with { end with }."],
                ["role": "user", "content": contentArray]
            ],
            "temperature": 0.3,
            "max_tokens": 4096
        ]

        return try await sendRequest(url: url, body: body, timeout: timeout)
    }

    private static func sendRequest(url: URL, body: [String: Any], timeout: TimeInterval) async throws -> String {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeout
        config.timeoutIntervalForResource = timeout + 30
        let session = URLSession(configuration: config)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = timeout

        guard let httpBody = try? JSONSerialization.data(withJSONObject: body) else {
            throw AIServiceError.networkError("Error preparing the request.")
        }
        request.httpBody = httpBody

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch let urlError as URLError {
            if urlError.code == .timedOut {
                throw AIServiceError.networkError("Server timeout. Please try again.")
            }
            if urlError.code == .networkConnectionLost || urlError.code == .notConnectedToInternet {
                throw AIServiceError.networkError("Connection lost. Check your internet connection.")
            }
            throw AIServiceError.networkError("Connection failed (\(urlError.code.rawValue)). Try again.")
        } catch {
            throw AIServiceError.networkError("Network error: \(error.localizedDescription)")
        }

        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            let code = httpResponse.statusCode
            let responseBody = String(data: data, encoding: .utf8) ?? ""
            if code == 401 {
                throw AIServiceError.networkError("Invalid Kimi API key. Please check your configuration.")
            }
            if code == 413 {
                throw AIServiceError.networkError("Photos too large (413). Try again.")
            }
            if code == 429 {
                throw AIServiceError.networkError("Rate limit exceeded. Please wait a moment and try again.")
            }
            if code >= 500 {
                throw AIServiceError.networkError("Kimi server unavailable (\(code)). Try again later.")
            }
            throw AIServiceError.networkError("Kimi API error (\(code)): \(responseBody.prefix(200))")
        }

        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            let raw = String(data: data, encoding: .utf8) ?? ""
            if !raw.isEmpty {
                return raw
            }
            throw AIServiceError.noContent
        }

        return content
    }
}
