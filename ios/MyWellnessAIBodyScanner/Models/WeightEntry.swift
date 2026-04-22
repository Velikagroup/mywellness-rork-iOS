import Foundation

nonisolated struct WeightEntry: Identifiable, Codable, Sendable {
    var id: UUID = UUID()
    var date: Date
    var weightKg: Double
}
