import Foundation

nonisolated struct MealPlanQuizPreferences: Codable, Sendable {
    var dietType: String = ""
    var intolerances: [String] = []
    var customIntolerances: String = ""
    var wantsFasting: Bool = false
    var fastingWindow: FastingWindow = .skipBreakfast
    var mealsCount: Int = 3
    var cookingTime: CookingTime = .moderate
    var cheatMeal: CheatMealSelection? = nil

    nonisolated enum FastingWindow: String, Codable, Sendable {
        case skipBreakfast = "skip_breakfast"
        case skipDinner = "skip_dinner"

        var windowLabel: String {
            switch self {
            case .skipBreakfast: return "12:00 - 20:00"
            case .skipDinner: return "08:00 - 16:00"
            }
        }

        var description: String {
            switch self {
            case .skipBreakfast: return "I eat from noon to 8:00 PM"
            case .skipDinner: return "I eat from 8:00 AM to 4:00 PM"
            }
        }
    }

    nonisolated enum CookingTime: String, Codable, CaseIterable, Sendable {
        case quick = "quick"
        case moderate = "moderate"
        case relaxed = "relaxed"

        var title: String {
            switch self {
            case .quick: return Lang.s("cooking_quick")
            case .moderate: return Lang.s("cooking_moderate")
            case .relaxed: return Lang.s("cooking_relaxed")
            }
        }

        var subtitle: String {
            switch self {
            case .quick: return Lang.s("cooking_quick_time")
            case .moderate: return Lang.s("cooking_moderate_time")
            case .relaxed: return Lang.s("cooking_relaxed_time")
            }
        }

        var emoji: String {
            switch self {
            case .quick: return "⚡"
            case .moderate: return "☕"
            case .relaxed: return "👨‍🍳"
            }
        }
    }

    nonisolated struct CheatMealSelection: Codable, Sendable, Equatable {
        var day: String
        var mealType: String
    }
}
