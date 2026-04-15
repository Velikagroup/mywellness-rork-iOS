import Foundation
import UIKit

nonisolated struct MealImageResponse: Codable, Sendable {
    let image: MealImageData
    let size: String

    nonisolated struct MealImageData: Codable, Sendable {
        let base64Data: String
        let mimeType: String
    }
}

@MainActor
final class MealImageService {
    static let shared = MealImageService()
    private let imageGenerationURL = "https://toolkit.rork.com/images/generate/"
    private let maxConcurrent = 3
    private let mappingKey = "MealImageMapping_v3"

    private var imageMapping: [String: String] = [:]
    private let cacheDirectory: URL = {
        let dir = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("MealImages", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return dir
    }()

    init() {
        loadMapping()
    }

    private func loadMapping() {
        if let data = UserDefaults.standard.data(forKey: mappingKey),
           let decoded = try? JSONDecoder().decode([String: String].self, from: data) {
            imageMapping = decoded
        }
    }

    private func saveMapping() {
        if let data = try? JSONEncoder().encode(imageMapping) {
            UserDefaults.standard.set(data, forKey: mappingKey)
        }
    }

    private static func stableKey(_ name: String) -> String {
        name.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func stableFileName(_ key: String) -> String {
        var hash: UInt64 = 5381
        for byte in key.utf8 {
            hash = hash &* 33 &+ UInt64(byte)
        }
        return "\(hash).jpg"
    }

    private static func isPlaceholderURL(_ url: String?) -> Bool {
        guard let url else { return true }
        return url.isEmpty || url.contains("unsplash.com")
    }

    func cachedImageURL(forMealName name: String) -> String? {
        let key = Self.stableKey(name)
        if let cached = imageMapping[key], !Self.isPlaceholderURL(cached) {
            if FileManager.default.fileExists(atPath: URL(string: cached)?.path ?? "") {
                return cached
            }
            let filePath = cacheDirectory.appendingPathComponent(Self.stableFileName(key))
            if FileManager.default.fileExists(atPath: filePath.path) {
                let url = filePath.absoluteString
                imageMapping[key] = url
                saveMapping()
                return url
            }
        }

        let filePath = cacheDirectory.appendingPathComponent(Self.stableFileName(key))
        if FileManager.default.fileExists(atPath: filePath.path) {
            let url = filePath.absoluteString
            imageMapping[key] = url
            saveMapping()
            return url
        }
        return nil
    }

    func assignCachedImages(to plan: NutritionPlan) -> NutritionPlan {
        var updated = plan
        for di in updated.days.indices {
            for mi in updated.days[di].meals.indices {
                if let cached = cachedImageURL(forMealName: updated.days[di].meals[mi].name) {
                    updated.days[di].meals[mi].imageURL = cached
                }
            }
        }
        return updated
    }

    func generateImagesForPlan(_ plan: NutritionPlan, onUpdate: @escaping (NutritionPlan) -> Void) {
        Task {
            var updatedPlan = assignCachedImages(to: plan)

            var uncached: [(dayIndex: Int, mealIndex: Int, meal: Meal)] = []
            for (di, day) in updatedPlan.days.enumerated() {
                for (mi, meal) in day.meals.enumerated() {
                    if Self.isPlaceholderURL(meal.imageURL) {
                        uncached.append((di, mi, meal))
                    }
                }
            }

            if uncached.isEmpty {
                onUpdate(updatedPlan)
                return
            }

            onUpdate(updatedPlan)

            for batch in stride(from: 0, to: uncached.count, by: maxConcurrent) {
                let end = min(batch + maxConcurrent, uncached.count)
                let slice = uncached[batch..<end]

                await withTaskGroup(of: (Int, Int, String?).self) { group in
                    for item in slice {
                        group.addTask {
                            let url = await self.generateImageForMeal(item.meal)
                            return (item.dayIndex, item.mealIndex, url)
                        }
                    }

                    for await (di, mi, url) in group {
                        if let url {
                            updatedPlan.days[di].meals[mi].imageURL = url
                        }
                    }
                }

                onUpdate(updatedPlan)
            }
        }
    }

    func generateImageForSingleMeal(_ meal: Meal) async -> String? {
        if let cached = cachedImageURL(forMealName: meal.name) {
            return cached
        }
        return await generateImageForMeal(meal)
    }

    private func generateImageForMeal(_ meal: Meal) async -> String? {
        let key = Self.stableKey(meal.name)

        if let cached = imageMapping[key], !Self.isPlaceholderURL(cached) {
            if FileManager.default.fileExists(atPath: URL(string: cached)?.path ?? "") {
                return cached
            }
        }

        let filePath = cacheDirectory.appendingPathComponent(Self.stableFileName(key))
        if FileManager.default.fileExists(atPath: filePath.path) {
            let url = filePath.absoluteString
            imageMapping[key] = url
            saveMapping()
            return url
        }

        let prompt = buildPrompt(for: meal)

        guard let url = URL(string: imageGenerationURL) else { return nil }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 90

        let body: [String: Any] = ["prompt": prompt, "size": "1024x1024"]
        guard let httpBody = try? JSONSerialization.data(withJSONObject: body) else { return nil }
        request.httpBody = httpBody

        for attempt in 1...2 {
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    if attempt < 2 {
                        try? await Task.sleep(for: .seconds(3))
                        continue
                    }
                    return nil
                }

                let decoded = try JSONDecoder().decode(MealImageResponse.self, from: data)
                guard let imageData = Data(base64Encoded: decoded.image.base64Data) else { return nil }

                try imageData.write(to: filePath)
                let urlString = filePath.absoluteString
                imageMapping[key] = urlString
                saveMapping()
                return urlString
            } catch {
                if attempt < 2 {
                    try? await Task.sleep(for: .seconds(3))
                    continue
                }
                return nil
            }
        }
        return nil
    }

    private func buildPrompt(for meal: Meal) -> String {
        let ingredientList = meal.ingredients.prefix(6).map(\.name).joined(separator: ", ")

        let mealContext: String
        switch meal.type {
        case .breakfast:
            mealContext = "breakfast dish, morning light, warm tones"
        case .lunch:
            mealContext = "lunch plate, bright daylight, fresh and vibrant"
        case .dinner:
            mealContext = "dinner plate, warm ambient evening lighting, elegant"
        case .snack:
            mealContext = "snack portion, small plate or bowl, casual presentation"
        }

        let dishStyle: String
        let nameLower = meal.name.lowercased()
        if nameLower.contains("smoothie") || nameLower.contains("frullato") {
            dishStyle = "served in a tall glass with garnish"
        } else if nameLower.contains("bowl") {
            dishStyle = "served in a deep ceramic bowl, arranged in sections"
        } else if nameLower.contains("zuppa") || nameLower.contains("minestrone") {
            dishStyle = "served in a deep soup bowl with a spoon"
        } else if nameLower.contains("insalata") {
            dishStyle = "arranged on a wide flat plate with visible fresh ingredients"
        } else if nameLower.contains("toast") || nameLower.contains("pane") || nameLower.contains("panino") || nameLower.contains("piadina") {
            dishStyle = "on a wooden cutting board"
        } else if nameLower.contains("pasta") || nameLower.contains("spaghetti") || nameLower.contains("risotto") || nameLower.contains("lasagna") {
            dishStyle = "twirled on a deep Italian ceramic plate"
        } else if nameLower.contains("bistecca") || nameLower.contains("tagliata") || nameLower.contains("costata") || nameLower.contains("costolette") {
            dishStyle = "sliced on a dark slate board showing the inside"
        } else if nameLower.contains("tisana") || nameLower.contains("latte dorato") {
            dishStyle = "served in a ceramic mug with steam rising"
        } else if nameLower.contains("pancake") || nameLower.contains("crêpes") || nameLower.contains("crepes") {
            dishStyle = "stacked on a plate with toppings drizzled"
        } else if nameLower.contains("uov") || nameLower.contains("frittata") || nameLower.contains("omelette") {
            dishStyle = "served in a cast iron skillet or on a warm plate"
        } else {
            dishStyle = "beautifully plated on a clean white ceramic dish"
        }

        return "Hyperrealistic top-down food photography: \(meal.name). Main ingredients visible: \(ingredientList). \(mealContext). \(dishStyle). Professional studio lighting, shallow depth of field, 4K quality, Italian cuisine style, appetizing and photorealistic. No text, no watermarks, no hands, no utensils in frame."
    }

    func clearCache() {
        imageMapping.removeAll()
        saveMapping()
        try? FileManager.default.removeItem(at: cacheDirectory)
        try? FileManager.default.createDirectory(at: cacheDirectory, withIntermediateDirectories: true)
    }
}
