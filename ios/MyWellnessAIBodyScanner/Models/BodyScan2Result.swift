import Foundation

nonisolated struct BodyRegionDetail: Codable, Sendable, Identifiable {
    var id: String { region }
    let region: String
    let muscleDefinition: String
    let fatDistribution: String
    let bloating: String
    let score: Int
    let notes: String
    let improvementTips: [String]

    init(region: String, muscleDefinition: String, fatDistribution: String, bloating: String, score: Int, notes: String, improvementTips: [String]) {
        self.region = region
        self.muscleDefinition = muscleDefinition
        self.fatDistribution = fatDistribution
        self.bloating = bloating
        self.score = score
        self.notes = notes
        self.improvementTips = improvementTips
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        region = (try? c.decode(String.self, forKey: .region)) ?? "--"
        muscleDefinition = (try? c.decode(String.self, forKey: .muscleDefinition)) ?? "--"
        fatDistribution = (try? c.decode(String.self, forKey: .fatDistribution)) ?? "--"
        bloating = (try? c.decode(String.self, forKey: .bloating)) ?? "--"
        if let intVal = try? c.decode(Int.self, forKey: .score) {
            score = intVal
        } else if let dblVal = try? c.decode(Double.self, forKey: .score) {
            score = Int(dblVal)
        } else {
            score = 5
        }
        notes = (try? c.decode(String.self, forKey: .notes)) ?? ""
        improvementTips = (try? c.decode([String].self, forKey: .improvementTips)) ?? []
    }
}

nonisolated struct BodyScan2Result: Codable, Sendable {
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
    let bodyRegions: [BodyRegionDetail]
    let fatDistributionSummary: String
    let bloatingAreas: [String]
    let dailyCalories: Int
    let proteinGrams: Int
    let carbsGrams: Int
    let fatGrams: Int
    let nutritionRecommendations: [String]
    let sampleMeals: [BodyScan2Meal]
    let trainingDaysPerWeek: Int
    let trainingSplit: String
    let focusAreas: [String]
    let sampleExercises: [BodyScan2Exercise]
    let trainingRecommendations: [String]

    init(somatotype: String, estimatedBodyFat: String, biologicalAge: String,
         muscleDefinition: String, bloatingPercentage: String = "--", skinTexture: String = "--",
         strongPoints: [String] = [], weakPoints: [String] = [],
         overallAssessment: String, posturalNotes: String,
         bodyRegions: [BodyRegionDetail] = [], fatDistributionSummary: String = "--",
         bloatingAreas: [String] = [],
         dailyCalories: Int, proteinGrams: Int, carbsGrams: Int, fatGrams: Int,
         nutritionRecommendations: [String], sampleMeals: [BodyScan2Meal],
         trainingDaysPerWeek: Int, trainingSplit: String, focusAreas: [String],
         sampleExercises: [BodyScan2Exercise], trainingRecommendations: [String]) {
        self.somatotype = somatotype
        self.estimatedBodyFat = estimatedBodyFat
        self.biologicalAge = biologicalAge
        self.muscleDefinition = muscleDefinition
        self.bloatingPercentage = bloatingPercentage
        self.skinTexture = skinTexture
        self.strongPoints = strongPoints
        self.weakPoints = weakPoints
        self.overallAssessment = overallAssessment
        self.posturalNotes = posturalNotes
        self.bodyRegions = bodyRegions
        self.fatDistributionSummary = fatDistributionSummary
        self.bloatingAreas = bloatingAreas
        self.dailyCalories = dailyCalories
        self.proteinGrams = proteinGrams
        self.carbsGrams = carbsGrams
        self.fatGrams = fatGrams
        self.nutritionRecommendations = nutritionRecommendations
        self.sampleMeals = sampleMeals
        self.trainingDaysPerWeek = trainingDaysPerWeek
        self.trainingSplit = trainingSplit
        self.focusAreas = focusAreas
        self.sampleExercises = sampleExercises
        self.trainingRecommendations = trainingRecommendations
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        somatotype = (try? c.decode(String.self, forKey: .somatotype)) ?? "Mesomorfo"
        estimatedBodyFat = (try? c.decode(String.self, forKey: .estimatedBodyFat)) ?? "--"
        biologicalAge = (try? c.decode(String.self, forKey: .biologicalAge)) ?? "--"
        muscleDefinition = (try? c.decode(String.self, forKey: .muscleDefinition)) ?? "--"
        bloatingPercentage = (try? c.decode(String.self, forKey: .bloatingPercentage)) ?? "--"
        skinTexture = (try? c.decode(String.self, forKey: .skinTexture)) ?? "--"
        strongPoints = (try? c.decode([String].self, forKey: .strongPoints)) ?? []
        weakPoints = (try? c.decode([String].self, forKey: .weakPoints)) ?? []
        overallAssessment = (try? c.decode(String.self, forKey: .overallAssessment)) ?? ""
        posturalNotes = (try? c.decode(String.self, forKey: .posturalNotes)) ?? ""
        bodyRegions = (try? c.decode([BodyRegionDetail].self, forKey: .bodyRegions)) ?? []
        fatDistributionSummary = (try? c.decode(String.self, forKey: .fatDistributionSummary)) ?? "--"
        bloatingAreas = (try? c.decode([String].self, forKey: .bloatingAreas)) ?? []
        if let intVal = try? c.decode(Int.self, forKey: .dailyCalories) {
            dailyCalories = intVal
        } else if let dblVal = try? c.decode(Double.self, forKey: .dailyCalories) {
            dailyCalories = Int(dblVal)
        } else {
            dailyCalories = 2000
        }
        if let intVal = try? c.decode(Int.self, forKey: .proteinGrams) {
            proteinGrams = intVal
        } else if let dblVal = try? c.decode(Double.self, forKey: .proteinGrams) {
            proteinGrams = Int(dblVal)
        } else {
            proteinGrams = 150
        }
        if let intVal = try? c.decode(Int.self, forKey: .carbsGrams) {
            carbsGrams = intVal
        } else if let dblVal = try? c.decode(Double.self, forKey: .carbsGrams) {
            carbsGrams = Int(dblVal)
        } else {
            carbsGrams = 200
        }
        if let intVal = try? c.decode(Int.self, forKey: .fatGrams) {
            fatGrams = intVal
        } else if let dblVal = try? c.decode(Double.self, forKey: .fatGrams) {
            fatGrams = Int(dblVal)
        } else {
            fatGrams = 65
        }
        nutritionRecommendations = (try? c.decode([String].self, forKey: .nutritionRecommendations)) ?? []
        sampleMeals = (try? c.decode([BodyScan2Meal].self, forKey: .sampleMeals)) ?? []
        if let intVal = try? c.decode(Int.self, forKey: .trainingDaysPerWeek) {
            trainingDaysPerWeek = intVal
        } else if let dblVal = try? c.decode(Double.self, forKey: .trainingDaysPerWeek) {
            trainingDaysPerWeek = Int(dblVal)
        } else {
            trainingDaysPerWeek = 4
        }
        trainingSplit = (try? c.decode(String.self, forKey: .trainingSplit)) ?? "Full Body"
        focusAreas = (try? c.decode([String].self, forKey: .focusAreas)) ?? []
        sampleExercises = (try? c.decode([BodyScan2Exercise].self, forKey: .sampleExercises)) ?? []
        trainingRecommendations = (try? c.decode([String].self, forKey: .trainingRecommendations)) ?? []
    }

    static func fallback() -> BodyScan2Result {
        let lang = UserDefaults.standard.string(forKey: "appLanguage") ?? "en"
        switch lang {
        case "it":
            return BodyScan2Result(
                somatotype: "Mesomorfo",
                estimatedBodyFat: "19-20%",
                biologicalAge: "25",
                muscleDefinition: "Moderata",
                bloatingPercentage: "10-15%",
                skinTexture: "Normale, leggermente disidratata",
                strongPoints: ["Buona struttura delle spalle", "Proporzioni equilibrate tra parte superiore e inferiore", "Buona base muscolare nelle gambe"],
                weakPoints: ["La definizione addominale necessita miglioramento", "Petto poco sviluppato", "Dorsali asimmetrici"],
                overallAssessment: "Buona composizione corporea con margine di miglioramento nella definizione muscolare.",
                posturalNotes: "Postura normale, leggera inclinazione delle spalle in avanti.",
                dailyCalories: 2200,
                proteinGrams: 165,
                carbsGrams: 240,
                fatGrams: 70,
                nutritionRecommendations: [
                    "Aumentare l'apporto proteico a 1.8g/kg",
                    "Distribuire i carboidrati prima e dopo l'allenamento",
                    "Includere grassi sani da fonti come avocado, frutta secca e olio d'oliva"
                ],
                sampleMeals: [
                    BodyScan2Meal(name: "Colazione proteica", type: "breakfast", calories: 450, description: "Avena con proteine, banana e burro di arachidi"),
                    BodyScan2Meal(name: "Pranzo equilibrato", type: "lunch", calories: 650, description: "Pollo alla piastra, riso integrale e verdure"),
                    BodyScan2Meal(name: "Cena leggera", type: "dinner", calories: 550, description: "Salmone al forno con patata dolce e insalata")
                ],
                trainingDaysPerWeek: 4,
                trainingSplit: "Divisione Superiore/Inferiore",
                focusAreas: ["Petto", "Schiena", "Gambe"],
                sampleExercises: [
                    BodyScan2Exercise(name: "Panca piana", sets: 4, reps: "8-10", muscleGroup: "Petto"),
                    BodyScan2Exercise(name: "Squat", sets: 4, reps: "8-10", muscleGroup: "Gambe"),
                    BodyScan2Exercise(name: "Trazioni", sets: 3, reps: "8-12", muscleGroup: "Schiena"),
                    BodyScan2Exercise(name: "Military press", sets: 3, reps: "10-12", muscleGroup: "Spalle"),
                    BodyScan2Exercise(name: "Stacco rumeno", sets: 3, reps: "10-12", muscleGroup: "Posteriore")
                ],
                trainingRecommendations: [
                    "Concentrarsi su movimenti composti multiarticolari",
                    "Aumentare progressivamente i carichi ogni settimana",
                    "Includere almeno 2 sessioni di cardio a bassa intensità"
                ]
            )
        case "es":
            return BodyScan2Result(
                somatotype: "Mesomorfo",
                estimatedBodyFat: "19-20%",
                biologicalAge: "25",
                muscleDefinition: "Moderada",
                bloatingPercentage: "10-15%",
                skinTexture: "Normal, ligeramente deshidratada",
                strongPoints: ["Buena estructura de hombros", "Proporciones equilibradas entre tren superior e inferior", "Buena base muscular en piernas"],
                weakPoints: ["La definición abdominal necesita mejora", "Pecho poco desarrollado", "Dorsales asimétricos"],
                overallAssessment: "Buena composición corporal con margen de mejora en definición muscular.",
                posturalNotes: "Postura normal, ligera inclinación de hombros hacia adelante.",
                dailyCalories: 2200,
                proteinGrams: 165,
                carbsGrams: 240,
                fatGrams: 70,
                nutritionRecommendations: [
                    "Aumentar la ingesta de proteínas a 1.8g/kg",
                    "Distribuir carbohidratos antes y después del entrenamiento",
                    "Incluir grasas saludables de fuentes como aguacate, frutos secos y aceite de oliva"
                ],
                sampleMeals: [
                    BodyScan2Meal(name: "Desayuno proteico", type: "breakfast", calories: 450, description: "Avena con proteína, plátano y mantequilla de maní"),
                    BodyScan2Meal(name: "Almuerzo equilibrado", type: "lunch", calories: 650, description: "Pollo a la plancha, arroz integral y verduras"),
                    BodyScan2Meal(name: "Cena ligera", type: "dinner", calories: 550, description: "Salmón al horno con batata y ensalada")
                ],
                trainingDaysPerWeek: 4,
                trainingSplit: "División Superior/Inferior",
                focusAreas: ["Pecho", "Espalda", "Piernas"],
                sampleExercises: [
                    BodyScan2Exercise(name: "Press de banca", sets: 4, reps: "8-10", muscleGroup: "Pecho"),
                    BodyScan2Exercise(name: "Sentadilla", sets: 4, reps: "8-10", muscleGroup: "Piernas"),
                    BodyScan2Exercise(name: "Dominadas", sets: 3, reps: "8-12", muscleGroup: "Espalda"),
                    BodyScan2Exercise(name: "Press militar", sets: 3, reps: "10-12", muscleGroup: "Hombros"),
                    BodyScan2Exercise(name: "Peso muerto rumano", sets: 3, reps: "10-12", muscleGroup: "Posterior")
                ],
                trainingRecommendations: [
                    "Enfocarse en movimientos compuestos multiarticulares",
                    "Aumentar progresivamente las cargas cada semana",
                    "Incluir al menos 2 sesiones de cardio de baja intensidad"
                ]
            )
        default:
            return BodyScan2Result(
                somatotype: "Mesomorph",
                estimatedBodyFat: "19-20%",
                biologicalAge: "25",
                muscleDefinition: "Moderate",
                bloatingPercentage: "10-15%",
                skinTexture: "Normal, slightly dehydrated",
                strongPoints: ["Good shoulder structure", "Balanced upper/lower body proportions", "Good muscular base in legs"],
                weakPoints: ["Abdominal definition needs improvement", "Underdeveloped chest", "Asymmetric lats"],
                overallAssessment: "Good body composition with room for improvement in muscle definition.",
                posturalNotes: "Normal posture, slight forward shoulder tilt.",
                dailyCalories: 2200,
                proteinGrams: 165,
                carbsGrams: 240,
                fatGrams: 70,
                nutritionRecommendations: [
                    "Increase protein intake to 1.8g/kg",
                    "Distribute carbs before and after training",
                    "Include healthy fats from sources like avocado, nuts and olive oil"
                ],
                sampleMeals: [
                    BodyScan2Meal(name: "Protein Breakfast", type: "breakfast", calories: 450, description: "Oats with protein, banana and peanut butter"),
                    BodyScan2Meal(name: "Balanced Lunch", type: "lunch", calories: 650, description: "Grilled chicken, brown rice and vegetables"),
                    BodyScan2Meal(name: "Light Dinner", type: "dinner", calories: 550, description: "Baked salmon with sweet potato and salad")
                ],
                trainingDaysPerWeek: 4,
                trainingSplit: "Upper/Lower Split",
                focusAreas: ["Chest", "Back", "Legs"],
                sampleExercises: [
                    BodyScan2Exercise(name: "Bench Press", sets: 4, reps: "8-10", muscleGroup: "Chest"),
                    BodyScan2Exercise(name: "Squat", sets: 4, reps: "8-10", muscleGroup: "Legs"),
                    BodyScan2Exercise(name: "Pull-ups", sets: 3, reps: "8-12", muscleGroup: "Back"),
                    BodyScan2Exercise(name: "Military Press", sets: 3, reps: "10-12", muscleGroup: "Shoulders"),
                    BodyScan2Exercise(name: "Romanian Deadlift", sets: 3, reps: "10-12", muscleGroup: "Posterior")
                ],
                trainingRecommendations: [
                    "Focus on compound multi-joint movements",
                    "Progressively increase loads each week",
                    "Include at least 2 low-intensity cardio sessions"
                ]
            )
        }
    }
}

nonisolated struct BodyScan2Meal: Codable, Sendable, Identifiable {
    var id: String { "\(name)-\(type)" }
    let name: String
    let type: String
    let calories: Int
    let description: String

    init(name: String, type: String, calories: Int, description: String) {
        self.name = name
        self.type = type
        self.calories = calories
        self.description = description
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        name = (try? c.decode(String.self, forKey: .name)) ?? "Meal"
        type = (try? c.decode(String.self, forKey: .type)) ?? "snack"
        if let intVal = try? c.decode(Int.self, forKey: .calories) {
            calories = intVal
        } else if let dblVal = try? c.decode(Double.self, forKey: .calories) {
            calories = Int(dblVal)
        } else {
            calories = 400
        }
        description = (try? c.decode(String.self, forKey: .description)) ?? ""
    }
}

nonisolated struct BodyScan2Exercise: Codable, Sendable, Identifiable {
    var id: String { "\(name)-\(muscleGroup)" }
    let name: String
    let sets: Int
    let reps: String
    let muscleGroup: String

    init(name: String, sets: Int, reps: String, muscleGroup: String) {
        self.name = name
        self.sets = sets
        self.reps = reps
        self.muscleGroup = muscleGroup
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        name = (try? c.decode(String.self, forKey: .name)) ?? "Exercise"
        if let intVal = try? c.decode(Int.self, forKey: .sets) {
            sets = intVal
        } else if let dblVal = try? c.decode(Double.self, forKey: .sets) {
            sets = Int(dblVal)
        } else {
            sets = 3
        }
        reps = (try? c.decode(String.self, forKey: .reps)) ?? "10"
        muscleGroup = (try? c.decode(String.self, forKey: .muscleGroup)) ?? ""
    }
}
