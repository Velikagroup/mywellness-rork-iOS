import Foundation

nonisolated struct PantryItem: Identifiable, Codable, Sendable {
    var id: UUID = UUID()
    var name: String
    var brand: String?
    var type: String?
    var calories: Int
    var protein: Double
    var carbs: Double
    var fat: Double
    var unit: String = "per 100g"
    var category: String
}
