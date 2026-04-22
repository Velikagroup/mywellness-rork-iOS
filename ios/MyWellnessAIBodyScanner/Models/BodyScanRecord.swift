import Foundation

nonisolated struct BodyScanRecord: Codable, Sendable, Identifiable {
    let id: UUID
    let date: Date
    let somatotype: String
    let estimatedBodyFat: String
    let biologicalAge: String
    let muscleDefinition: String
    let bloatingPercentage: String
    let skinTexture: String
    let strongPoints: [String]
    let weakPoints: [String]
    let overallAssessment: String
    let posturalNotes: String
    let dailyCalories: Int
    let proteinGrams: Int
    let carbsGrams: Int
    let fatGrams: Int

    init(from result: BodyScan2Result) {
        self.id = UUID()
        self.date = Date()
        self.somatotype = result.somatotype
        self.estimatedBodyFat = result.estimatedBodyFat
        self.biologicalAge = result.biologicalAge
        self.muscleDefinition = result.muscleDefinition
        self.bloatingPercentage = result.bloatingPercentage
        self.skinTexture = result.skinTexture
        self.strongPoints = result.strongPoints
        self.weakPoints = result.weakPoints
        self.overallAssessment = result.overallAssessment
        self.posturalNotes = result.posturalNotes
        self.dailyCalories = result.dailyCalories
        self.proteinGrams = result.proteinGrams
        self.carbsGrams = result.carbsGrams
        self.fatGrams = result.fatGrams
    }

    var bodyFatNumeric: Double? {
        let cleaned = estimatedBodyFat
            .replacingOccurrences(of: "%", with: "")
            .trimmingCharacters(in: .whitespaces)
        if cleaned.contains("-") {
            let parts = cleaned.split(separator: "-")
            if parts.count == 2,
               let low = Double(parts[0].trimmingCharacters(in: .whitespaces)),
               let high = Double(parts[1].trimmingCharacters(in: .whitespaces)) {
                return (low + high) / 2.0
            }
        }
        return Double(cleaned)
    }

    var biologicalAgeNumeric: Double? {
        let cleaned = biologicalAge
            .replacingOccurrences(of: " anni", with: "")
            .replacingOccurrences(of: " años", with: "")
            .replacingOccurrences(of: " years old", with: "")
            .replacingOccurrences(of: " years", with: "")
            .replacingOccurrences(of: " yrs", with: "")
            .replacingOccurrences(of: " Jahre alt", with: "")
            .replacingOccurrences(of: " Jahre", with: "")
            .replacingOccurrences(of: " ans", with: "")
            .replacingOccurrences(of: " anos", with: "")
            .trimmingCharacters(in: .whitespaces)
        return Double(cleaned)
    }
}
