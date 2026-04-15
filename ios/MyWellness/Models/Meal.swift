import Foundation

nonisolated struct Ingredient: Identifiable, Codable, Sendable {
    var id: UUID = UUID()
    var name: String
    var amount: Double
    var unit: String
    var calories: Int
}

nonisolated struct Meal: Identifiable, Codable, Sendable {
    var id: UUID = UUID()
    var type: MealType
    var name: String
    var calories: Int
    var protein: Double
    var carbs: Double
    var fat: Double
    var prepTime: Int
    var difficulty: Difficulty
    var ingredients: [Ingredient]
    var imageURL: String?
    var isCompleted: Bool = false
    var isCheatMeal: Bool = false
    var preparationSteps: [String]?

    enum MealType: String, Codable, CaseIterable, Sendable {
        case breakfast = "Breakfast"
        case lunch = "Lunch"
        case dinner = "Dinner"
        case snack = "Snack"

        var localizedName: String {
            switch self {
            case .breakfast: return "Desayuno"
            case .lunch: return "Almuerzo"
            case .dinner: return "Cena"
            case .snack: return "Snack"
            }
        }

        var icon: String {
            switch self {
            case .breakfast: return "sunrise.fill"
            case .lunch: return "sun.max.fill"
            case .dinner: return "moon.fill"
            case .snack: return "apple.logo"
            }
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let raw = try container.decode(String.self)
            let lowered = raw.lowercased().trimmingCharacters(in: .whitespaces)
            if lowered.contains("breakfast") || lowered.contains("colazione") {
                self = .breakfast
            } else if lowered.contains("lunch") || lowered.contains("pranzo") {
                self = .lunch
            } else if lowered.contains("dinner") || lowered.contains("cena") {
                self = .dinner
            } else {
                self = .snack
            }
        }
    }

    enum Difficulty: String, Codable, Sendable {
        case easy = "Easy"
        case medium = "Medium"
        case hard = "Hard"

        var localizedName: String {
            switch self {
            case .easy: return Lang.s("difficulty_easy")
            case .medium: return Lang.s("difficulty_medium")
            case .hard: return Lang.s("difficulty_hard")
            }
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let raw = (try? container.decode(String.self))?.lowercased() ?? "easy"
            if raw.contains("hard") || raw.contains("difficult") {
                self = .hard
            } else if raw.contains("med") {
                self = .medium
            } else {
                self = .easy
            }
        }
    }
}

nonisolated struct DayPlan: Identifiable, Codable, Sendable {
    var id: UUID = UUID()
    var dayName: String
    var meals: [Meal]

    var totalCalories: Int { meals.reduce(0) { $0 + $1.calories } }
    var totalProtein: Double { meals.reduce(0.0) { $0 + $1.protein } }
    var totalCarbs: Double { meals.reduce(0.0) { $0 + $1.carbs } }
    var totalFat: Double { meals.reduce(0.0) { $0 + $1.fat } }
}

nonisolated struct NutritionPlan: Codable, Sendable {
    var days: [DayPlan] = []
    var createdAt: Date = Date()
}
