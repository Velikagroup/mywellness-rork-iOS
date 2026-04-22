import Foundation

nonisolated enum FeatureStatus: String, Codable, Sendable, CaseIterable {
    case review = "En revisión"
    case planned = "Planificado"
    case inProgress = "En progreso"
    case completed = "Completado"

    var color: String {
        switch self {
        case .review: return "gray"
        case .planned: return "blue"
        case .inProgress: return "orange"
        case .completed: return "green"
        }
    }

    var icon: String {
        switch self {
        case .review: return "clock"
        case .planned: return "list.bullet"
        case .inProgress: return "hammer"
        case .completed: return "checkmark.circle.fill"
        }
    }
}

nonisolated struct FeatureRequest: Identifiable, Codable, Sendable {
    var id: UUID
    var title: String
    var description: String
    var votes: Int
    var status: FeatureStatus
    var createdAt: Date
    var category: String

    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        votes: Int = 0,
        status: FeatureStatus = .review,
        createdAt: Date = Date(),
        category: String = "General"
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.votes = votes
        self.status = status
        self.createdAt = createdAt
        self.category = category
    }
}
