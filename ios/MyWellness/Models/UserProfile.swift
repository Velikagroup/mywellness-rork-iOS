import Foundation

nonisolated struct UserProfile: Codable, Sendable {
    enum Goal: String, Codable, CaseIterable, Sendable {
        case loseWeight = "Lose Weight"
        case maintain = "Maintain Weight"
        case gainMuscle = "Gain Muscle"

        var icon: String {
            switch self {
            case .loseWeight: return "flame.fill"
            case .maintain: return "scale.3d"
            case .gainMuscle: return "dumbbell.fill"
            }
        }
    }

    enum Gender: String, Codable, CaseIterable, Sendable {
        case male = "Male"
        case female = "Female"
        case other = "Other"
    }

    enum ActivityLevel: String, Codable, CaseIterable, Sendable {
        case sedentary = "Sedentary"
        case light = "Lightly Active"
        case moderate = "Moderately Active"
        case active = "Very Active"
        case veryActive = "Extremely Active"

        var multiplier: Double {
            switch self {
            case .sedentary: return 1.2
            case .light: return 1.375
            case .moderate: return 1.55
            case .active: return 1.725
            case .veryActive: return 1.9
            }
        }

        var langKey: String {
            switch self {
            case .sedentary: return "sedentary"
            case .light: return "light"
            case .moderate: return "moderate"
            case .active: return "active"
            case .veryActive: return "very_active"
            }
        }

        var description: String {
            switch self {
            case .sedentary: return "Little or no exercise"
            case .light: return "1–3 days/week"
            case .moderate: return "3–5 days/week"
            case .active: return "6–7 days/week"
            case .veryActive: return "Hard exercise daily"
            }
        }

        var icon: String {
            switch self {
            case .sedentary: return "sofa.fill"
            case .light: return "figure.walk"
            case .moderate: return "figure.run"
            case .active: return "figure.strengthtraining.traditional"
            case .veryActive: return "bolt.fill"
            }
        }
    }

    enum DietType: String, Codable, CaseIterable, Sendable {
        case lowCarb = "Low Carb"
        case softLowCarb = "Soft Low Carb"
        case ketogenic = "Ketogenic"
        case carnivore = "Carnivore"
        case vegetarian = "Vegetarian"
        case vegan = "Vegan"
        case paleo = "Paleo"
        case mediterranean = "Mediterranean"
        case standard = "Balanced"
        case none = "No specific diet"

        var icon: String {
            switch self {
            case .lowCarb: return "🥗"
            case .softLowCarb: return "🌮"
            case .ketogenic: return "🥑"
            case .carnivore: return "🥩"
            case .vegetarian: return "🥦"
            case .vegan: return "🌱"
            case .paleo: return "🥜"
            case .mediterranean: return "🫒"
            case .standard: return "🍽️"
            case .none: return "✨"
            }
        }
    }

    var name: String = ""
    var goal: Goal = .loseWeight
    var gender: Gender = .male
    var age: Int = 24
    var dateOfBirth: Date = Calendar.current.date(from: DateComponents(year: 2001, month: 9, day: 1)) ?? Date()
    var heightCm: Double = 174
    var currentWeightKg: Double = 81
    var targetWeightKg: Double = 75
    var isMetric: Bool = true
    var weightLossSpeedKgPerWeek: Double = 0.65
    var currentBodyTypeIndex: Int = 3
    var targetBodyTypeIndex: Int = 1
    var areasToImprove: [String] = []
    var obstacles: [String] = []
    var achievements: [String] = []
    var dietType: DietType = .standard
    var referralCode: String = ""
    var activityLevel: ActivityLevel = .moderate

    var bmr: Double {
        if let custom = customBMR { return custom }
        switch gender {
        case .male:
            return 10 * currentWeightKg + 6.25 * heightCm - 5 * Double(age) + 5
        case .female:
            return 10 * currentWeightKg + 6.25 * heightCm - 5 * Double(age) - 161
        case .other:
            return 10 * currentWeightKg + 6.25 * heightCm - 5 * Double(age) - 78
        }
    }

    var tdee: Double {
        bmr * activityLevel.multiplier
    }

    var customCalorieTarget: Double?
    var customBMR: Double?

    var neckCircumferenceCm: Double?
    var waistCircumferenceCm: Double?
    var hipCircumferenceCm: Double?

    var bodyFatPercentage: Double? {
        guard let neck = neckCircumferenceCm,
              let waist = waistCircumferenceCm,
              neck > 0, waist > neck else { return nil }
        let h = heightCm
        switch gender {
        case .male:
            let val = 495.0 / (1.0324 - 0.19077 * log10(waist - neck) + 0.15456 * log10(h)) - 450.0
            return max(3, min(60, val))
        case .female, .other:
            guard let hip = hipCircumferenceCm, hip > 0 else { return nil }
            let val = 495.0 / (1.29579 - 0.35004 * log10(waist + hip - neck) + 0.22100 * log10(h)) - 450.0
            return max(8, min(60, val))
        }
    }

    var dailyCalorieTarget: Double {
        if let custom = customCalorieTarget { return custom }
        let deficit = weightLossSpeedKgPerWeek * 7700.0 / 7.0
        let minCalories: Double = gender == .female ? 1300 : 1600
        let maxDeficitPercent = 0.25
        let maxAllowedDeficit = tdee * maxDeficitPercent
        let effectiveDeficit = min(deficit, maxAllowedDeficit)
        switch goal {
        case .loseWeight: return max(minCalories, tdee - effectiveDeficit)
        case .maintain: return tdee
        case .gainMuscle: return tdee + 300
        }
    }

    var proteinTarget: Double { currentWeightKg * 1.8 }
    var carbsTarget: Double { (dailyCalorieTarget * 0.45) / 4 }
    var fatTarget: Double { (dailyCalorieTarget * 0.30) / 9 }

    var bmi: Double {
        let heightM = heightCm / 100
        return currentWeightKg / (heightM * heightM)
    }

    var weightToGoKg: Double {
        currentWeightKg - targetWeightKg
    }

    var estimatedWeeksToGoal: Int {
        guard weightToGoKg != 0 else { return 0 }
        return Int(ceil(abs(weightToGoKg) / weightLossSpeedKgPerWeek))
    }
}
