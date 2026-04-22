import Foundation

nonisolated enum ExerciseCategory: String, Codable, Sendable {
    case warmup
    case main
    case cooldown
}

nonisolated struct Exercise: Identifiable, Codable, Sendable {
    var id: UUID = UUID()
    var name: String
    var sets: Int
    var reps: String
    var restSeconds: Int
    var muscleGroups: [String]
    var notes: String?
    var isCompleted: Bool = false
    var category: ExerciseCategory = .main
    var difficulty: String = ""
    var exerciseDescription: String = ""
    var formTips: [String] = []
    var loadTips: [String] = []
    var completedSets: Set<Int> = []
    var durationMinutes: Int = 0
    var rpe: Double = 0

    var setDisplay: String { "\(sets) × \(reps)" }

    var rpeDisplay: String {
        guard rpe > 0 else { return "" }
        if rpe == rpe.rounded() {
            return "RPE \(Int(rpe))"
        }
        return "RPE \(String(format: "%.1f", rpe))"
    }

    var allSetsCompleted: Bool {
        guard sets > 0 else { return isCompleted }
        return completedSets.count >= sets
    }

    enum CodingKeys: String, CodingKey {
        case id, name, sets, reps, restSeconds, muscleGroups, notes, isCompleted
        case category, difficulty, exerciseDescription, formTips, loadTips, completedSets, durationMinutes, rpe
    }

    init(
        id: UUID = UUID(),
        name: String,
        sets: Int,
        reps: String,
        restSeconds: Int,
        muscleGroups: [String],
        notes: String? = nil,
        isCompleted: Bool = false,
        category: ExerciseCategory = .main,
        difficulty: String = "",
        exerciseDescription: String = "",
        formTips: [String] = [],
        loadTips: [String] = [],
        completedSets: Set<Int> = [],
        durationMinutes: Int = 0,
        rpe: Double = 0
    ) {
        self.id = id
        self.name = name
        self.sets = sets
        self.reps = reps
        self.restSeconds = restSeconds
        self.muscleGroups = muscleGroups
        self.notes = notes
        self.isCompleted = isCompleted
        self.category = category
        self.difficulty = difficulty
        self.exerciseDescription = exerciseDescription
        self.formTips = formTips
        self.loadTips = loadTips
        self.completedSets = completedSets
        self.durationMinutes = durationMinutes
        self.rpe = rpe
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = (try? c.decode(UUID.self, forKey: .id)) ?? UUID()
        name = (try? c.decode(String.self, forKey: .name)) ?? ""
        sets = (try? c.decode(Int.self, forKey: .sets)) ?? 0
        reps = (try? c.decode(String.self, forKey: .reps)) ?? ""
        restSeconds = (try? c.decode(Int.self, forKey: .restSeconds)) ?? 0
        muscleGroups = (try? c.decode([String].self, forKey: .muscleGroups)) ?? []
        notes = try? c.decode(String.self, forKey: .notes)
        isCompleted = (try? c.decode(Bool.self, forKey: .isCompleted)) ?? false
        category = (try? c.decode(ExerciseCategory.self, forKey: .category)) ?? .main
        difficulty = (try? c.decode(String.self, forKey: .difficulty)) ?? ""
        exerciseDescription = (try? c.decode(String.self, forKey: .exerciseDescription)) ?? ""
        formTips = (try? c.decode([String].self, forKey: .formTips)) ?? []
        loadTips = (try? c.decode([String].self, forKey: .loadTips)) ?? []
        completedSets = (try? c.decode(Set<Int>.self, forKey: .completedSets)) ?? []
        durationMinutes = (try? c.decode(Int.self, forKey: .durationMinutes)) ?? 0
        rpe = (try? c.decode(Double.self, forKey: .rpe)) ?? 0
    }
}

nonisolated struct WorkoutDay: Identifiable, Codable, Sendable {
    var id: UUID = UUID()
    var dayName: String
    var focus: String
    var durationMinutes: Int
    var exercises: [Exercise]
    var isRestDay: Bool = false
    var caloriesBurned: Int

    var warmupExercises: [Exercise] { exercises.filter { $0.category == .warmup } }
    var mainExercises: [Exercise] { exercises.filter { $0.category == .main } }
    var cooldownExercises: [Exercise] { exercises.filter { $0.category == .cooldown } }

    var completedExercises: Int { exercises.filter { $0.allSetsCompleted || $0.isCompleted }.count }
    var totalExercises: Int { exercises.count }
    var completionPercent: Double {
        guard totalExercises > 0 else { return 0 }
        return Double(completedExercises) / Double(totalExercises)
    }

    enum CodingKeys: String, CodingKey {
        case id, dayName, focus, durationMinutes, exercises, isRestDay, caloriesBurned
    }

    init(
        id: UUID = UUID(),
        dayName: String,
        focus: String,
        durationMinutes: Int,
        exercises: [Exercise],
        isRestDay: Bool = false,
        caloriesBurned: Int
    ) {
        self.id = id
        self.dayName = dayName
        self.focus = focus
        self.durationMinutes = durationMinutes
        self.exercises = exercises
        self.isRestDay = isRestDay
        self.caloriesBurned = caloriesBurned
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        id = (try? c.decode(UUID.self, forKey: .id)) ?? UUID()
        dayName = (try? c.decode(String.self, forKey: .dayName)) ?? ""
        focus = (try? c.decode(String.self, forKey: .focus)) ?? ""
        durationMinutes = (try? c.decode(Int.self, forKey: .durationMinutes)) ?? 0
        exercises = (try? c.decode([Exercise].self, forKey: .exercises)) ?? []
        isRestDay = (try? c.decode(Bool.self, forKey: .isRestDay)) ?? false
        caloriesBurned = (try? c.decode(Int.self, forKey: .caloriesBurned)) ?? 0
    }
}

nonisolated struct WorkoutPlan: Codable, Sendable {
    var days: [WorkoutDay] = []
    var createdAt: Date = Date()

    var totalExercises: Int {
        days.reduce(0) { $0 + $1.exercises.count }
    }

    enum CodingKeys: String, CodingKey {
        case days, createdAt
    }

    init(days: [WorkoutDay] = [], createdAt: Date = Date()) {
        self.days = days
        self.createdAt = createdAt
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        days = (try? c.decode([WorkoutDay].self, forKey: .days)) ?? []
        createdAt = (try? c.decode(Date.self, forKey: .createdAt)) ?? Date()
    }
}
