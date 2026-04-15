import Foundation

nonisolated struct FoodScanRecord: Identifiable, Codable, Sendable {
    var id: UUID = UUID()
    var date: Date = Date()
    var foodName: String
    var totalCalories: Int
    var totalProtein: Double
    var totalCarbs: Double
    var totalFat: Double
    var servingSize: String
    var confidence: String
    var notes: String
    var ingredients: [ScannedIngredient]
    var imageData: Data?

    var formattedDate: String {
        let f = DateFormatter()
        f.dateFormat = "dd MMM yyyy, HH:mm"
        return f.string(from: date)
    }
}

nonisolated struct FoodProductScanRecord: Identifiable, Codable, Sendable {
    var id: UUID = UUID()
    var date: Date = Date()
    var productName: String
    var servingSize: String
    var calories: Int
    var totalFat: Double
    var saturatedFat: Double
    var carbohydrates: Double
    var sugars: Double
    var protein: Double
    var salt: Double
    var fiber: Double
    var imageData: Data?
    var qualityScore: Int

    var formattedDate: String {
        let f = DateFormatter()
        f.dateFormat = "dd MMM yyyy, HH:mm"
        return f.string(from: date)
    }

    var qualityLabel: String {
        switch qualityScore {
        case 80...100: return "Excellent"
        case 60..<80: return "Good"
        case 40..<60: return "Average"
        case 20..<40: return "Poor"
        default: return "Very Poor"
        }
    }

    var qualityColor: String {
        switch qualityScore {
        case 80...100: return "green"
        case 60..<80: return "blue"
        case 40..<60: return "orange"
        default: return "red"
        }
    }

    static func computeQuality(from result: NutritionTableResult) -> Int {
        var score = 50
        if result.protein >= 10 { score += 15 } else if result.protein >= 5 { score += 8 }
        if result.fiber >= 5 { score += 10 } else if result.fiber >= 2 { score += 5 }
        if result.sugars <= 5 { score += 10 } else if result.sugars <= 15 { score += 3 } else { score -= 10 }
        if result.saturatedFat <= 2 { score += 10 } else if result.saturatedFat <= 5 { score += 3 } else { score -= 10 }
        if result.salt <= 0.5 { score += 5 } else if result.salt > 1.5 { score -= 5 }
        if result.calories <= 150 { score += 5 } else if result.calories > 400 { score -= 5 }
        return max(0, min(100, score))
    }
}
