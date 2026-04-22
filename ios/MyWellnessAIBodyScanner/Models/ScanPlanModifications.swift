import Foundation

nonisolated struct ScanPlanModifications: Codable, Sendable {
    let nutritionSummary: String
    let workoutSummary: String
    let nutritionChanges: [PlanChange]
    let workoutChanges: [PlanChange]
}

nonisolated struct PlanChange: Codable, Sendable, Identifiable {
    var id: String { "\(dayName)-\(changeType)-\(description.prefix(20))" }
    let dayName: String
    let changeType: String
    let description: String
    let reason: String

    init(dayName: String, changeType: String, description: String, reason: String) {
        self.dayName = dayName
        self.changeType = changeType
        self.description = description
        self.reason = reason
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        dayName = (try? c.decode(String.self, forKey: .dayName)) ?? ""
        changeType = (try? c.decode(String.self, forKey: .changeType)) ?? "modify"
        description = (try? c.decode(String.self, forKey: .description)) ?? ""
        reason = (try? c.decode(String.self, forKey: .reason)) ?? ""
    }
}
