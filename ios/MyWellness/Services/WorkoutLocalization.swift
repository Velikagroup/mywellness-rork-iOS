import Foundation

enum WorkoutLocalization {
    static func localizePlanSafe(_ plan: WorkoutPlan) -> WorkoutPlan {
        let lang = UserDefaults.standard.string(forKey: "appLanguage") ?? "en"
        guard lang != "en" else { return plan }
        var localizedDays: [WorkoutDay] = []
        for day in plan.days {
            let locDay = localizeDaySafe(day, lang: lang)
            localizedDays.append(locDay)
        }
        return WorkoutPlan(days: localizedDays, createdAt: plan.createdAt)
    }

    static func localizePlan(_ plan: WorkoutPlan) -> WorkoutPlan {
        let lang = UserDefaults.standard.string(forKey: "appLanguage") ?? "en"
        guard lang != "en" else { return plan }
        let days = plan.days.map { localizeDay($0, lang: lang) }
        return WorkoutPlan(days: days, createdAt: plan.createdAt)
    }

    private static func localizeDaySafe(_ day: WorkoutDay, lang: String) -> WorkoutDay {
        let dict = translationDict(for: lang)
        let focusText = dict.focusNames[day.focus] ?? day.focus
        var localizedExercises: [Exercise] = []
        for exercise in day.exercises {
            let localizedEx = Exercise(
                id: exercise.id,
                name: dict.exerciseNames[exercise.name] ?? exercise.name,
                sets: exercise.sets,
                reps: translateReps(exercise.reps, to: lang),
                restSeconds: exercise.restSeconds,
                muscleGroups: exercise.muscleGroups.map { translateMuscleGroup($0, dict: dict) },
                notes: exercise.notes,
                isCompleted: exercise.isCompleted,
                category: exercise.category,
                difficulty: dict.difficulties[exercise.difficulty] ?? exercise.difficulty,
                exerciseDescription: dict.descriptions[exercise.name] ?? exercise.exerciseDescription,
                formTips: dict.formTipsByExercise[exercise.name] ?? exercise.formTips,
                loadTips: exercise.loadTips.map { translateLoadTip($0, lang: lang, dict: dict) },
                completedSets: exercise.completedSets,
                durationMinutes: exercise.durationMinutes,
                rpe: exercise.rpe
            )
            localizedExercises.append(localizedEx)
        }
        return WorkoutDay(
            id: day.id,
            dayName: day.dayName,
            focus: focusText,
            durationMinutes: day.durationMinutes,
            exercises: localizedExercises,
            isRestDay: day.isRestDay,
            caloriesBurned: day.caloriesBurned
        )
    }

    private static func localizeDay(_ day: WorkoutDay, lang: String) -> WorkoutDay {
        WorkoutDay(
            id: day.id,
            dayName: day.dayName,
            focus: translateFocus(day.focus, to: lang),
            durationMinutes: day.durationMinutes,
            exercises: day.exercises.map { localizeExercise($0, lang: lang) },
            isRestDay: day.isRestDay,
            caloriesBurned: day.caloriesBurned
        )
    }

    private static func localizeExercise(_ exercise: Exercise, lang: String) -> Exercise {
        let dict = translationDict(for: lang)
        return Exercise(
            id: exercise.id,
            name: dict.exerciseNames[exercise.name] ?? exercise.name,
            sets: exercise.sets,
            reps: translateReps(exercise.reps, to: lang),
            restSeconds: exercise.restSeconds,
            muscleGroups: exercise.muscleGroups.map { translateMuscleGroup($0, dict: dict) },
            notes: exercise.notes,
            isCompleted: exercise.isCompleted,
            category: exercise.category,
            difficulty: dict.difficulties[exercise.difficulty] ?? exercise.difficulty,
            exerciseDescription: dict.descriptions[exercise.name] ?? exercise.exerciseDescription,
            formTips: dict.formTipsByExercise[exercise.name] ?? exercise.formTips,
            loadTips: exercise.loadTips.map { translateLoadTip($0, lang: lang, dict: dict) },
            completedSets: exercise.completedSets,
            durationMinutes: exercise.durationMinutes,
            rpe: exercise.rpe
        )
    }

    private static func translateMuscleGroup(_ muscle: String, dict: WorkoutTranslationData) -> String {
        if let translated = dict.muscleGroups[muscle] { return translated }
        if let translated = dict.muscleGroups[muscle.lowercased()] { return translated }
        let capitalizedLookup = muscle.lowercased()
        for (key, value) in dict.muscleGroups {
            if key.lowercased() == capitalizedLookup { return value }
        }
        return muscle
    }

    private static func translateLoadTip(_ tip: String, lang: String, dict: WorkoutTranslationData) -> String {
        if let exact = dict.loadTipTranslations[tip] { return exact }
        if tip.hasPrefix("RPE ") && tip.contains("you should have") {
            let parts = tip.split(separator: ":")
            if parts.count >= 2 {
                let rpePart = String(parts[0]).trimmingCharacters(in: .whitespaces)
                let rpeVal = rpePart.replacingOccurrences(of: "RPE ", with: "")
                let repsInReserve = Int(10 - (Double(rpeVal) ?? 7))
                return dict.rpeTemplate
                    .replacingOccurrences(of: "{rpe}", with: rpeVal)
                    .replacingOccurrences(of: "{reps}", with: "\(repsInReserve)")
            }
        }
        if tip.contains("between sets for full recovery") {
            let secs = tip.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            return dict.restFullTemplate.replacingOccurrences(of: "{secs}", with: secs)
        }
        if tip.contains("between sets for moderate recovery") {
            let secs = tip.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            return dict.restModerateTemplate.replacingOccurrences(of: "{secs}", with: secs)
        }
        if tip.contains("keep heart rate elevated") {
            let secs = tip.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
            return dict.restShortTemplate.replacingOccurrences(of: "{secs}", with: secs)
        }
        if tip.contains("warm-up set at 50%") {
            return dict.warmupSetTip
        }
        return tip
    }

    private static func translateFocus(_ focus: String, to lang: String) -> String {
        let dict = translationDict(for: lang)
        return dict.focusNames[focus] ?? focus
    }

    private static func translateReps(_ reps: String, to lang: String) -> String {
        let dict = translationDict(for: lang)
        var result = reps
        for (en, loc) in dict.repsUnits {
            result = result.replacingOccurrences(of: en, with: loc)
        }
        return result
    }

    private static func translationDict(for lang: String) -> WorkoutTranslationData {
        switch lang {
        case "it": return WorkoutTranslationsIT.data
        case "es": return WorkoutTranslationsES.data
        case "de": return WorkoutTranslationsDE.data
        case "fr": return WorkoutTranslationsFR.data
        case "pt": return WorkoutTranslationsPT.data
        default: return WorkoutTranslationData()
        }
    }
}

nonisolated struct WorkoutTranslationData: Sendable {
    var exerciseNames: [String: String] = [:]
    var focusNames: [String: String] = [:]
    var muscleGroups: [String: String] = [:]
    var difficulties: [String: String] = [:]
    var descriptions: [String: String] = [:]
    var repsUnits: [String: String] = [:]
    var formTipsByExercise: [String: [String]] = [:]
    var loadTipTranslations: [String: String] = [:]
    var rpeTemplate: String = "RPE {rpe}: you should have {reps} reps left in reserve"
    var restFullTemplate: String = "Rest {secs}s between sets for full recovery"
    var restModerateTemplate: String = "Rest {secs}s between sets for moderate recovery"
    var restShortTemplate: String = "Short rest {secs}s \u{2014} keep heart rate elevated"
    var warmupSetTip: String = "Consider a warm-up set at 50% of working weight"
}
