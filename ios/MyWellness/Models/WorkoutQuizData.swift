import Foundation

nonisolated struct WorkoutQuizPreferences: Codable, Sendable {
    var fitnessGoal: String = ""
    var isPerformance: Bool? = nil
    var selectedSport: String = ""
    var sportAnswers: [String: String] = [:]
    var trainingFrequency: String = ""
    var strengthLevel: String = ""
    var daysPerWeek: Int = 0
    var preferredDays: [String] = []
    var sessionDuration: String = ""
    var trainingLocation: String = ""
    var equipmentCategory: String = ""
    var jointPain: [String] = []
}

nonisolated struct WorkoutStyleCategory: Sendable, Identifiable {
    let id: String
    let nameKey: String
    let emoji: String
    let sports: [String]

    var name: String {
        Lang.localizedCategory(id)
    }
}

nonisolated struct SportQuestion: Sendable, Identifiable {
    let id: String
    let label: String
    let placeholder: String
    let unit: String
}

enum WorkoutQuizStaticData {
    static var fitnessGoals: [(id: String, name: String, icon: String)] {
        [
            ("tone", Lang.s("goal_tone"), "scope"),
            ("lose_weight", Lang.s("goal_lose_weight"), "chart.line.downtrend.xyaxis"),
            ("gain_muscle", Lang.s("goal_gain_muscle"), "bolt.fill"),
            ("mobility", Lang.s("goal_mobility"), "figure.flexibility")
        ]
    }

    static let categories: [WorkoutStyleCategory] = [
        WorkoutStyleCategory(id: "strength", nameKey: "strength", emoji: "💪", sports: [
            "Bodybuilding", "Powerlifting", "Weightlifting (Sollevamento Olimpico)",
            "Streetlifting", "Calisthenics", "Functional Training",
            "Allenamento in sospensione (TRX)"
        ]),
        WorkoutStyleCategory(id: "hiit", nameKey: "hiit", emoji: "🔥", sports: [
            "HIIT (High Intensity Interval Training)", "CrossFit",
            "Tabata", "Bootcamp", "Circuit Training"
        ]),
        WorkoutStyleCategory(id: "conditioning", nameKey: "conditioning", emoji: "🏃", sports: [
            "Athletic Training", "Plyometrics", "Sprint Training",
            "Endurance Training", "Metabolic Conditioning (MetCon)"
        ]),
        WorkoutStyleCategory(id: "mobility", nameKey: "mobility", emoji: "🤸", sports: [
            "Ginnastica artistica / corpo libero", "Animal Flow",
            "MovNat", "Yoga strength / Power Yoga",
            "Pilates Matwork e Reformer"
        ]),
        WorkoutStyleCategory(id: "dance", nameKey: "dance", emoji: "💃", sports: [
            "Zumba", "Dance Fitness", "Choreographic Step",
            "BodyJam (Les Mills)", "Sh'Bam", "Pound Workout"
        ]),
        WorkoutStyleCategory(id: "mindbody", nameKey: "mindbody", emoji: "🧘", sports: [
            "Yoga (Hatha, Vinyasa, Yin, Power)", "Pilates",
            "Stretching / Mobility Flow", "Tai Chi",
            "Mindfulness Movement"
        ]),
        WorkoutStyleCategory(id: "combat", nameKey: "combat", emoji: "🥊", sports: [
            "Kickboxing Fitness", "Boxe / Functional Boxing",
            "MMA Conditioning", "Fit Kombat",
            "Krav Maga (versione fitness)"
        ]),
        WorkoutStyleCategory(id: "equipment", nameKey: "equipment", emoji: "🚴", sports: [
            "Spinning / Indoor Cycling", "Elliptical Training",
            "Rowing Machine", "Kettlebell Training",
            "Sandbag Training", "Battle Ropes"
        ]),
        WorkoutStyleCategory(id: "branded", nameKey: "branded", emoji: "🏋️", sports: [
            "BodyPump", "BodyCombat", "BodyBalance",
            "BodyAttack", "GRIT", "CXWorx/Core", "Booty Barre"
        ])
    ]

    static func questions(for sport: String) -> [SportQuestion] {
        switch sport {
        case "Bodybuilding":
            return [
                SportQuestion(id: "experience_years", label: Lang.s("sq_experience"), placeholder: "2", unit: Lang.s("sq_years")),
                SportQuestion(id: "squat_max", label: Lang.s("sq_squat_max"), placeholder: "80", unit: "kg"),
                SportQuestion(id: "bench_max", label: Lang.s("sq_bench_max"), placeholder: "60", unit: "kg"),
                SportQuestion(id: "deadlift_max", label: Lang.s("sq_deadlift_max"), placeholder: "100", unit: "kg"),
            ]
        case "Powerlifting":
            return [
                SportQuestion(id: "squat_1rm", label: Lang.s("sq_squat_1rm"), placeholder: "120", unit: "kg"),
                SportQuestion(id: "bench_1rm", label: Lang.s("sq_bench_1rm"), placeholder: "90", unit: "kg"),
                SportQuestion(id: "deadlift_1rm", label: Lang.s("sq_deadlift_1rm"), placeholder: "140", unit: "kg"),
                SportQuestion(id: "weight_class", label: Lang.s("sq_weight_class"), placeholder: "83", unit: "kg"),
            ]
        case "Weightlifting (Sollevamento Olimpico)":
            return [
                SportQuestion(id: "snatch_max", label: Lang.s("sq_snatch_max"), placeholder: "60", unit: "kg"),
                SportQuestion(id: "clean_jerk_max", label: Lang.s("sq_clean_jerk_max"), placeholder: "80", unit: "kg"),
                SportQuestion(id: "front_squat_max", label: Lang.s("sq_front_squat_max"), placeholder: "90", unit: "kg"),
            ]
        case "Streetlifting":
            return [
                SportQuestion(id: "weighted_dip", label: Lang.s("sq_weighted_dip"), placeholder: "20", unit: "kg"),
                SportQuestion(id: "weighted_pullup", label: Lang.s("sq_weighted_pullup"), placeholder: "15", unit: "kg"),
                SportQuestion(id: "max_pullups", label: Lang.s("sq_max_pullups"), placeholder: "15", unit: "reps"),
            ]
        case "Calisthenics":
            return [
                SportQuestion(id: "max_pullups", label: Lang.s("sq_max_pullups"), placeholder: "10", unit: "reps"),
                SportQuestion(id: "max_pushups", label: Lang.s("sq_max_pushups"), placeholder: "30", unit: "reps"),
                SportQuestion(id: "max_dips", label: Lang.s("sq_max_dips"), placeholder: "15", unit: "reps"),
                SportQuestion(id: "experience_months", label: Lang.s("sq_experience"), placeholder: "12", unit: Lang.s("sq_months")),
            ]
        case "Functional Training":
            return [
                SportQuestion(id: "experience_months", label: Lang.s("sq_experience"), placeholder: "6", unit: Lang.s("sq_months")),
                SportQuestion(id: "sessions_week", label: Lang.s("sq_sessions_week"), placeholder: "3", unit: ""),
                SportQuestion(id: "session_duration", label: Lang.s("sq_session_duration"), placeholder: "45", unit: "min"),
            ]
        case "Allenamento in sospensione (TRX)":
            return [
                SportQuestion(id: "experience_months", label: Lang.s("sq_experience"), placeholder: "6", unit: Lang.s("sq_months")),
                SportQuestion(id: "sessions_week", label: Lang.s("sq_sessions_week"), placeholder: "3", unit: ""),
            ]
        case "HIIT (High Intensity Interval Training)":
            return [
                SportQuestion(id: "experience_months", label: Lang.s("sq_experience"), placeholder: "6", unit: Lang.s("sq_months")),
                SportQuestion(id: "session_duration", label: Lang.s("sq_preferred_duration"), placeholder: "30", unit: "min"),
                SportQuestion(id: "sessions_week", label: Lang.s("sq_sessions_week"), placeholder: "3", unit: ""),
            ]
        case "CrossFit":
            return [
                SportQuestion(id: "experience_months", label: Lang.s("sq_experience"), placeholder: "12", unit: Lang.s("sq_months")),
                SportQuestion(id: "fran_time", label: Lang.s("sq_fran_time"), placeholder: "5:30", unit: "min"),
                SportQuestion(id: "max_pullups", label: Lang.s("sq_max_pullups"), placeholder: "15", unit: "reps"),
            ]
        case "Athletic Training":
            return [
                SportQuestion(id: "experience_years", label: Lang.s("sq_experience"), placeholder: "3", unit: Lang.s("sq_years")),
                SportQuestion(id: "sessions_week", label: Lang.s("sq_sessions_week"), placeholder: "4", unit: ""),
                SportQuestion(id: "vertical_jump", label: Lang.s("sq_vertical_jump"), placeholder: "45", unit: "cm"),
            ]
        case "Plyometrics":
            return [
                SportQuestion(id: "experience_months", label: Lang.s("sq_experience"), placeholder: "6", unit: Lang.s("sq_months")),
                SportQuestion(id: "vertical_jump", label: Lang.s("sq_vertical_jump"), placeholder: "40", unit: "cm"),
            ]
        case "Sprint Training":
            return [
                SportQuestion(id: "time_100m", label: Lang.s("sq_time_100m"), placeholder: "12.5", unit: "sec"),
                SportQuestion(id: "experience_months", label: Lang.s("sq_experience"), placeholder: "6", unit: Lang.s("sq_months")),
            ]
        case "Endurance Training":
            return [
                SportQuestion(id: "time_5k", label: Lang.s("sq_time_5k"), placeholder: "25", unit: "min"),
                SportQuestion(id: "weekly_km", label: Lang.s("sq_weekly_volume"), placeholder: "20", unit: "km"),
                SportQuestion(id: "experience_months", label: Lang.s("sq_experience"), placeholder: "12", unit: Lang.s("sq_months")),
            ]
        case "Spinning / Indoor Cycling":
            return [
                SportQuestion(id: "ftp_watts", label: Lang.s("sq_ftp"), placeholder: "150", unit: "watts"),
                SportQuestion(id: "sessions_week", label: Lang.s("sq_sessions_week"), placeholder: "3", unit: ""),
                SportQuestion(id: "experience_months", label: Lang.s("sq_experience"), placeholder: "6", unit: Lang.s("sq_months")),
            ]
        case "Rowing Machine":
            return [
                SportQuestion(id: "time_2k", label: Lang.s("sq_time_2k"), placeholder: "8:00", unit: "min"),
                SportQuestion(id: "sessions_week", label: Lang.s("sq_sessions_week"), placeholder: "3", unit: ""),
                SportQuestion(id: "experience_months", label: Lang.s("sq_experience"), placeholder: "6", unit: Lang.s("sq_months")),
            ]
        case "Kettlebell Training":
            return [
                SportQuestion(id: "typical_weight", label: Lang.s("sq_typical_kb_weight"), placeholder: "16", unit: "kg"),
                SportQuestion(id: "experience_months", label: Lang.s("sq_experience"), placeholder: "6", unit: Lang.s("sq_months")),
                SportQuestion(id: "sessions_week", label: Lang.s("sq_sessions_week"), placeholder: "3", unit: ""),
            ]
        case "Sandbag Training":
            return [
                SportQuestion(id: "typical_weight", label: Lang.s("sq_typical_weight"), placeholder: "20", unit: "kg"),
                SportQuestion(id: "experience_months", label: Lang.s("sq_experience"), placeholder: "3", unit: Lang.s("sq_months")),
            ]
        case "Boxe / Functional Boxing":
            return [
                SportQuestion(id: "experience_months", label: Lang.s("sq_experience"), placeholder: "6", unit: Lang.s("sq_months")),
                SportQuestion(id: "sessions_week", label: Lang.s("sq_sessions_week"), placeholder: "3", unit: ""),
                SportQuestion(id: "rounds_sparring", label: Lang.s("sq_rounds_sparring"), placeholder: "3", unit: "rounds"),
            ]
        case "BodyPump":
            return [
                SportQuestion(id: "squat", label: Lang.s("sq_squat_bp"), placeholder: "20", unit: "kg"),
                SportQuestion(id: "chest", label: Lang.s("sq_chest_bp"), placeholder: "15", unit: "kg"),
                SportQuestion(id: "back", label: Lang.s("sq_back_bp"), placeholder: "12", unit: "kg"),
                SportQuestion(id: "triceps", label: Lang.s("sq_triceps_bp"), placeholder: "8", unit: "kg"),
                SportQuestion(id: "biceps", label: Lang.s("sq_biceps_bp"), placeholder: "10", unit: "kg"),
                SportQuestion(id: "lunges", label: Lang.s("sq_lunges_bp"), placeholder: "15", unit: "kg"),
            ]
        default:
            return [
                SportQuestion(id: "experience_months", label: Lang.s("sq_experience"), placeholder: "6", unit: Lang.s("sq_months")),
                SportQuestion(id: "sessions_week", label: Lang.s("sq_sessions_week"), placeholder: "3", unit: ""),
            ]
        }
    }

    struct TrainingFrequencyOption: Sendable {
        let id: String
        let title: String
        let subtitle: String
    }

    static var trainingFrequencies: [TrainingFrequencyOption] {
        [
            TrainingFrequencyOption(id: "never", title: Lang.s("freq_never"), subtitle: Lang.s("freq_never_desc")),
            TrainingFrequencyOption(id: "occasionally", title: Lang.s("freq_occasionally"), subtitle: Lang.s("freq_occasionally_desc")),
            TrainingFrequencyOption(id: "1-2_week", title: Lang.s("freq_1_2_week"), subtitle: Lang.s("freq_1_2_week_desc")),
            TrainingFrequencyOption(id: "3+_week", title: Lang.s("freq_3_plus_week"), subtitle: Lang.s("freq_3_plus_week_desc")),
        ]
    }

    struct StrengthLevelOption: Sendable {
        let id: String
        let title: String
        let subtitle: String
        let icon: String
    }

    static var strengthLevels: [StrengthLevelOption] {
        [
            StrengthLevelOption(id: "never", title: Lang.s("str_never_lifted"), subtitle: Lang.s("str_never_lifted_desc"), icon: "circle.dotted"),
            StrengthLevelOption(id: "light", title: Lang.s("str_light"), subtitle: Lang.s("str_light_desc"), icon: "scalemass"),
            StrengthLevelOption(id: "moderate", title: Lang.s("str_moderate"), subtitle: Lang.s("str_moderate_desc"), icon: "scalemass.fill"),
            StrengthLevelOption(id: "intermediate", title: Lang.s("str_intermediate"), subtitle: Lang.s("str_intermediate_desc"), icon: "chart.line.uptrend.xyaxis"),
            StrengthLevelOption(id: "advanced", title: Lang.s("str_advanced"), subtitle: Lang.s("str_advanced_desc"), icon: "bolt.fill"),
        ]
    }

    struct WeekDayOption: Sendable {
        let id: String
        let label: String
    }

    static var weekDayOptions: [WeekDayOption] {
        [
            WeekDayOption(id: "Monday", label: Lang.s("wd_mon")),
            WeekDayOption(id: "Tuesday", label: Lang.s("wd_tue")),
            WeekDayOption(id: "Wednesday", label: Lang.s("wd_wed")),
            WeekDayOption(id: "Thursday", label: Lang.s("wd_thu")),
            WeekDayOption(id: "Friday", label: Lang.s("wd_fri")),
            WeekDayOption(id: "Saturday", label: Lang.s("wd_sat")),
            WeekDayOption(id: "Sunday", label: Lang.s("wd_sun")),
        ]
    }

    static var weekDays: [String] {
        weekDayOptions.map { $0.label }
    }

    struct SessionDurationOption: Sendable {
        let id: String
        let title: String
        let subtitle: String
    }

    static var sessionDurations: [SessionDurationOption] {
        [
            SessionDurationOption(id: "20", title: "< 20 min", subtitle: Lang.s("session_quick")),
            SessionDurationOption(id: "30", title: "30 min", subtitle: Lang.s("session_standard")),
            SessionDurationOption(id: "45", title: "45 min", subtitle: Lang.s("session_extended")),
            SessionDurationOption(id: "60", title: "60+ min", subtitle: Lang.s("session_long")),
        ]
    }

    struct TrainingLocationOption: Sendable {
        let id: String
        let emoji: String
        let title: String
        let subtitle: String
    }

    static var trainingLocations: [TrainingLocationOption] {
        [
            TrainingLocationOption(id: "gym", emoji: "🏋️", title: Lang.s("loc_gym"), subtitle: Lang.s("loc_gym_desc")),
            TrainingLocationOption(id: "home", emoji: "🏠", title: Lang.s("loc_home"), subtitle: Lang.s("loc_home_desc")),
            TrainingLocationOption(id: "outdoors", emoji: "🌳", title: Lang.s("loc_outdoors"), subtitle: Lang.s("loc_outdoors_desc")),
        ]
    }

    struct EquipmentOption: Sendable {
        let id: String
        let emoji: String
        let title: String
        let subtitle: String
    }

    static var equipmentCategories: [EquipmentOption] {
        [
            EquipmentOption(id: "bodyweight", emoji: "💪", title: Lang.s("eq_bodyweight"), subtitle: Lang.s("eq_bodyweight_desc")),
            EquipmentOption(id: "home_basic", emoji: "🏠", title: Lang.s("eq_home_basic"), subtitle: Lang.s("eq_home_basic_desc")),
            EquipmentOption(id: "home_complete", emoji: "🏠", title: Lang.s("eq_home_complete"), subtitle: Lang.s("eq_home_complete_desc")),
            EquipmentOption(id: "gym_basic", emoji: "🏋️", title: Lang.s("eq_gym_basic"), subtitle: Lang.s("eq_gym_basic_desc")),
            EquipmentOption(id: "gym_complete", emoji: "🏋️", title: Lang.s("eq_gym_complete"), subtitle: Lang.s("eq_gym_complete_desc")),
            EquipmentOption(id: "crossfit", emoji: "⚡", title: Lang.s("eq_crossfit"), subtitle: Lang.s("eq_crossfit_desc")),
            EquipmentOption(id: "outdoors", emoji: "🌳", title: Lang.s("eq_outdoors"), subtitle: Lang.s("eq_outdoors_desc")),
            EquipmentOption(id: "custom", emoji: "⚙️", title: Lang.s("eq_custom"), subtitle: Lang.s("eq_custom_desc")),
        ]
    }

    struct JointPainOption: Sendable {
        let id: String
        let emoji: String
        let title: String
        let subtitle: String
    }

    static var jointPainAreas: [JointPainOption] {
        [
            JointPainOption(id: "knees", emoji: "🦵", title: Lang.s("jp_knees"), subtitle: Lang.s("jp_knees_desc")),
            JointPainOption(id: "back", emoji: "🧍", title: Lang.s("jp_back"), subtitle: Lang.s("jp_back_desc")),
            JointPainOption(id: "shoulders", emoji: "💪", title: Lang.s("jp_shoulders"), subtitle: Lang.s("jp_shoulders_desc")),
            JointPainOption(id: "elbows", emoji: "💪", title: Lang.s("jp_elbows"), subtitle: Lang.s("jp_elbows_desc")),
            JointPainOption(id: "wrists", emoji: "👊", title: Lang.s("jp_wrists"), subtitle: Lang.s("jp_wrists_desc")),
            JointPainOption(id: "hips", emoji: "🦴", title: Lang.s("jp_hips"), subtitle: Lang.s("jp_hips_desc")),
            JointPainOption(id: "ankles", emoji: "🦶", title: Lang.s("jp_ankles"), subtitle: Lang.s("jp_ankles_desc")),
            JointPainOption(id: "No Pain", emoji: "✅", title: Lang.s("jp_no_pain"), subtitle: Lang.s("jp_no_pain_desc")),
        ]
    }
}
