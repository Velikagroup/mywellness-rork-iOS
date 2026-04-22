import Foundation

nonisolated struct ExerciseChatResponse: Sendable {
    let message: String
    let exerciseReady: Bool
    let exercise: Exercise?
}
