import Foundation

nonisolated struct DaySnapshot: Codable, Sendable, Identifiable {
    var date: Date
    var wellnessScore: Double
    var caloriesConsumed: Int
    var caloriesBurned: Int
    var completedMealCount: Int
    var totalMealCount: Int
    var proteinConsumed: Double
    var carbsConsumed: Double
    var fatConsumed: Double
    var photoScannedCalories: Int
    var weightKg: Double?

    var id: String { dateKey }

    var dateKey: String {
        let fmt = DateFormatter()
        fmt.dateFormat = "yyyy-MM-dd"
        return fmt.string(from: date)
    }

    var calorieBalance: Int {
        caloriesConsumed - caloriesBurned
    }
}
