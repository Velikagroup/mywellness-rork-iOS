import Foundation

nonisolated enum WorkoutPlanGenerator {

    static func generateFromScanSafe(
        scanResult: BodyScan2Result,
        profile: UserProfile,
        selectedDays: [String],
        existingPreferences: WorkoutQuizPreferences? = nil
    ) -> WorkoutPlan {
        let plan = generateFromScan(scanResult: scanResult, profile: profile, selectedDays: selectedDays, existingPreferences: existingPreferences)
        guard !plan.days.isEmpty else {
            return DefaultData.workoutPlan(for: profile)
        }
        return plan
    }

    static func generateFromScan(
        scanResult: BodyScan2Result,
        profile: UserProfile,
        selectedDays: [String],
        existingPreferences: WorkoutQuizPreferences? = nil
    ) -> WorkoutPlan {
        let goal = inferGoalFromScan(scanResult: scanResult, profile: profile)
        let strengthLevel = inferStrengthFromScan(scanResult: scanResult)
        let equipment = existingPreferences.map { equipmentSet(for: $0.equipmentCategory, location: $0.trainingLocation) }
            ?? equipmentSet(for: "gym_basic", location: "gym")
        let excludeJoints = existingPreferences.map { mapJointPain($0.jointPain) } ?? []
        let sessionMinutes = Int(existingPreferences?.sessionDuration ?? "45") ?? 45
        let daysPerWeek = selectedDays.count
        let sport = existingPreferences?.selectedSport ?? ""

        let split: [String]
        if !scanResult.trainingSplit.isEmpty && scanResult.trainingSplit != "Full Body" {
            split = scanSplitToDaySplits(scanSplit: scanResult.trainingSplit, focusAreas: scanResult.focusAreas, weakPoints: scanResult.weakPoints, days: daysPerWeek)
        } else {
            split = determineSplit(daysPerWeek: daysPerWeek, goal: goal, sport: sport)
        }

        let weekdays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
        let difficultyLevel = mapDifficulty(strength: strengthLevel, frequency: existingPreferences?.trainingFrequency ?? "1-2_week")

        var days: [WorkoutDay] = []
        var usedExerciseNames: Set<String> = []
        var trainingIdx = 0

        for dayName in weekdays {
            if selectedDays.contains(dayName) {
                let focus = split[trainingIdx % split.count]
                var muscles = musclesForFocus(focus)
                let weakMuscles = mapFocusAreasToMuscles(scanResult.focusAreas + scanResult.weakPoints)
                for wm in weakMuscles where !muscles.contains(wm) && muscles.count < 4 {
                    muscles.append(wm)
                }
                let day = buildTrainingDay(
                    dayName: dayName,
                    focus: focus,
                    muscles: muscles,
                    equipment: equipment,
                    difficulty: difficultyLevel,
                    excludeJoints: excludeJoints,
                    sessionMinutes: sessionMinutes,
                    goal: goal,
                    strengthLevel: strengthLevel,
                    usedNames: &usedExerciseNames
                )
                days.append(day)
                trainingIdx += 1
            } else {
                days.append(WorkoutDay(
                    dayName: dayName,
                    focus: Lang.s("rest_recovery"),
                    durationMinutes: 0,
                    exercises: [],
                    isRestDay: true,
                    caloriesBurned: 0
                ))
            }
        }

        return WorkoutPlan(days: days, createdAt: Date())
    }

    private static func inferGoalFromScan(scanResult: BodyScan2Result, profile: UserProfile) -> String {
        let combined = (scanResult.weakPoints + scanResult.focusAreas + [scanResult.overallAssessment]).joined(separator: " ").lowercased()

        if combined.contains("grasso") || combined.contains("fat") || combined.contains("fett") || combined.contains("graisse") || combined.contains("grasa") || combined.contains("gordura") || combined.contains("dimagr") || combined.contains("peso") || combined.contains("weight") || combined.contains("gewicht") || combined.contains("poids") || combined.contains("slim") || combined.contains("abnehm") || combined.contains("perdre") || combined.contains("perder") {
            return "lose_weight"
        }
        if combined.contains("muscol") || combined.contains("massa") || combined.contains("muscle") || combined.contains("muskel") || combined.contains("músculo") || combined.contains("ipertrofi") || combined.contains("hypertro") || combined.contains("svilupp") || combined.contains("develop") || combined.contains("aufbau") || combined.contains("développ") || combined.contains("desarroll") {
            return "gain_muscle"
        }
        if combined.contains("mobilit") || combined.contains("flexibility") || combined.contains("flexibil") || combined.contains("postur") || combined.contains("haltung") || combined.contains("souplesse") {
            return "mobility"
        }
        if combined.contains("definiz") || combined.contains("definition") || combined.contains("tonic") || combined.contains("tone") || combined.contains("definición") || combined.contains("definição") || combined.contains("définition") || combined.contains("straffung") {
            return "tone"
        }

        let bodyFat = scanResult.estimatedBodyFat.lowercased()
        if let pct = extractPercentage(from: bodyFat) {
            if pct > 25 { return "lose_weight" }
            if pct < 15 { return "gain_muscle" }
        }

        switch profile.goal {
        case .gainMuscle: return "gain_muscle"
        case .loseWeight: return "lose_weight"
        default: return "tone"
        }
    }

    private static func inferStrengthFromScan(scanResult: BodyScan2Result) -> String {
        let definition = scanResult.muscleDefinition.lowercased()
        if definition.contains("alta") || definition.contains("high") || definition.contains("hoch") || definition.contains("élevé") || definition.contains("elevad") || definition.contains("eccellente") || definition.contains("excellent") || definition.contains("excelent") || definition.contains("avanzat") || definition.contains("advanced") {
            return "advanced"
        }
        if definition.contains("buona") || definition.contains("good") || definition.contains("gut") || definition.contains("bonne") || definition.contains("buena") || definition.contains("boa") || definition.contains("intermedi") {
            return "intermediate"
        }
        if definition.contains("moderata") || definition.contains("moderate") || definition.contains("moderada") || definition.contains("modéré") || definition.contains("mäßig") || definition.contains("media") || definition.contains("moyen") {
            return "moderate"
        }
        if definition.contains("bassa") || definition.contains("low") || definition.contains("niedrig") || definition.contains("gering") || definition.contains("faible") || definition.contains("baja") || definition.contains("baixa") || definition.contains("scarsa") || definition.contains("poor") {
            return "light"
        }
        return "moderate"
    }

    private static func extractPercentage(from text: String) -> Double? {
        let cleaned = text.replacingOccurrences(of: "%", with: "").trimmingCharacters(in: .whitespaces)
        if cleaned.contains("-") {
            let parts = cleaned.split(separator: "-")
            if let low = Double(parts.first?.trimmingCharacters(in: .whitespaces) ?? ""),
               let high = Double(parts.last?.trimmingCharacters(in: .whitespaces) ?? "") {
                return (low + high) / 2.0
            }
        }
        return Double(cleaned)
    }

    private static func scanSplitToDaySplits(scanSplit: String, focusAreas: [String], weakPoints: [String], days: Int) -> [String] {
        let lower = scanSplit.lowercased()

        if lower.contains("upper") && lower.contains("lower") || lower.contains("superiore") && lower.contains("inferiore") || lower.contains("ober") && lower.contains("unter") || lower.contains("supérieur") && lower.contains("inférieur") || lower.contains("superior") && lower.contains("inferior") || lower.contains("tren superior") {
            switch days {
            case 1: return ["Full Body"]
            case 2: return ["Upper Body", "Lower Body"]
            case 3: return ["Upper Body", "Lower Body", "Full Body"]
            case 4: return ["Upper Body A", "Lower Body A", "Upper Body B", "Lower Body B"]
            case 5: return ["Upper Body A", "Lower Body A", "Upper Body B", "Lower Body B", "Full Body"]
            default: return ["Upper Body A", "Lower Body A", "Upper Body B", "Lower Body B", "Full Body", "Active Recovery"]
            }
        }

        if lower.contains("push") && lower.contains("pull") || lower.contains("ppl") {
            switch days {
            case 1: return ["Full Body"]
            case 2: return ["Push", "Pull"]
            case 3: return ["Push", "Pull", "Legs"]
            case 4: return ["Push", "Pull", "Legs", "Upper Body"]
            case 5: return ["Push", "Pull", "Legs", "Push B", "Pull B"]
            default: return ["Push A", "Pull A", "Legs A", "Push B", "Pull B", "Legs B"]
            }
        }

        if lower.contains("full body") || lower.contains("corpo completo") || lower.contains("cuerpo completo") || lower.contains("ganzkörper") || lower.contains("corps complet") || lower.contains("corpo inteiro") {
            return Array(repeating: "Full Body", count: min(days, 7))
                .enumerated()
                .map { days > 1 ? "Full Body \(Character(UnicodeScalar(65 + $0.offset)!))" : $0.element }
        }

        return determineSplit(daysPerWeek: days, goal: "", sport: "")
    }

    private static func mapFocusAreasToMuscles(_ areas: [String]) -> [MuscleGroup] {
        var muscles: [MuscleGroup] = []
        for area in areas {
            let lower = area.lowercased()
            if lower.contains("pett") || lower.contains("chest") || lower.contains("pecho") || lower.contains("brust") || lower.contains("poitrine") || lower.contains("peitor") { muscles.append(.chest) }
            if lower.contains("schien") || lower.contains("dorsal") || lower.contains("back") || lower.contains("lat") || lower.contains("espalda") || lower.contains("rücken") || lower.contains("dos") || lower.contains("costas") { muscles.append(.back) }
            if lower.contains("spall") || lower.contains("shoulder") || lower.contains("deltoid") || lower.contains("hombr") || lower.contains("schulter") || lower.contains("épaul") || lower.contains("ombro") { muscles.append(.shoulders) }
            if lower.contains("bicip") || lower.contains("bicep") || lower.contains("bícep") || lower.contains("bizep") { muscles.append(.biceps) }
            if lower.contains("tricip") || lower.contains("tricep") || lower.contains("trícep") || lower.contains("trizep") { muscles.append(.triceps) }
            if lower.contains("quadricip") || lower.contains("quad") || lower.contains("cuádricep") || lower.contains("quadrícep") { muscles.append(.quads) }
            if lower.contains("femorali") || lower.contains("hamstring") || lower.contains("posteriore") || lower.contains("isquiotib") || lower.contains("oberschenkel") || lower.contains("ischio") { muscles.append(.hamstrings) }
            if lower.contains("glute") || lower.contains("glutei") || lower.contains("glúteo") || lower.contains("gesäß") || lower.contains("fessier") { muscles.append(.glutes) }
            if lower.contains("polpacc") || lower.contains("calves") || lower.contains("calf") || lower.contains("pantorrilla") || lower.contains("wade") || lower.contains("mollet") || lower.contains("panturrilha") { muscles.append(.calves) }
            if lower.contains("addome") || lower.contains("core") || lower.contains("abdomin") || lower.contains("abdomen") || lower.contains("bauch") || lower.contains("ventre") { muscles.append(.core) }
            if lower.contains("gamb") || lower.contains("leg") || lower.contains("pierna") || lower.contains("bein") || lower.contains("jambe") || lower.contains("perna") { muscles.append(contentsOf: [.quads, .hamstrings, .glutes]) }
            if lower.contains("bracc") || lower.contains("arm") || lower.contains("brazo") || lower.contains("bras") || lower.contains("braço") { muscles.append(contentsOf: [.biceps, .triceps]) }
        }
        return Array(Set(muscles))
    }

    static func generateSafe(profile: UserProfile, preferences: WorkoutQuizPreferences?) -> WorkoutPlan {
        let plan = generate(profile: profile, preferences: preferences)
        guard !plan.days.isEmpty else {
            return DefaultData.workoutPlan(for: profile)
        }
        return plan
    }

    static func generate(profile: UserProfile, preferences: WorkoutQuizPreferences?) -> WorkoutPlan {
        let prefs = preferences ?? defaultPreferences(for: profile)
        let equipment = equipmentSet(for: prefs.equipmentCategory, location: prefs.trainingLocation)
        let difficultyLevel = mapDifficulty(strength: prefs.strengthLevel, frequency: prefs.trainingFrequency)
        let excludeJoints = mapJointPain(prefs.jointPain)
        let daysPerWeek = max(prefs.daysPerWeek, 1)
        let sessionMinutes = Int(prefs.sessionDuration) ?? 45
        let split = determineSplit(daysPerWeek: daysPerWeek, goal: prefs.fitnessGoal, sport: prefs.selectedSport)
        let weekdays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
        let trainingDays = pickTrainingDays(preferred: prefs.preferredDays, count: daysPerWeek)

        var days: [WorkoutDay] = []
        var usedExerciseNames: Set<String> = []

        for dayName in weekdays {
            if let splitIndex = trainingDays.firstIndex(of: dayName) {
                let focus = split[splitIndex % split.count]
                let muscles = musclesForFocus(focus)
                let day = buildTrainingDay(
                    dayName: dayName,
                    focus: focus,
                    muscles: muscles,
                    equipment: equipment,
                    difficulty: difficultyLevel,
                    excludeJoints: excludeJoints,
                    sessionMinutes: sessionMinutes,
                    goal: prefs.fitnessGoal,
                    strengthLevel: prefs.strengthLevel,
                    usedNames: &usedExerciseNames
                )
                days.append(day)
            } else {
                days.append(WorkoutDay(
                    dayName: dayName,
                    focus: "Rest & Recovery",
                    durationMinutes: 0,
                    exercises: [],
                    isRestDay: true,
                    caloriesBurned: 0
                ))
            }
        }

        return WorkoutPlan(days: days)
    }

    // MARK: - Split Determination

    private static func determineSplit(daysPerWeek: Int, goal: String, sport: String) -> [String] {
        if !sport.isEmpty {
            return sportSpecificSplit(sport: sport, days: daysPerWeek)
        }

        switch daysPerWeek {
        case 1:
            return ["Full Body"]
        case 2:
            return ["Upper Body", "Lower Body"]
        case 3:
            if goal == "gain_muscle" {
                return ["Push (Chest, Shoulders, Triceps)", "Pull (Back, Biceps)", "Legs & Core"]
            }
            return ["Full Body A", "Full Body B", "Full Body C"]
        case 4:
            return ["Upper Body A", "Lower Body A", "Upper Body B", "Lower Body B"]
        case 5:
            return ["Chest & Triceps", "Back & Biceps", "Shoulders & Core", "Quads & Calves", "Hamstrings & Glutes"]
        case 6:
            return ["Push A", "Pull A", "Legs A", "Push B", "Pull B", "Legs B"]
        default:
            return ["Push", "Pull", "Legs", "Upper Body", "Lower Body", "Full Body", "Active Recovery"]
        }
    }

    private static func sportSpecificSplit(sport: String, days: Int) -> [String] {
        let lowerSport = sport.lowercased()
        if lowerSport.contains("bodybuilding") || lowerSport.contains("hypertrophy") {
            switch days {
            case 1...3: return Array(["Chest & Back", "Shoulders & Arms", "Legs & Core"].prefix(days))
            case 4: return ["Chest", "Back & Biceps", "Shoulders & Triceps", "Legs"]
            case 5: return ["Chest", "Back", "Shoulders", "Arms", "Legs"]
            default: return ["Chest", "Back", "Shoulders & Traps", "Arms", "Quads & Calves", "Hamstrings & Glutes"]
            }
        }
        if lowerSport.contains("powerlifting") {
            switch days {
            case 1...3: return Array(["Squat Focus", "Bench Focus", "Deadlift Focus"].prefix(days))
            default: return ["Squat", "Bench", "Deadlift", "Accessories"]
            }
        }
        if lowerSport.contains("calisthenics") {
            switch days {
            case 1...3: return Array(["Push & Core", "Pull & Legs", "Full Body Skills"].prefix(days))
            default: return ["Push", "Pull", "Legs", "Skills & Core"]
            }
        }
        if lowerSport.contains("crossfit") || lowerSport.contains("functional") {
            return Array(repeating: "Full Body Functional", count: min(days, 7))
        }
        if lowerSport.contains("hiit") || lowerSport.contains("tabata") || lowerSport.contains("circuit") {
            return Array(repeating: "HIIT Circuit", count: min(days, 7))
        }
        if lowerSport.contains("yoga") || lowerSport.contains("pilates") || lowerSport.contains("stretching") {
            return Array(repeating: "Flexibility & Core", count: min(days, 7))
        }
        if lowerSport.contains("boxing") || lowerSport.contains("kickboxing") || lowerSport.contains("mma") || lowerSport.contains("combat") {
            switch days {
            case 1...3: return Array(["Upper Body Power", "Core & Conditioning", "Lower Body & Agility"].prefix(days))
            default: return ["Upper Body Power", "Core & Conditioning", "Lower Body", "Full Body Circuit"]
            }
        }
        if lowerSport.contains("cycling") || lowerSport.contains("spinning") || lowerSport.contains("rowing") || lowerSport.contains("endurance") {
            switch days {
            case 1...3: return Array(["Legs & Core", "Upper Body", "Full Body Endurance"].prefix(days))
            default: return ["Legs Power", "Upper Body", "Core & Stability", "Full Body Endurance"]
            }
        }
        if lowerSport.contains("kettlebell") {
            return Array(repeating: "Kettlebell Circuit", count: min(days, 7))
        }
        return determineSplit(daysPerWeek: days, goal: "", sport: "")
    }

    // MARK: - Muscle Mapping

    private static func musclesForFocus(_ focus: String) -> [MuscleGroup] {
        let lower = focus.lowercased()

        if lower.contains("full body") || lower.contains("circuit") || lower.contains("hiit") || lower.contains("functional") || lower.contains("kettlebell") {
            return [.chest, .back, .shoulders, .quads, .glutes, .core]
        }
        if lower.contains("push") {
            return [.chest, .shoulders, .triceps]
        }
        if lower.contains("pull") {
            return [.back, .biceps]
        }
        if lower.contains("legs") || lower.contains("lower body") {
            return [.quads, .hamstrings, .glutes, .calves]
        }
        if lower.contains("upper body") {
            return [.chest, .back, .shoulders, .biceps, .triceps]
        }
        if lower.contains("chest") && lower.contains("triceps") {
            return [.chest, .triceps]
        }
        if lower.contains("chest") && lower.contains("back") {
            return [.chest, .back]
        }
        if lower.contains("chest") {
            return [.chest, .triceps, .shoulders]
        }
        if lower.contains("back") && lower.contains("biceps") {
            return [.back, .biceps]
        }
        if lower.contains("back") {
            return [.back, .biceps]
        }
        if lower.contains("shoulders") && lower.contains("arms") {
            return [.shoulders, .biceps, .triceps]
        }
        if lower.contains("shoulders") && lower.contains("triceps") {
            return [.shoulders, .triceps]
        }
        if lower.contains("shoulders") {
            return [.shoulders, .core]
        }
        if lower.contains("arms") {
            return [.biceps, .triceps]
        }
        if lower.contains("quads") {
            return [.quads, .calves]
        }
        if lower.contains("hamstrings") || lower.contains("glutes") {
            return [.hamstrings, .glutes]
        }
        if lower.contains("squat") {
            return [.quads, .glutes, .core]
        }
        if lower.contains("bench") {
            return [.chest, .triceps, .shoulders]
        }
        if lower.contains("deadlift") {
            return [.back, .hamstrings, .glutes]
        }
        if lower.contains("accessories") {
            return [.biceps, .triceps, .shoulders, .core]
        }
        if lower.contains("core") || lower.contains("flexibility") || lower.contains("skills") || lower.contains("active recovery") {
            return [.core, .shoulders]
        }
        if lower.contains("conditioning") || lower.contains("agility") || lower.contains("power") {
            return [.fullBody, .core]
        }
        if lower.contains("endurance") {
            return [.quads, .core, .glutes]
        }

        return [.chest, .back, .shoulders, .quads, .core]
    }

    // MARK: - Build Training Day

    private static func buildTrainingDay(
        dayName: String,
        focus: String,
        muscles: [MuscleGroup],
        equipment: Set<EquipmentType>,
        difficulty: String,
        excludeJoints: [String],
        sessionMinutes: Int,
        goal: String,
        strengthLevel: String,
        usedNames: inout Set<String>
    ) -> WorkoutDay {
        let availableWarmups = ExerciseDatabase.warmupExercises(equipment: equipment, excludeJoints: excludeJoints)
        let warmupCount = 2
        let warmupTemplates = pickRandom(from: availableWarmups, count: warmupCount, excluding: &usedNames, forceUnique: false)

        let mainCount = mainExerciseCount(sessionMinutes: sessionMinutes, goal: goal)
        var mainTemplates: [ExerciseTemplate] = []
        let compoundFirst = ExerciseDatabase.exercises(for: muscles, equipment: equipment, difficulty: difficulty, category: .main, excludeJoints: excludeJoints)
            .sorted { $0.isCompound && !$1.isCompound }
        let compoundCount = min(mainCount / 2 + 1, compoundFirst.filter { $0.isCompound }.count)
        let compounds = pickRandom(from: compoundFirst.filter { $0.isCompound }, count: compoundCount, excluding: &usedNames, forceUnique: true)
        mainTemplates.append(contentsOf: compounds)

        let isolationPool = compoundFirst.filter { template in !template.isCompound && !mainTemplates.contains(where: { m in m.name == template.name }) }
        let remaining = mainCount - mainTemplates.count
        let isolations = pickRandom(from: isolationPool, count: remaining, excluding: &usedNames, forceUnique: true)
        mainTemplates.append(contentsOf: isolations)

        if mainTemplates.count < mainCount {
            let allPool = ExerciseDatabase.exercises(for: muscles, equipment: equipment, difficulty: difficulty, category: .main, excludeJoints: excludeJoints)
                .filter { template in !mainTemplates.contains(where: { m in m.name == template.name }) }
            let extra = pickRandom(from: allPool, count: mainCount - mainTemplates.count, excluding: &usedNames, forceUnique: false)
            mainTemplates.append(contentsOf: extra)
        }

        let cooldownPool = ExerciseDatabase.cooldownExercises(muscles: muscles)
        let cooldownCount = 2
        let cooldownTemplates = pickRandom(from: cooldownPool, count: cooldownCount, excluding: &usedNames, forceUnique: false)

        let params = exerciseParams(goal: goal, strengthLevel: strengthLevel)

        var exercises: [Exercise] = []

        for t in warmupTemplates {
            exercises.append(templateToExercise(t, params: WarmupParams(), category: .warmup))
        }
        for t in mainTemplates {
            let p = t.isCompound ? params.compound : params.isolation
            exercises.append(templateToExercise(t, params: p, category: .main))
        }
        for t in cooldownTemplates {
            exercises.append(templateToExercise(t, params: CooldownParams(), category: .cooldown))
        }

        let totalDuration = exercises.reduce(0) { total, ex in
            if ex.category == .warmup || ex.category == .cooldown {
                return total + max(ex.durationMinutes, 2)
            }
            let setTime = ex.sets * (30 + ex.restSeconds)
            return total + (setTime / 60)
        }
        let caloriesBurned = estimateCalories(duration: max(totalDuration, sessionMinutes), goal: goal)

        return WorkoutDay(
            dayName: dayName,
            focus: focus,
            durationMinutes: max(totalDuration, sessionMinutes),
            exercises: exercises,
            isRestDay: false,
            caloriesBurned: caloriesBurned
        )
    }

    // MARK: - Exercise Parameters

    private struct ExerciseParams {
        let sets: Int
        let repsRange: String
        let restSeconds: Int
        let rpe: Double
    }

    private struct GoalParams {
        let compound: ExerciseParams
        let isolation: ExerciseParams
    }

    private struct WarmupParams {}
    private struct CooldownParams {}

    private static func exerciseParams(goal: String, strengthLevel: String) -> GoalParams {
        let levelMultiplier: Double
        switch strengthLevel {
        case "never": levelMultiplier = 0.7
        case "light": levelMultiplier = 0.8
        case "moderate": levelMultiplier = 0.9
        case "intermediate": levelMultiplier = 1.0
        case "advanced": levelMultiplier = 1.1
        default: levelMultiplier = 0.9
        }

        switch goal {
        case "gain_muscle":
            return GoalParams(
                compound: ExerciseParams(sets: Int(4 * levelMultiplier), repsRange: "8-12", restSeconds: 90, rpe: 7.5),
                isolation: ExerciseParams(sets: Int(3 * levelMultiplier), repsRange: "10-15", restSeconds: 60, rpe: 7.0)
            )
        case "lose_weight":
            return GoalParams(
                compound: ExerciseParams(sets: max(Int(3 * levelMultiplier), 2), repsRange: "12-15", restSeconds: 45, rpe: 7.0),
                isolation: ExerciseParams(sets: max(Int(3 * levelMultiplier), 2), repsRange: "15-20", restSeconds: 30, rpe: 6.5)
            )
        case "tone":
            return GoalParams(
                compound: ExerciseParams(sets: max(Int(3 * levelMultiplier), 2), repsRange: "10-15", restSeconds: 60, rpe: 7.0),
                isolation: ExerciseParams(sets: max(Int(3 * levelMultiplier), 2), repsRange: "12-15", restSeconds: 45, rpe: 6.5)
            )
        case "mobility":
            return GoalParams(
                compound: ExerciseParams(sets: max(Int(3 * levelMultiplier), 2), repsRange: "8-12", restSeconds: 60, rpe: 6.0),
                isolation: ExerciseParams(sets: max(Int(2 * levelMultiplier), 2), repsRange: "12-15", restSeconds: 45, rpe: 5.5)
            )
        default:
            return GoalParams(
                compound: ExerciseParams(sets: 3, repsRange: "10-12", restSeconds: 60, rpe: 7.0),
                isolation: ExerciseParams(sets: 3, repsRange: "12-15", restSeconds: 45, rpe: 6.5)
            )
        }
    }

    private static func templateToExercise(_ template: ExerciseTemplate, params: ExerciseParams, category: ExerciseCategory) -> Exercise {
        Exercise(
            name: template.name,
            sets: params.sets,
            reps: params.repsRange,
            restSeconds: params.restSeconds,
            muscleGroups: template.primaryMuscles.map { $0.rawValue.capitalized } + template.secondaryMuscles.map { $0.rawValue.capitalized },
            category: category,
            difficulty: template.difficulty,
            exerciseDescription: template.exerciseDescription,
            formTips: template.formTips,
            loadTips: generateLoadTips(template: template, params: params),
            rpe: params.rpe
        )
    }

    private static func templateToExercise(_ template: ExerciseTemplate, params: WarmupParams, category: ExerciseCategory) -> Exercise {
        Exercise(
            name: template.name,
            sets: 1,
            reps: "30-45 sec",
            restSeconds: 0,
            muscleGroups: template.primaryMuscles.map { $0.rawValue.capitalized },
            category: .warmup,
            difficulty: "Beginner",
            exerciseDescription: template.exerciseDescription,
            formTips: template.formTips,
            durationMinutes: 2
        )
    }

    private static func templateToExercise(_ template: ExerciseTemplate, params: CooldownParams, category: ExerciseCategory) -> Exercise {
        Exercise(
            name: template.name,
            sets: 1,
            reps: "30 sec",
            restSeconds: 0,
            muscleGroups: template.primaryMuscles.map { $0.rawValue.capitalized },
            category: .cooldown,
            difficulty: "Beginner",
            exerciseDescription: template.exerciseDescription,
            formTips: template.formTips,
            durationMinutes: 2
        )
    }

    private static func generateLoadTips(template: ExerciseTemplate, params: ExerciseParams) -> [String] {
        var tips: [String] = []
        if template.isCompound {
            tips.append("RPE \(String(format: "%.0f", params.rpe)): you should have \(Int(10 - params.rpe)) reps left in reserve")
        }
        if params.restSeconds >= 90 {
            tips.append("Rest \(params.restSeconds)s between sets for full recovery")
        } else if params.restSeconds >= 60 {
            tips.append("Rest \(params.restSeconds)s between sets for moderate recovery")
        } else {
            tips.append("Short rest \(params.restSeconds)s — keep heart rate elevated")
        }
        if template.isCompound && params.sets >= 4 {
            tips.append("Consider a warm-up set at 50% of working weight")
        }
        return tips
    }

    // MARK: - Helpers

    private static func mainExerciseCount(sessionMinutes: Int, goal: String) -> Int {
        let base: Int
        switch sessionMinutes {
        case ..<25: base = 3
        case 25..<40: base = 4
        case 40..<55: base = 5
        case 55..<75: base = 6
        default: base = 7
        }
        if goal == "lose_weight" { return max(base, 4) }
        return base
    }

    private static func estimateCalories(duration: Int, goal: String) -> Int {
        let perMinute: Double
        switch goal {
        case "lose_weight": perMinute = 8.0
        case "gain_muscle": perMinute = 6.0
        case "tone": perMinute = 7.0
        default: perMinute = 6.5
        }
        return Int(Double(duration) * perMinute)
    }

    private static func pickRandom(from pool: [ExerciseTemplate], count: Int, excluding: inout Set<String>, forceUnique: Bool) -> [ExerciseTemplate] {
        var result: [ExerciseTemplate] = []
        var available = pool
        if forceUnique {
            available = available.filter { !excluding.contains($0.name) }
        }
        available.shuffle()
        for template in available {
            if result.count >= count { break }
            if !result.contains(where: { $0.name == template.name }) {
                result.append(template)
                excluding.insert(template.name)
            }
        }
        if result.count < count {
            var fallback = pool.filter { template in !result.contains(where: { r in r.name == template.name }) }
            fallback.shuffle()
            for template in fallback {
                if result.count >= count { break }
                result.append(template)
            }
        }
        return result
    }

    private static func pickTrainingDays(preferred: [String], count: Int) -> [String] {
        let weekdays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
        if preferred.count == count {
            return preferred
        }
        if preferred.count > count {
            return Array(preferred.prefix(count))
        }
        var result = preferred
        for day in weekdays where result.count < count {
            if !result.contains(day) {
                result.append(day)
            }
        }
        return Array(result.prefix(count))
    }

    private static func equipmentSet(for category: String, location: String) -> Set<EquipmentType> {
        var set: Set<EquipmentType> = [.bodyweight]
        switch category {
        case "bodyweight":
            set.insert(.pullupBar)
        case "home_basic":
            set.formUnion([.dumbbell, .resistanceBand, .pullupBar])
        case "home_complete":
            set.formUnion([.dumbbell, .barbell, .bench, .pullupBar, .kettlebell, .resistanceBand])
        case "gym_basic":
            set.formUnion([.dumbbell, .barbell, .bench, .cable, .pullupBar])
        case "gym_complete":
            set.formUnion([.dumbbell, .barbell, .bench, .cable, .machine, .pullupBar, .kettlebell])
        case "crossfit":
            set.formUnion([.barbell, .kettlebell, .pullupBar, .dumbbell, .bench])
        case "outdoors":
            set.formUnion([.pullupBar, .resistanceBand])
        default:
            set.formUnion([.dumbbell, .barbell, .bench, .cable, .machine, .pullupBar])
        }
        return set
    }

    private static func mapDifficulty(strength: String, frequency: String) -> String {
        switch strength {
        case "never", "light": return "Beginner"
        case "moderate": return frequency == "3+_week" ? "Intermediate" : "Beginner"
        case "intermediate": return "Intermediate"
        case "advanced": return "Advanced"
        default: return "Intermediate"
        }
    }

    private static func mapJointPain(_ pain: [String]) -> [String] {
        if pain.contains("No Pain") { return [] }
        return pain
    }

    private static func defaultPreferences(for profile: UserProfile) -> WorkoutQuizPreferences {
        var prefs = WorkoutQuizPreferences()
        prefs.fitnessGoal = profile.goal.rawValue == "Gain Muscle" ? "gain_muscle" : profile.goal.rawValue == "Lose Weight" ? "lose_weight" : "tone"
        prefs.daysPerWeek = 4
        prefs.preferredDays = ["Monday", "Tuesday", "Thursday", "Friday"]
        prefs.sessionDuration = "45"
        prefs.trainingLocation = "gym"
        prefs.equipmentCategory = "gym_basic"
        prefs.strengthLevel = "moderate"
        prefs.trainingFrequency = "1-2_week"
        prefs.jointPain = ["No Pain"]
        return prefs
    }
}
