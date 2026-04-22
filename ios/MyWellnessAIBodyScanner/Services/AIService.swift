import Foundation
import UIKit

nonisolated enum AIServiceError: LocalizedError, Sendable {
    case invalidURL
    case networkError(String)
    case decodingError
    case noContent

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "Invalid URL"
        case .networkError(let message): return message
        case .decodingError: return "Failed to decode response"
        case .noContent: return "No content received"
        }
    }
}

nonisolated struct ScannedIngredient: Identifiable, Codable, Sendable {
    var id: UUID = UUID()
    var name: String
    var quantity: String
    var calories: Int
    var protein: Double
    var carbs: Double
    var fat: Double

    enum CodingKeys: String, CodingKey {
        case name, quantity, calories, protein, carbs, fat
    }

    init(name: String, quantity: String, calories: Int, protein: Double, carbs: Double, fat: Double) {
        self.name = name
        self.quantity = quantity
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        name = try c.decode(String.self, forKey: .name)
        quantity = (try? c.decode(String.self, forKey: .quantity)) ?? "1 portion"
        if let intVal = try? c.decode(Int.self, forKey: .calories) {
            calories = intVal
        } else if let dblVal = try? c.decode(Double.self, forKey: .calories) {
            calories = Int(dblVal)
        } else {
            calories = 0
        }
        protein = (try? c.decode(Double.self, forKey: .protein)) ?? 0
        carbs = (try? c.decode(Double.self, forKey: .carbs)) ?? 0
        fat = (try? c.decode(Double.self, forKey: .fat)) ?? 0
    }
}

nonisolated struct CalorieAnalysisResult: Codable, Sendable {
    var foodName: String
    var calories: Int
    var protein: Double
    var carbs: Double
    var fat: Double
    var servingSize: String
    var confidence: String
    var notes: String
    var ingredients: [ScannedIngredient]

    init(foodName: String, calories: Int, protein: Double, carbs: Double, fat: Double,
         servingSize: String, confidence: String, notes: String, ingredients: [ScannedIngredient] = []) {
        self.foodName = foodName
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fat = fat
        self.servingSize = servingSize
        self.confidence = confidence
        self.notes = notes
        self.ingredients = ingredients
    }

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        foodName = try c.decode(String.self, forKey: .foodName)
        if let intVal = try? c.decode(Int.self, forKey: .calories) {
            calories = intVal
        } else if let dblVal = try? c.decode(Double.self, forKey: .calories) {
            calories = Int(dblVal)
        } else {
            calories = 0
        }
        protein = (try? c.decode(Double.self, forKey: .protein)) ?? 0
        carbs = (try? c.decode(Double.self, forKey: .carbs)) ?? 0
        fat = (try? c.decode(Double.self, forKey: .fat)) ?? 0
        servingSize = (try? c.decode(String.self, forKey: .servingSize)) ?? "1 serving"
        confidence = (try? c.decode(String.self, forKey: .confidence)) ?? "Medium"
        notes = (try? c.decode(String.self, forKey: .notes)) ?? ""
        ingredients = (try? c.decode([ScannedIngredient].self, forKey: .ingredients)) ?? []
    }

    static func fallback() -> CalorieAnalysisResult {
        CalorieAnalysisResult(
            foodName: "Detected Meal",
            calories: 400,
            protein: 20,
            carbs: 50,
            fat: 12,
            servingSize: "1 serving",
            confidence: "Low",
            notes: "Unable to analyze details"
        )
    }
}

nonisolated struct NutritionTableResult: Codable, Sendable {
    let productName: String
    let servingSize: String
    let calories: Int
    let totalFat: Double
    let saturatedFat: Double
    let carbohydrates: Double
    let sugars: Double
    let protein: Double
    let salt: Double
    let fiber: Double
}

nonisolated struct AIService: Sendable {
    private static let toolkitURL = Config.EXPO_PUBLIC_TOOLKIT_URL

    private static var useKimi: Bool {
        KimiService.isConfigured
    }

    static var aiLanguageName: String {
        let code = UserDefaults.standard.string(forKey: "appLanguage") ?? "en"
        switch code {
        case "es": return "Spanish"
        case "it": return "Italian"
        case "de": return "German"
        case "fr": return "French"
        case "pt": return "Portuguese"
        default: return "English"
        }
    }

    static func compressImageForAI(_ image: UIImage, maxDimension: CGFloat = 1024, quality: CGFloat = 0.6) -> String? {
        return compressImageToTarget(image, maxDimension: maxDimension, quality: quality, maxBytes: 800_000)
    }

    static func compressImageSmall(_ image: UIImage) -> String? {
        return compressImageToTarget(image, maxDimension: 1024, quality: 0.6, maxBytes: 600_000)
    }

    private static func compressImageToTarget(_ image: UIImage, maxDimension: CGFloat, quality: CGFloat, maxBytes: Int) -> String? {
        let size = image.size
        let orientedImage = normalizeOrientation(image)
        var currentMaxDim = maxDimension
        var currentQuality = quality

        for attempt in 0..<10 {
            let scale = min(currentMaxDim / size.width, currentMaxDim / size.height, 1.0)
            let newSize = CGSize(width: floor(size.width * scale), height: floor(size.height * scale))
            let renderer = UIGraphicsImageRenderer(size: newSize)
            let resized = renderer.image { _ in orientedImage.draw(in: CGRect(origin: .zero, size: newSize)) }

            if let data = resized.jpegData(compressionQuality: currentQuality), data.count <= maxBytes {
                return data.base64EncodedString()
            }

            if attempt < 4 {
                currentQuality = max(currentQuality - 0.08, 0.25)
            } else {
                currentMaxDim *= 0.7
                currentQuality = max(currentQuality - 0.05, 0.2)
            }
        }

        let fallbackScale = min(512.0 / size.width, 512.0 / size.height, 1.0)
        let fallbackSize = CGSize(width: floor(size.width * fallbackScale), height: floor(size.height * fallbackScale))
        let fallbackRenderer = UIGraphicsImageRenderer(size: fallbackSize)
        let fallbackImage = fallbackRenderer.image { _ in orientedImage.draw(in: CGRect(origin: .zero, size: fallbackSize)) }
        return fallbackImage.jpegData(compressionQuality: 0.25)?.base64EncodedString()
    }

    private static func normalizeOrientation(_ image: UIImage) -> UIImage {
        guard image.imageOrientation != .up else { return image }
        let renderer = UIGraphicsImageRenderer(size: image.size)
        return renderer.image { _ in image.draw(at: .zero) }
    }

    static func analyzeCalories(imageBase64: String) async throws -> CalorieAnalysisResult {
        if useKimi {
            return try await analyzeCaloriesWithKimi(imageBase64: imageBase64)
        }
        guard !toolkitURL.isEmpty, let url = URL(string: toolkitURL + "/agent/chat") else {
            throw AIServiceError.networkError("AI service not configured.")
        }

        var lastError: Error?
        for attempt in 0..<3 {
            do {
                let result = try await performCalorieAnalysis(url: url, imageBase64: imageBase64)
                return result
            } catch {
                lastError = error
                if attempt < 2 {
                    try? await Task.sleep(for: .seconds(Double(attempt + 1) * 2.0))
                }
            }
        }
        throw lastError ?? AIServiceError.networkError("Analysis failed after multiple attempts.")
    }

    private static func performCalorieAnalysis(url: URL, imageBase64: String) async throws -> CalorieAnalysisResult {
        let step1Prompt = """
        You are a food recognition expert. Analyze this photo and identify EVERY visible food item.
        For each item, estimate the approximate portion size.
        Return ONLY a raw JSON object with this format:
        {"foods":[{"name":"Food name","portion":"estimated portion like 150g or 1 cup"}],"mealDescription":"Brief description of the overall meal"}
        Be specific. List each food item separately. If you see a plate with multiple items, list each one.
        """

        let step1Body = buildImageRequestBody(prompt: step1Prompt, imageBase64Strings: [imageBase64])
        let step1RawText = try await sendToolkitRequest(url: url, body: step1Body, timeout: 90)
        let step1JSON = extractFoodJSON(from: step1RawText)

        var foodList = step1JSON
        if let data = step1JSON.data(using: .utf8),
           let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let foods = obj["foods"] as? [[String: Any]] {
            foodList = foods.map { item in
                let n = item["name"] as? String ?? "Unknown"
                let p = item["portion"] as? String ?? "1 serving"
                return "\(n) (\(p))"
            }.joined(separator: ", ")
        }

        if foodList.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw AIServiceError.noContent
        }

        let exampleJSON = #"{"foodName":"Pasta al Pomodoro","calories":520,"protein":18.0,"carbs":82.0,"fat":12.0,"servingSize":"1 piatto ~350g","confidence":"High","notes":"Calories estimated based on visible portion size","ingredients":[{"name":"Pasta spaghetti","quantity":"180g","calories":285,"protein":10.0,"carbs":58.0,"fat":1.5}]}"#

        let step2Prompt = """
        You are a nutrition expert and calorie calculator. Based on the following identified foods from a meal photo, calculate the total calories and macronutrients.

        Identified foods: \(foodList)

        Calculate precise nutritional values for each ingredient and the total meal.
        Return ONLY raw JSON in this exact format:
        \(exampleJSON)

        Rules:
        - foodName: a concise name for the overall meal in \(aiLanguageName)
        - calories: total integer kcal for the entire meal
        - protein/carbs/fat: total decimal grams
        - servingSize: estimated total portion size
        - confidence: "High" if foods are clearly identifiable, "Medium" if some estimation, "Low" if very uncertain
        - notes: brief note about the estimation in \(aiLanguageName)
        - ingredients: array listing EACH food item separately with individual nutritional values
        - Be accurate — use standard nutritional databases as reference
        """

        let step2Body = buildTextRequestBody(prompt: step2Prompt)
        let step2RawText = try await sendToolkitRequest(url: url, body: step2Body, timeout: 90)
        let step2JSON = extractFoodJSON(from: step2RawText)
        let result = parseCalorieResult(from: step2JSON)
        if result.calories == 0 && result.foodName == "Detected Meal" {
            throw AIServiceError.decodingError
        }
        return result
    }

    static func lookupIngredientNutrition(name: String) async throws -> ScannedIngredient {
        if useKimi {
            return try await lookupIngredientNutritionWithKimi(name: name)
        }
        guard !toolkitURL.isEmpty, let url = URL(string: toolkitURL + "/agent/chat") else {
            return ScannedIngredient(name: name, quantity: "100g", calories: 0, protein: 0, carbs: 0, fat: 0)
        }

        let exampleIngredient = #"{"name":"Pechuga de pollo","quantity":"100g","calories":165,"protein":31.0,"carbs":0.0,"fat":3.6}"#

        let prompt = """
        You are a precise nutrition database. Return nutritional values for the food: "\(name)"

        Respond with ONLY a raw JSON object. No markdown, no explanation. Start with { end with }.
        Use this exact format:
        \(exampleIngredient)

        Rules:
        - Use 100g as default serving size
        - calories must be integer
        - protein, carbs, fat must be decimal numbers
        - name should be the clean ingredient name in \(aiLanguageName)
        - Return ONLY the JSON object, nothing else
        """

        let body = buildTextRequestBody(prompt: prompt)
        let rawText = try await sendToolkitRequest(url: url, body: body, timeout: 30)
        let jsonText = extractJSON(from: rawText)

        guard let jsonData = jsonText.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            return ScannedIngredient(name: name, quantity: "100g", calories: 0, protein: 0, carbs: 0, fat: 0)
        }

        let ingredientName = obj["name"] as? String ?? name
        let qty = obj["quantity"] as? String ?? "100g"
        let cal = (obj["calories"] as? Int) ?? Int((obj["calories"] as? Double) ?? 0)
        let p = (obj["protein"] as? Double) ?? Double((obj["protein"] as? Int) ?? 0)
        let cb = (obj["carbs"] as? Double) ?? Double((obj["carbs"] as? Int) ?? 0)
        let f = (obj["fat"] as? Double) ?? Double((obj["fat"] as? Int) ?? 0)

        return ScannedIngredient(name: ingredientName, quantity: qty, calories: cal, protein: p, carbs: cb, fat: f)
    }

    static func analyzeNutritionTable(imageBase64: String) async throws -> NutritionTableResult {
        if useKimi {
            return try await analyzeNutritionTableWithKimi(imageBase64: imageBase64)
        }
        guard !toolkitURL.isEmpty, let url = URL(string: toolkitURL + "/agent/chat") else {
            return NutritionTableResult(
                productName: "Product",
                servingSize: "100g",
                calories: 250,
                totalFat: 8,
                saturatedFat: 3,
                carbohydrates: 35,
                sugars: 12,
                protein: 10,
                salt: 0.5,
                fiber: 3
            )
        }

        let prompt = """
        Read this nutrition label. Return ONLY raw JSON:
        {"productName":"Name","servingSize":"100g","calories":250,"totalFat":8.0,"saturatedFat":3.0,"carbohydrates":35.0,"sugars":12.0,"protein":10.0,"salt":0.5,"fiber":3.0}
        Read exact values from label. Use 0 for missing values.
        """

        let body = buildImageRequestBody(prompt: prompt, imageBase64Strings: [imageBase64])
        let rawText = try await sendToolkitRequest(url: url, body: body, timeout: 90)
        let jsonText = extractJSON(from: rawText)

        guard let jsonData = jsonText.data(using: .utf8),
              let result = try? JSONDecoder().decode(NutritionTableResult.self, from: jsonData) else {
            return NutritionTableResult(
                productName: "Product",
                servingSize: "100g",
                calories: 250,
                totalFat: 8,
                saturatedFat: 3,
                carbohydrates: 35,
                sugars: 12,
                protein: 10,
                salt: 0.5,
                fiber: 3
            )
        }
        return result
    }

    static func analyzeFullBodyScan(frontBase64: String?, rightBase64: String?, backBase64: String?, leftBase64: String?, profile: UserProfile) async throws -> BodyScan2Result {
        if useKimi {
            return try await analyzeFullBodyScanWithKimi(frontBase64: frontBase64, rightBase64: rightBase64, backBase64: backBase64, leftBase64: leftBase64, profile: profile)
        }
        guard !toolkitURL.isEmpty, let url = URL(string: toolkitURL + "/agent/chat") else {
            return BodyScan2Result.fallback()
        }

        let profileInfo = "Gender: \(profile.gender.rawValue), Age: \(profile.age), Height: \(Int(profile.heightCm))cm, Weight: \(Int(profile.currentWeightKg))kg, Goal: \(profile.goal.rawValue), Activity: \(profile.activityLevel.rawValue), DailyCalorieTarget: \(Int(profile.dailyCalorieTarget))kcal"

        let prompt = """
        You are an expert fitness coach, nutritionist, and body composition analyst with deep expertise in visual body assessment.
        Analyze these 360° body scan photos (front, right side, back, left side) taken with the front camera.
        User profile: \(profileInfo)

        IMPORTANT: The user's daily calorie target is \(Int(profile.dailyCalorieTarget)) kcal. You MUST use this exact value for dailyCalories in your response. Do NOT calculate or estimate a different calorie target — use the one provided.

        CRITICAL ANALYSIS INSTRUCTIONS:
        You MUST perform a DETAILED analysis of EVERY body region. Do NOT skip or give generic assessments. Analyze each region carefully from all 4 photos:
        - SHOULDERS & ARMS: Look at deltoid development, biceps/triceps definition, arm fat, symmetry between left and right
        - CHEST: Pectoral development, symmetry, fat accumulation around chest area
        - ABDOMEN: Core definition, visceral fat, bloating signs, love handles, oblique development
        - BACK: Lat width, trap development, lower back definition, fat folds, posture from behind
        - GLUTES: Gluteal muscle development, shape, firmness, fat distribution around hips and buttocks. THIS IS CRITICAL — analyze glute shape, volume, tone, and whether they need more development or toning
        - UPPER LEGS (Quadriceps/Hamstrings): Thigh muscle definition, fat around inner thighs, quadricep separation, hamstring visibility from the back, cellulite, overall leg shape and proportion
        - LOWER LEGS (Calves): Calf muscle development, ankle definition, overall proportion to upper legs

        For EACH body region, you must assess:
        1. Muscle definition level (how visible are the muscles)
        2. Fat distribution (where fat accumulates in that region)
        3. Bloating/water retention signs specific to that area
        4. A score from 1 to 10 (1=needs major work, 10=excellent)
        5. Specific notes about what you observe
        6. 1-3 improvement tips specific to that region

        Also provide:
        - fatDistributionSummary: A detailed description of WHERE fat is stored on the body
        - bloatingAreas: List of specific body areas showing signs of bloating/water retention
        - strongPoints: 5-7 specific strengths observed (be VERY specific, reference exact body parts)
        - weakPoints: 5-7 specific weak points (be VERY specific, mention exact muscles/areas that need work)

        Return ONLY raw JSON:
        {"somatotype":"Mesomorph","estimatedBodyFat":"19-20%","biologicalAge":"25","muscleDefinition":"Moderate","bloatingPercentage":"10-15%","skinTexture":"Normal, well hydrated","strongPoints":["Well-developed deltoids with good roundness","Proportioned quadriceps with visible separation"],"weakPoints":["Undefined lower abdomen with visible fat accumulation","Gluteal muscles lack volume and firmness","Inner thighs show excess fat"],"overallAssessment":"Detailed assessment in \(aiLanguageName)","posturalNotes":"Postural notes in \(aiLanguageName)","fatDistributionSummary":"Detailed fat distribution description in \(aiLanguageName)","bloatingAreas":["Lower abdomen","Ankles"],"bodyRegions":[{"region":"Shoulders & Arms","muscleDefinition":"Good deltoid development","fatDistribution":"Minimal fat on arms","bloating":"None","score":7,"notes":"Notes","improvementTips":["Tip 1"]},{"region":"Chest","muscleDefinition":"Moderate","fatDistribution":"Light fat layer","bloating":"None","score":6,"notes":"Notes","improvementTips":["Tip"]},{"region":"Abdomen","muscleDefinition":"Low","fatDistribution":"Concentrated in lower abs","bloating":"Moderate","score":4,"notes":"Notes","improvementTips":["Tip"]},{"region":"Back","muscleDefinition":"Moderate","fatDistribution":"Light","bloating":"None","score":6,"notes":"Notes","improvementTips":["Tip"]},{"region":"Glutes","muscleDefinition":"Needs development","fatDistribution":"Moderate around hips","bloating":"None","score":5,"notes":"Notes","improvementTips":["Hip thrusts"]},{"region":"Upper Legs","muscleDefinition":"Moderate","fatDistribution":"Inner thigh fat","bloating":"Minimal","score":6,"notes":"Notes","improvementTips":["Tip"]},{"region":"Lower Legs","muscleDefinition":"Well developed","fatDistribution":"Minimal","bloating":"None","score":7,"notes":"Notes","improvementTips":["Tip"]}],"dailyCalories":\(Int(profile.dailyCalorieTarget)),"proteinGrams":\(Int(profile.proteinTarget)),"carbsGrams":\(Int(profile.carbsTarget)),"fatGrams":\(Int(profile.fatTarget)),"nutritionRecommendations":["Rec 1 in \(aiLanguageName)","Rec 2"],"sampleMeals":[{"name":"Protein breakfast","type":"breakfast","calories":450,"description":"Description in \(aiLanguageName)"}],"trainingDaysPerWeek":4,"trainingSplit":"Upper/Lower Split","focusAreas":["Chest","Legs"],"sampleExercises":[{"name":"Bench Press","sets":4,"reps":"8-10","muscleGroup":"Chest"}],"trainingRecommendations":["Rec 1 in \(aiLanguageName)"]}

        Rules:
        - somatotype: Ectomorph, Mesomorph, or Endomorph
        - estimatedBodyFat: percentage range string with MAXIMUM 2 percentage points difference (e.g. "18-19%", "21-22%", "15-16%"). NEVER use wider ranges like "18-22%" or "15-18%"
        - biologicalAge: estimated biological age as string
        - muscleDefinition: overall level in \(aiLanguageName)
        - bloatingPercentage: estimated overall bloating/water retention percentage range string
        - skinTexture: skin quality description in \(aiLanguageName)
        - bodyRegions: MANDATORY array of EXACTLY 7 regions: "Shoulders & Arms", "Chest", "Abdomen", "Back", "Glutes", "Upper Legs", "Lower Legs". Each with muscleDefinition, fatDistribution, bloating, score (1-10), notes, and improvementTips array
        - fatDistributionSummary: detailed description of WHERE fat is stored across the body, in \(aiLanguageName)
        - bloatingAreas: array of specific body areas showing bloating signs, in \(aiLanguageName)
        - strongPoints: array of 5-7 VERY SPECIFIC physical strong points observed in the photos, in \(aiLanguageName)
        - weakPoints: array of 5-7 VERY SPECIFIC physical weak points/areas to improve observed in the photos, in \(aiLanguageName)
        - dailyCalories: MUST be exactly \(Int(profile.dailyCalorieTarget)) — use the user's configured calorie target, do NOT override it
        - proteinGrams/carbsGrams/fatGrams: integers calculated proportionally from dailyCalories
        - sampleMeals: at least 4 meals (breakfast, lunch, dinner, snack) with type being breakfast/lunch/dinner/snack. Total calories must add up close to \(Int(profile.dailyCalorieTarget))
        - sampleExercises: at least 5 exercises targeting weak areas
        - focusAreas: body areas that need the most work based on the photos
        - All text fields in \(aiLanguageName)
        - Be EXTREMELY specific and personalized based on what you ACTUALLY see in the photos. Do NOT give generic assessments.
        - PAY SPECIAL ATTENTION to legs and glutes — these are often overlooked. Describe their shape, tone, fat distribution, and muscle development in detail.
        """

        var images: [String] = []
        if let front = frontBase64 { images.append(front) }
        if let right = rightBase64 { images.append(right) }
        if let back = backBase64 { images.append(back) }
        if let left = leftBase64 { images.append(left) }

        let body = buildImageRequestBody(prompt: prompt, imageBase64Strings: images)
        let rawText = try await sendToolkitRequest(url: url, body: body, timeout: 180)
        let jsonText = extractJSON(from: rawText)

        guard let jsonData = jsonText.data(using: .utf8),
              let result = try? JSONDecoder().decode(BodyScan2Result.self, from: jsonData) else {
            return BodyScan2Result.fallback()
        }
        return result
    }

    static func generateMealPlan(for profile: UserProfile, quizPreferences: MealPlanQuizPreferences? = nil) async throws -> NutritionPlan {
        if useKimi {
            return try await generateMealPlanWithKimi(for: profile, quizPreferences: quizPreferences)
        }
        var dietInfo = profile.dietType.rawValue
        var intolerancesInfo = ""
        var fastingInfo = ""
        var mealsInfo = "Include breakfast, lunch, and dinner for each day."
        var cookingInfo = ""
        var cheatMealInfo = ""

        if let quiz = quizPreferences {
            if !quiz.dietType.isEmpty {
                dietInfo = quiz.dietType
            }
            if !quiz.intolerances.isEmpty || !quiz.customIntolerances.isEmpty {
                var allIntolerances = quiz.intolerances
                if !quiz.customIntolerances.isEmpty {
                    allIntolerances.append(quiz.customIntolerances)
                }
                intolerancesInfo = "\n        - Food intolerances/allergies: \(allIntolerances.joined(separator: ", ")). NEVER include these foods or derivatives."
            }
            let totalKcal = Int(profile.dailyCalorieTarget)
            if quiz.wantsFasting {
                let window = quiz.fastingWindow == .skipBreakfast ? "12:00-20:00 (skip breakfast)" : "08:00-16:00 (skip dinner)"
                fastingInfo = "\n        - Intermittent fasting: 16/8 protocol, eating window \(window)"
                switch quiz.mealsCount {
                case 1:
                    if quiz.fastingWindow == .skipBreakfast {
                        mealsInfo = "Include exactly 1 meal per day: lunch (\(totalKcal) kcal). All daily calories in this single meal."
                    } else {
                        mealsInfo = "Include exactly 1 meal per day: breakfast (\(totalKcal) kcal). All daily calories in this single meal."
                    }
                case 2:
                    let perMeal = totalKcal / 2
                    if quiz.fastingWindow == .skipBreakfast {
                        mealsInfo = "Include exactly 2 meals per day: lunch (\(perMeal) kcal) and dinner (\(perMeal) kcal). Split calories equally between the two main meals."
                    } else {
                        mealsInfo = "Include exactly 2 meals per day: breakfast (\(perMeal) kcal) and lunch (\(perMeal) kcal). Split calories equally between the two main meals."
                    }
                case 3:
                    let mainKcal = Int(Double(totalKcal) * 0.4)
                    let snackKcal = totalKcal - mainKcal * 2
                    if quiz.fastingWindow == .skipBreakfast {
                        mealsInfo = "Include exactly 3 meals per day in this order: lunch (\(mainKcal) kcal), snack (\(snackKcal) kcal), dinner (\(mainKcal) kcal). The snack is between lunch and dinner and has fewer calories than the main meals."
                    } else {
                        mealsInfo = "Include exactly 3 meals per day in this order: breakfast (\(mainKcal) kcal), snack (\(snackKcal) kcal), lunch (\(mainKcal) kcal). The snack is between breakfast and lunch and has fewer calories than the main meals."
                    }
                case 4:
                    let mainKcal = Int(Double(totalKcal) * 0.35)
                    let snackKcal = (totalKcal - mainKcal * 2) / 2
                    if quiz.fastingWindow == .skipBreakfast {
                        mealsInfo = "Include exactly 4 meals per day in this order: lunch (\(mainKcal) kcal), snack (\(snackKcal) kcal), dinner (\(mainKcal) kcal), snack (\(snackKcal) kcal). Snacks have fewer calories than main meals. The first snack is between lunch and dinner, the second snack is after dinner."
                    } else {
                        mealsInfo = "Include exactly 4 meals per day in this order: breakfast (\(mainKcal) kcal), snack (\(snackKcal) kcal), lunch (\(mainKcal) kcal), snack (\(snackKcal) kcal). Snacks have fewer calories than main meals. The first snack is between breakfast and lunch, the second snack is after lunch."
                    }
                default:
                    let perMeal = totalKcal / 2
                    if quiz.fastingWindow == .skipBreakfast {
                        mealsInfo = "Include exactly 2 meals per day: lunch (\(perMeal) kcal) and dinner (\(perMeal) kcal)."
                    } else {
                        mealsInfo = "Include exactly 2 meals per day: breakfast (\(perMeal) kcal) and lunch (\(perMeal) kcal)."
                    }
                }
            } else {
                switch quiz.mealsCount {
                case 1:
                    mealsInfo = "Include exactly 1 meal per day: lunch (\(totalKcal) kcal). All daily calories in this single meal."
                case 2:
                    let perMeal = totalKcal / 2
                    mealsInfo = "Include exactly 2 meals per day: lunch (\(perMeal) kcal) and dinner (\(perMeal) kcal). Split calories equally between the two main meals."
                case 3:
                    let perMeal = totalKcal / 3
                    mealsInfo = "Include exactly 3 meals per day: breakfast (\(perMeal) kcal), lunch (\(perMeal) kcal), and dinner (\(perMeal) kcal). Three main meals with roughly equal calories."
                case 4:
                    let mainKcal = Int(Double(totalKcal) * 0.3)
                    let snackKcal = totalKcal - mainKcal * 3
                    mealsInfo = "Include exactly 4 meals per day in this order: breakfast (\(mainKcal) kcal), lunch (\(mainKcal) kcal), snack (\(snackKcal) kcal), dinner (\(mainKcal) kcal). The snack is between lunch and dinner (afternoon snack) and has fewer calories than the main meals."
                case 5:
                    let mainKcal = Int(Double(totalKcal) * 0.27)
                    let snackKcal = (totalKcal - mainKcal * 3) / 2
                    mealsInfo = "Include exactly 5 meals per day in this order: breakfast (\(mainKcal) kcal), snack (\(snackKcal) kcal), lunch (\(mainKcal) kcal), snack (\(snackKcal) kcal), dinner (\(mainKcal) kcal). Snacks are between breakfast-lunch and lunch-dinner, and have fewer calories than the main meals."
                case 6:
                    let mainKcal = Int(Double(totalKcal) * 0.25)
                    let snackKcal = (totalKcal - mainKcal * 3) / 3
                    mealsInfo = "Include exactly 6 meals per day in this order: breakfast (\(mainKcal) kcal), snack (\(snackKcal) kcal), lunch (\(mainKcal) kcal), snack (\(snackKcal) kcal), dinner (\(mainKcal) kcal), evening snack (\(snackKcal) kcal). Snacks have fewer calories than main meals. Evening snack is after dinner."
                case 7:
                    let mainKcal = Int(Double(totalKcal) * 0.23)
                    let snackKcal = (totalKcal - mainKcal * 3) / 4
                    mealsInfo = "Include exactly 7 meals per day in this order: breakfast (\(mainKcal) kcal), snack (\(snackKcal) kcal), lunch (\(mainKcal) kcal), snack (\(snackKcal) kcal), dinner (\(mainKcal) kcal), evening snack (\(snackKcal) kcal), late snack (\(snackKcal) kcal). Snacks have fewer calories than main meals. Evening snack is after dinner, late snack is before bed."
                default:
                    let perMeal = totalKcal / 3
                    mealsInfo = "Include exactly 3 meals per day: breakfast (\(perMeal) kcal), lunch (\(perMeal) kcal), and dinner (\(perMeal) kcal)."
                }
            }
            switch quiz.cookingTime {
            case .quick: cookingInfo = "\n        - Cooking time: Quick recipes only (10-20 minutes max prep time)"
            case .moderate: cookingInfo = "\n        - Cooking time: Moderate recipes (20-30 minutes prep time)"
            case .relaxed: cookingInfo = "\n        - Cooking time: Can include elaborate recipes (30+ minutes)"
            }
            if let cheat = quiz.cheatMeal {
                let dayMap = ["Mon": "Monday", "Tue": "Tuesday", "Wed": "Wednesday", "Thu": "Thursday", "Fri": "Friday", "Sat": "Saturday", "Sun": "Sunday"]
                let fullDay = dayMap[cheat.day] ?? cheat.day
                cheatMealInfo = "\n        - Free meal: On \(fullDay) \(cheat.mealType.lowercased()), DO NOT generate any meal. Instead put a placeholder meal with name \"Pasto Libero\", calories 0, protein 0, carbs 0, fat 0, prepTime 0, difficulty Easy, empty ingredients array. This is a free meal slot where the user eats whatever they want."
            }
        }

        let prompt = """
        Generate a 7-day meal plan. Return ONLY valid JSON, no markdown.
        Profile: Goal=\(profile.goal.rawValue), Diet=\(dietInfo), \(Int(profile.dailyCalorieTarget))kcal/day, Protein=\(Int(profile.proteinTarget))g, \(profile.gender.rawValue), \(Int(profile.currentWeightKg))kg→\(Int(profile.targetWeightKg))kg\(intolerancesInfo)\(fastingInfo)\(cookingInfo)\(cheatMealInfo)
        \(mealsInfo)
        IMPORTANT: Each day MUST have DIFFERENT meals. Never repeat the same dish on multiple days. Vary dishes, ingredients, cuisines and cooking styles across the 7 days. Even similar meal types (e.g. two breakfasts) must feature completely different foods. Slight natural variations in macros between days (+/- 5-15%) are encouraged for nutritional diversity.
        JSON format: {"days":[{"dayName":"Monday","meals":[{"type":"breakfast","name":"Name","calories":500,"protein":30.0,"carbs":45.0,"fat":20.0,"prepTime":15,"difficulty":"Easy","ingredients":[{"name":"Ing","amount":100.0,"unit":"g","calories":100}]}]}]}
        type must be one of: breakfast, lunch, dinner, snack. difficulty: Easy, Medium, Hard.
        CRITICAL CALORIE RULE: The sum of ALL meal calories for each day MUST equal EXACTLY \(Int(profile.dailyCalorieTarget)) kcal. Not approximately, not close — EXACTLY \(Int(profile.dailyCalorieTarget)). Adjust portion sizes to hit this number precisely. Before outputting, verify that the sum of calories of all meals for each day equals \(Int(profile.dailyCalorieTarget)).
        7 days Monday-Sunday. Do NOT include imageURL field. All meal names and ingredient names in \(aiLanguageName).
        """

        guard !toolkitURL.isEmpty else {
            return DefaultData.nutritionPlan(for: profile)
        }

        guard let url = URL(string: toolkitURL + "/agent/chat") else {
            return DefaultData.nutritionPlan(for: profile)
        }

        let body = buildTextRequestBody(prompt: prompt)

        let targetKcal = Int(profile.dailyCalorieTarget)
        var lastError: Error?
        for attempt in 0..<3 {
            do {
                let rawText = try await sendToolkitRequest(url: url, body: body, timeout: 180)
                lastError = nil
                let jsonText = extractJSON(from: rawText)
                if let plan = parseMealPlanJSON(jsonText) {
                    return normalizePlanCalories(plan, target: targetKcal)
                }
            } catch {
                lastError = error
            }
            if attempt < 2 {
                try? await Task.sleep(for: .seconds(Double(attempt + 1) * 2.0))
            }
        }

        if let err = lastError {
            throw err
        }
        return DefaultData.nutritionPlan(for: profile)
    }

    static func parseMealPlanJSON(_ jsonText: String) -> NutritionPlan? {
        guard let jsonData = jsonText.data(using: .utf8) else { return nil }

        if let decoded = try? JSONDecoder().decode(NutritionPlanResponse.self, from: jsonData),
           !decoded.days.isEmpty {
            let normalizedDays = decoded.days.map { day in
                let processedMeals = day.meals.map { meal -> Meal in
                    let isFreeMeal = meal.name.lowercased().contains("pasto libero") || meal.name.lowercased().contains("free meal") || meal.name.lowercased().contains("comida libre") || meal.name.lowercased().contains("repas libre")
                    if isFreeMeal {
                        return Meal(type: meal.type, name: meal.name, calories: 0, protein: 0, carbs: 0, fat: 0, prepTime: 0, difficulty: .easy, ingredients: [], isCheatMeal: true)
                    }
                    return meal
                }
                return DayPlan(id: day.id, dayName: DayNameNormalizer.normalize(day.dayName), meals: processedMeals)
            }
            return NutritionPlan(days: normalizedDays)
        }

        guard let obj = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
              let daysArr = obj["days"] as? [[String: Any]] else { return nil }

        var days: [DayPlan] = []
        for dayObj in daysArr {
            guard let dayName = dayObj["dayName"] as? String,
                  let mealsArr = dayObj["meals"] as? [[String: Any]] else { continue }
            var meals: [Meal] = []
            for mealObj in mealsArr {
                let typeRaw = (mealObj["type"] as? String ?? "snack").lowercased()
                let mealType: Meal.MealType
                if typeRaw.contains("breakfast") || typeRaw.contains("colazione") {
                    mealType = .breakfast
                } else if typeRaw.contains("lunch") || typeRaw.contains("pranzo") {
                    mealType = .lunch
                } else if typeRaw.contains("dinner") || typeRaw.contains("cena") {
                    mealType = .dinner
                } else {
                    mealType = .snack
                }
                let name = mealObj["name"] as? String ?? "Meal"
                let calories = (mealObj["calories"] as? Int) ?? Int((mealObj["calories"] as? Double) ?? 0)
                let protein = (mealObj["protein"] as? Double) ?? Double((mealObj["protein"] as? Int) ?? 0)
                let carbs = (mealObj["carbs"] as? Double) ?? Double((mealObj["carbs"] as? Int) ?? 0)
                let fat = (mealObj["fat"] as? Double) ?? Double((mealObj["fat"] as? Int) ?? 0)
                let prepTime = (mealObj["prepTime"] as? Int) ?? Int((mealObj["prepTime"] as? Double) ?? 15)
                let diffRaw = (mealObj["difficulty"] as? String ?? "Easy").lowercased()
                let difficulty: Meal.Difficulty = diffRaw.contains("hard") ? .hard : diffRaw.contains("med") ? .medium : .easy
                let imageURL = mealObj["imageURL"] as? String

                var ingredients: [Ingredient] = []
                if let ingsArr = mealObj["ingredients"] as? [[String: Any]] {
                    for ingObj in ingsArr {
                        let ingName = ingObj["name"] as? String ?? "Ingredient"
                        let amount = (ingObj["amount"] as? Double) ?? Double((ingObj["amount"] as? Int) ?? 100)
                        let unit = ingObj["unit"] as? String ?? "g"
                        let ingCal = (ingObj["calories"] as? Int) ?? Int((ingObj["calories"] as? Double) ?? 0)
                        ingredients.append(Ingredient(name: ingName, amount: amount, unit: unit, calories: ingCal))
                    }
                }

                let isFreeMeal = name.lowercased().contains("pasto libero") || name.lowercased().contains("free meal") || name.lowercased().contains("comida libre") || name.lowercased().contains("repas libre")
                meals.append(Meal(
                    type: mealType, name: name, calories: isFreeMeal ? 0 : calories,
                    protein: isFreeMeal ? 0 : protein, carbs: isFreeMeal ? 0 : carbs, fat: isFreeMeal ? 0 : fat,
                    prepTime: isFreeMeal ? 0 : prepTime, difficulty: difficulty,
                    ingredients: isFreeMeal ? [] : ingredients, imageURL: isFreeMeal ? nil : imageURL,
                    isCheatMeal: isFreeMeal
                ))
            }
            if !meals.isEmpty {
                days.append(DayPlan(dayName: DayNameNormalizer.normalize(dayName), meals: meals))
            }
        }

        guard !days.isEmpty else { return nil }
        return NutritionPlan(days: days)
    }

    static func normalizeDayCalories(_ day: DayPlan, target: Int) -> DayPlan {
        let nonCheatMeals = day.meals.filter { !$0.isCheatMeal }
        let currentTotal = nonCheatMeals.reduce(0) { $0 + $1.calories }
        guard currentTotal > 0, target > 0, abs(currentTotal - target) > 5 else { return day }
        let factor = Double(target) / Double(currentTotal)
        var adjustedMeals = day.meals.map { meal -> Meal in
            guard !meal.isCheatMeal, meal.calories > 0 else { return meal }
            var m = meal
            m.calories = max(1, Int(round(Double(meal.calories) * factor)))
            m.protein = max(0, round(meal.protein * factor * 10) / 10)
            m.carbs = max(0, round(meal.carbs * factor * 10) / 10)
            m.fat = max(0, round(meal.fat * factor * 10) / 10)
            m.ingredients = meal.ingredients.map { ing in
                var i = ing
                i.calories = max(0, Int(round(Double(ing.calories) * factor)))
                i.amount = max(0, round(ing.amount * factor * 10) / 10)
                return i
            }
            return m
        }
        let newTotal = adjustedMeals.filter({ !$0.isCheatMeal }).reduce(0) { $0 + $1.calories }
        let diff = target - newTotal
        if diff != 0, let idx = adjustedMeals.firstIndex(where: { !$0.isCheatMeal && $0.calories > 0 }) {
            adjustedMeals[idx].calories += diff
        }
        return DayPlan(id: day.id, dayName: day.dayName, meals: adjustedMeals)
    }

    static func normalizePlanCalories(_ plan: NutritionPlan, target: Int) -> NutritionPlan {
        let normalizedDays = plan.days.map { normalizeDayCalories($0, target: target) }
        return NutritionPlan(days: normalizedDays, createdAt: plan.createdAt)
    }

    static func generateWorkoutPlan(for profile: UserProfile, workoutQuizPreferences: WorkoutQuizPreferences? = nil) async throws -> WorkoutPlan {
        if useKimi {
            return try await generateWorkoutPlanWithKimi(for: profile, workoutQuizPreferences: workoutQuizPreferences)
        }
        guard !toolkitURL.isEmpty, let url = URL(string: toolkitURL + "/agent/chat") else {
            return WorkoutLocalization.localizePlan(DefaultData.workoutPlan(for: profile))
        }

        var sportInfo = ""
        var goalInfo = profile.goal.rawValue
        var specificData = ""
        var extraInfo = ""

        if let quiz = workoutQuizPreferences {
            if !quiz.fitnessGoal.isEmpty {
                goalInfo = quiz.fitnessGoal
            }
            if quiz.isPerformance == true, !quiz.selectedSport.isEmpty {
                sportInfo = "\n        - Training style: \(quiz.selectedSport) (performance-oriented)"
                if !quiz.sportAnswers.isEmpty {
                    let answers = quiz.sportAnswers.map { "\($0.key): \($0.value)" }.joined(separator: ", ")
                    specificData = "\n        - Sport-specific data: \(answers)"
                }
            } else if quiz.isPerformance == false {
                sportInfo = "\n        - Training approach: General wellness (not sport-specific)"
            }

            if !quiz.trainingFrequency.isEmpty {
                extraInfo += "\n        - Current training frequency: \(quiz.trainingFrequency)"
            }
            if !quiz.strengthLevel.isEmpty {
                extraInfo += "\n        - Strength level: \(quiz.strengthLevel)"
            }
            if quiz.daysPerWeek > 0 {
                extraInfo += "\n        - Desired training days per week: \(quiz.daysPerWeek)"
            }
            if !quiz.preferredDays.isEmpty {
                extraInfo += "\n        - Preferred days: \(quiz.preferredDays.joined(separator: ", "))"
            }
            if !quiz.sessionDuration.isEmpty {
                extraInfo += "\n        - Session duration: \(quiz.sessionDuration) minutes"
            }
            if !quiz.trainingLocation.isEmpty {
                extraInfo += "\n        - Training location: \(quiz.trainingLocation)"
            }
            if !quiz.equipmentCategory.isEmpty {
                extraInfo += "\n        - Equipment available: \(quiz.equipmentCategory)"
            }
            if !quiz.jointPain.isEmpty {
                let painStr = quiz.jointPain.joined(separator: ", ")
                extraInfo += "\n        - Joint pain/limitations: \(painStr). AVOID exercises that stress these areas."
            }
        }

        let daysCount = workoutQuizPreferences?.daysPerWeek ?? 7
        let preferredDaysList = workoutQuizPreferences?.preferredDays ?? ["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"]
        let durationMin = Int(workoutQuizPreferences?.sessionDuration ?? "45") ?? 45

        let prompt = """
        Generate a 7-day workout plan. Return ONLY valid JSON, no markdown.
        Profile: Goal=\(goalInfo), \(profile.gender.rawValue), \(Int(profile.currentWeightKg))kg, Age=\(profile.age)\(sportInfo)\(specificData)\(extraInfo)
        JSON format: {"days":[{"dayName":"Monday","focus":"Chest & Triceps","durationMinutes":60,"isRestDay":false,"caloriesBurned":350,"exercises":[{"name":"Bench Press","sets":4,"reps":"8-10","restSeconds":90,"muscleGroups":["Chest","Triceps"],"category":"main","difficulty":"Intermediate","exerciseDescription":"Flat barbell bench press","formTips":["Keep shoulder blades retracted"],"durationMinutes":0}]}]}
        category must be: warmup, main, or cooldown. Include 1-2 warmup, 4-6 main, 1-2 cooldown exercises per day.
        7 days Monday-Sunday. The user wants to train \(daysCount) days. Make the other days rest days (isRestDay=true, minimal exercises). Preferred training days: \(preferredDaysList.joined(separator: ", ")). Target session duration: ~\(durationMin) min. Adapt exercises to the goal, location, equipment, and sport style. If joint pain is specified, strictly avoid exercises that stress those joints.
        """

        let body = buildTextRequestBody(prompt: prompt)

        var lastError: Error?
        for attempt in 0..<3 {
            do {
                let rawText = try await sendToolkitRequest(url: url, body: body, timeout: 180)
                lastError = nil
                let jsonText = extractJSON(from: rawText)
                if let plan = parseWorkoutPlanJSON(jsonText) {
                    return plan
                }
            } catch {
                lastError = error
            }
            if attempt < 2 {
                try? await Task.sleep(for: .seconds(Double(attempt + 1) * 2.0))
            }
        }

        if let err = lastError {
            throw err
        }
        return WorkoutLocalization.localizePlan(DefaultData.workoutPlan(for: profile))
    }

    static func ensureTrainingDayCount(_ plan: WorkoutPlan, expected: Int) -> WorkoutPlan {
        let weekdays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
        var trainingDays = plan.days.filter { !$0.isRestDay }
        let restDays = plan.days.filter { $0.isRestDay }

        if trainingDays.count == expected { return plan }

        while trainingDays.count < expected {
            if let template = trainingDays.last {
                var newDay = template
                newDay.id = UUID()
                let usedNames = Set(trainingDays.map { $0.dayName })
                let availableName = weekdays.first { !usedNames.contains($0) } ?? "Day \(trainingDays.count + 1)"
                newDay.dayName = availableName
                trainingDays.append(newDay)
            } else {
                break
            }
        }

        if trainingDays.count > expected {
            trainingDays = Array(trainingDays.prefix(expected))
        }

        let trainingDayNames = Set(trainingDays.map { $0.dayName })
        var allDays: [WorkoutDay] = []
        for dayName in weekdays {
            if let training = trainingDays.first(where: { $0.dayName == dayName }) {
                allDays.append(training)
            } else {
                if let existing = restDays.first(where: { $0.dayName == dayName }) {
                    allDays.append(existing)
                } else {
                    allDays.append(WorkoutDay(
                        dayName: dayName, focus: "Rest & Recovery",
                        durationMinutes: 0, exercises: [], isRestDay: true, caloriesBurned: 0
                    ))
                }
            }
        }
        return WorkoutPlan(days: allDays, createdAt: plan.createdAt)
    }

    static func parseWorkoutPlanJSON(_ jsonText: String) -> WorkoutPlan? {
        guard let jsonData = jsonText.data(using: .utf8) else { return nil }

        guard let obj = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
              let daysArr = obj["days"] as? [[String: Any]] else { return nil }

        var days: [WorkoutDay] = []
        for dayObj in daysArr {
            guard let dayName = dayObj["dayName"] as? String else { continue }
            let focus = dayObj["focus"] as? String ?? ""
            let duration = (dayObj["durationMinutes"] as? Int) ?? Int((dayObj["durationMinutes"] as? Double) ?? 45)
            let isRest = dayObj["isRestDay"] as? Bool ?? false
            let cals = (dayObj["caloriesBurned"] as? Int) ?? Int((dayObj["caloriesBurned"] as? Double) ?? 300)

            var exercises: [Exercise] = []
            if let exArr = dayObj["exercises"] as? [[String: Any]] {
                for exObj in exArr {
                    let name = exObj["name"] as? String ?? "Exercise"
                    let sets = (exObj["sets"] as? Int) ?? Int((exObj["sets"] as? Double) ?? 3)
                    let reps = exObj["reps"] as? String ?? "10"
                    let rest = (exObj["restSeconds"] as? Int) ?? Int((exObj["restSeconds"] as? Double) ?? 60)
                    let muscles = exObj["muscleGroups"] as? [String] ?? []
                    let catRaw = (exObj["category"] as? String ?? "main").lowercased()
                    let cat: ExerciseCategory = catRaw.contains("warm") ? .warmup : catRaw.contains("cool") ? .cooldown : .main
                    let diff = exObj["difficulty"] as? String ?? ""
                    let desc = exObj["exerciseDescription"] as? String ?? ""
                    let tips = exObj["formTips"] as? [String] ?? []
                    let loadTips = exObj["loadTips"] as? [String] ?? []
                    let durMin = (exObj["durationMinutes"] as? Int) ?? Int((exObj["durationMinutes"] as? Double) ?? 0)

                    exercises.append(Exercise(
                        name: name, sets: sets, reps: reps, restSeconds: rest,
                        muscleGroups: muscles, category: cat, difficulty: diff,
                        exerciseDescription: desc, formTips: tips, loadTips: loadTips,
                        durationMinutes: durMin
                    ))
                }
            }

            days.append(WorkoutDay(
                dayName: dayName, focus: focus, durationMinutes: duration,
                exercises: exercises, isRestDay: isRest, caloriesBurned: cals
            ))
        }

        guard !days.isEmpty else { return nil }
        return WorkoutPlan(days: days)
    }

    static func generateScanBasedMealPlan(scanResult: BodyScan2Result, profile: UserProfile, quizPreferences: MealPlanQuizPreferences? = nil) async throws -> NutritionPlan {
        if useKimi {
            return try await generateScanBasedMealPlanWithKimi(scanResult: scanResult, profile: profile, quizPreferences: quizPreferences)
        }
        guard !toolkitURL.isEmpty, let url = URL(string: toolkitURL + "/agent/chat") else {
            return DefaultData.nutritionPlan(for: profile)
        }

        var dietInfo = profile.dietType.rawValue
        var intolerancesInfo = ""
        if let quiz = quizPreferences {
            if !quiz.dietType.isEmpty { dietInfo = quiz.dietType }
            if !quiz.intolerances.isEmpty || !quiz.customIntolerances.isEmpty {
                var allIntolerances = quiz.intolerances
                if !quiz.customIntolerances.isEmpty { allIntolerances.append(quiz.customIntolerances) }
                intolerancesInfo = " Intolerances: \(allIntolerances.joined(separator: ", "))."
            }
        }

        let bodyContext = "Body scan results: Somatotype=\(scanResult.somatotype), BodyFat=\(scanResult.estimatedBodyFat), BiologicalAge=\(scanResult.biologicalAge), MuscleDefinition=\(scanResult.muscleDefinition), Bloating=\(scanResult.bloatingPercentage), WeakPoints=\(scanResult.weakPoints.joined(separator: ", ")), StrongPoints=\(scanResult.strongPoints.joined(separator: ", ")), FocusAreas=\(scanResult.focusAreas.joined(separator: ", "))"

        let prompt = """
        Generate a 7-day meal plan PERSONALIZED based on body scan analysis. Return ONLY valid JSON, no markdown.
        Profile: Goal=\(profile.goal.rawValue), Diet=\(dietInfo), \(Int(profile.dailyCalorieTarget))kcal/day, Protein=\(Int(profile.proteinTarget))g, \(profile.gender.rawValue), \(Int(profile.currentWeightKg))kg→\(Int(profile.targetWeightKg))kg\(intolerancesInfo)
        \(bodyContext)
        IMPORTANT: Adapt the nutrition plan specifically to address the weak points and body composition findings from the scan. If body fat is high, prioritize deficit. If muscle definition is low, increase protein. If bloating is high, reduce sodium and inflammatory foods.
        IMPORTANT: Each day MUST have DIFFERENT meals. Never repeat the same dish on multiple days. Vary dishes, ingredients, cuisines and cooking styles across the 7 days. Slight natural variations in macros between days (+/- 5-15%) are encouraged.
        Include breakfast, lunch, dinner, and 1-2 snacks per day.
        JSON format: {"days":[{"dayName":"Monday","meals":[{"type":"breakfast","name":"Name","calories":500,"protein":30.0,"carbs":45.0,"fat":20.0,"prepTime":15,"difficulty":"Easy","ingredients":[{"name":"Ing","amount":100.0,"unit":"g","calories":100}]}]}]}
        type must be one of: breakfast, lunch, dinner, snack. difficulty: Easy, Medium, Hard.
        CRITICAL CALORIE RULE: The sum of ALL meal calories for each day MUST equal EXACTLY \(Int(profile.dailyCalorieTarget)) kcal. Not approximately, not close — EXACTLY \(Int(profile.dailyCalorieTarget)). Adjust portion sizes to hit this number precisely. Before outputting, verify that the sum of calories of all meals for each day equals \(Int(profile.dailyCalorieTarget)).
        7 days Monday-Sunday. Do NOT include imageURL field. All meal names and ingredient names in \(aiLanguageName).
        """

        let body = buildTextRequestBody(prompt: prompt)
        let targetKcal = Int(profile.dailyCalorieTarget)
        for attempt in 0..<3 {
            do {
                let rawText = try await sendToolkitRequest(url: url, body: body, timeout: 180)
                let jsonText = extractJSON(from: rawText)
                if let jsonData = jsonText.data(using: .utf8),
                   let decoded = try? JSONDecoder().decode(NutritionPlanResponse.self, from: jsonData),
                   !decoded.days.isEmpty {
                    let normalizedDays = decoded.days.map { day in
                        let nd = DayPlan(id: day.id, dayName: DayNameNormalizer.normalize(day.dayName), meals: day.meals)
                        return normalizeDayCalories(nd, target: targetKcal)
                    }
                    return NutritionPlan(days: normalizedDays)
                }
            } catch {
                if attempt < 2 { try? await Task.sleep(for: .seconds(Double(attempt + 1) * 2.0)) }
            }
        }
        return DefaultData.nutritionPlan(for: profile)
    }

    static func generateScanBasedWorkoutPlan(scanResult: BodyScan2Result, profile: UserProfile, workoutQuizPreferences: WorkoutQuizPreferences? = nil) async throws -> WorkoutPlan {
        if useKimi {
            return try await generateScanBasedWorkoutPlanWithKimi(scanResult: scanResult, profile: profile, workoutQuizPreferences: workoutQuizPreferences)
        }
        guard !toolkitURL.isEmpty, let url = URL(string: toolkitURL + "/agent/chat") else {
            return WorkoutLocalization.localizePlan(DefaultData.workoutPlan(for: profile))
        }

        var extraInfo = ""
        var goalInfo = profile.goal.rawValue
        if let quiz = workoutQuizPreferences {
            if !quiz.fitnessGoal.isEmpty { goalInfo = quiz.fitnessGoal }
            if !quiz.trainingLocation.isEmpty { extraInfo += " Location: \(quiz.trainingLocation)." }
            if !quiz.equipmentCategory.isEmpty { extraInfo += " Equipment: \(quiz.equipmentCategory)." }
            if !quiz.jointPain.isEmpty { extraInfo += " Joint pain: \(quiz.jointPain.joined(separator: ", ")). AVOID exercises that stress these areas." }
            if !quiz.sessionDuration.isEmpty { extraInfo += " Session duration: \(quiz.sessionDuration) min." }
        }

        let bodyContext = "Body scan results: Somatotype=\(scanResult.somatotype), BodyFat=\(scanResult.estimatedBodyFat), BiologicalAge=\(scanResult.biologicalAge), MuscleDefinition=\(scanResult.muscleDefinition), Bloating=\(scanResult.bloatingPercentage), WeakPoints=\(scanResult.weakPoints.joined(separator: ", ")), StrongPoints=\(scanResult.strongPoints.joined(separator: ", ")), FocusAreas=\(scanResult.focusAreas.joined(separator: ", ")), RecommendedSplit=\(scanResult.trainingSplit), RecommendedDays=\(scanResult.trainingDaysPerWeek)"

        let daysCount = workoutQuizPreferences?.daysPerWeek ?? scanResult.trainingDaysPerWeek

        let prompt = """
        Generate a 7-day workout plan PERSONALIZED based on body scan analysis. Return ONLY valid JSON, no markdown.
        Profile: Goal=\(goalInfo), \(profile.gender.rawValue), \(Int(profile.currentWeightKg))kg, Age=\(profile.age)\(extraInfo)
        \(bodyContext)
        IMPORTANT: Design the workout plan to specifically target the weak points and focus areas identified in the body scan. Prioritize exercises for underdeveloped muscle groups. Use the recommended training split.
        JSON format: {"days":[{"dayName":"Monday","focus":"Chest & Triceps","durationMinutes":60,"isRestDay":false,"caloriesBurned":350,"exercises":[{"name":"Bench Press","sets":4,"reps":"8-10","restSeconds":90,"muscleGroups":["Chest","Triceps"],"category":"main","difficulty":"Intermediate","exerciseDescription":"Flat barbell bench press","formTips":["Keep shoulder blades retracted"],"durationMinutes":0}]}]}
        category must be: warmup, main, or cooldown. Include 1-2 warmup, 4-6 main, 1-2 cooldown exercises per training day.
        7 days Monday-Sunday. EXACTLY \(daysCount) training days (isRestDay=false) and EXACTLY \(7 - daysCount) rest days (isRestDay=true). You MUST return exactly \(daysCount) non-rest days. Do NOT return fewer or more training days than \(daysCount).
        """

        let body = buildTextRequestBody(prompt: prompt)
        for attempt in 0..<3 {
            do {
                let rawText = try await sendToolkitRequest(url: url, body: body, timeout: 180)
                let jsonText = extractJSON(from: rawText)
                if var plan = parseWorkoutPlanJSON(jsonText) {
                    plan = ensureTrainingDayCount(plan, expected: daysCount)
                    return plan
                }
            } catch {
                if attempt < 2 { try? await Task.sleep(for: .seconds(Double(attempt + 1) * 2.0)) }
            }
        }
        return WorkoutLocalization.localizePlan(DefaultData.workoutPlan(for: profile))
    }

    static func analyzeImageForPantry(imageBase64: String) async throws -> PantryProductResult {
        if useKimi {
            return try await analyzeImageForPantryWithKimi(imageBase64: imageBase64)
        }
        guard !toolkitURL.isEmpty, let url = URL(string: toolkitURL + "/agent/chat") else {
            return PantryProductResult(
                productName: "Product", brand: "", category: "Condiments and Spices",
                servingSize: "100g", calories: 250, protein: 10, carbs: 35, fat: 8,
                fiber: 3, sugars: 12, saturatedFat: 3
            )
        }
        return try await analyzePantrySingleImage(url: url, imageBase64: imageBase64, imageType: "food product")
    }

    static func analyzePantryProduct(frontBase64: String?, nutritionBase64: String?) async throws -> PantryProductResult {
        if useKimi {
            return try await analyzePantryProductWithKimi(frontBase64: frontBase64, nutritionBase64: nutritionBase64)
        }
        guard !toolkitURL.isEmpty, let url = URL(string: toolkitURL + "/agent/chat") else {
            throw AIServiceError.networkError("AI service not configured.")
        }

        guard frontBase64 != nil || nutritionBase64 != nil else {
            throw AIServiceError.networkError("No images to analyze.")
        }

        if let front = frontBase64, let nutrition = nutritionBase64 {
            for attempt in 0..<3 {
                do {
                    return try await analyzePantryBothImages(url: url, frontBase64: front, nutritionBase64: nutrition)
                } catch let error as AIServiceError {
                    if case .networkError(let msg) = error, (msg.contains("413") || msg.contains("too large")) {
                        break
                    }
                    if attempt < 2 {
                        try? await Task.sleep(for: .seconds(Double(attempt + 1) * 1.5))
                        continue
                    }
                } catch {
                    if attempt < 2 {
                        try? await Task.sleep(for: .seconds(Double(attempt + 1) * 1.5))
                        continue
                    }
                }
                break
            }

            async let frontTask = safeAnalyzeSingleWithRetry(url: url, imageBase64: front, imageType: "front label of a food product (read product name, brand, ingredients)")
            async let nutritionTask = safeAnalyzeSingleWithRetry(url: url, imageBase64: nutrition, imageType: "nutrition facts table (read exact values for calories, protein, carbs, fat, fiber, sugars, saturated fat)")

            let frontResult = await frontTask
            let nutritionResult = await nutritionTask

            if let fr = frontResult, let nr = nutritionResult {
                return PantryProductResult(
                    productName: fr.productName != "Scanned Product" ? fr.productName : nr.productName,
                    brand: !fr.brand.isEmpty ? fr.brand : nr.brand,
                    category: fr.category,
                    servingSize: !nr.servingSize.isEmpty ? nr.servingSize : fr.servingSize,
                    calories: nr.calories > 0 ? nr.calories : fr.calories,
                    protein: nr.protein > 0 ? nr.protein : fr.protein,
                    carbs: nr.carbs > 0 ? nr.carbs : fr.carbs,
                    fat: nr.fat > 0 ? nr.fat : fr.fat,
                    fiber: nr.fiber > 0 ? nr.fiber : fr.fiber,
                    sugars: nr.sugars > 0 ? nr.sugars : fr.sugars,
                    saturatedFat: nr.saturatedFat > 0 ? nr.saturatedFat : fr.saturatedFat
                )
            }
            if let fr = frontResult { return fr }
            if let nr = nutritionResult { return nr }
            throw AIServiceError.networkError("Analysis failed. Make sure photos are clear and well-lit, then try again.")
        }

        let singleBase64 = frontBase64 ?? nutritionBase64!
        let imageType = frontBase64 != nil ? "front label of a food product (read product name, brand, ingredients)" : "nutrition facts table (read exact values for calories, protein, carbs, fat)"
        return try await analyzePantrySingleWithRetry(url: url, imageBase64: singleBase64, imageType: imageType)
    }

    private static func safeAnalyzeSingleWithRetry(url: URL, imageBase64: String, imageType: String) async -> PantryProductResult? {
        for attempt in 0..<2 {
            if let result = try? await analyzePantrySingleImage(url: url, imageBase64: imageBase64, imageType: imageType) {
                return result
            }
            if attempt < 1 {
                try? await Task.sleep(for: .seconds(2))
            }
        }
        return nil
    }

    private static func analyzePantrySingleWithRetry(url: URL, imageBase64: String, imageType: String) async throws -> PantryProductResult {
        var lastError: Error?
        for attempt in 0..<3 {
            do {
                return try await analyzePantrySingleImage(url: url, imageBase64: imageBase64, imageType: imageType)
            } catch {
                lastError = error
                if attempt < 2 {
                    try? await Task.sleep(for: .seconds(Double(attempt + 1) * 1.5))
                }
            }
        }
        throw lastError ?? AIServiceError.networkError("Analysis failed after multiple attempts. Try again.")
    }

    private static func safeAnalyzeSingle(url: URL, imageBase64: String, imageType: String) async -> PantryProductResult? {
        try? await analyzePantrySingleImage(url: url, imageBase64: imageBase64, imageType: imageType)
    }

    private static func analyzePantryBothImages(url: URL, frontBase64: String, nutritionBase64: String) async throws -> PantryProductResult {
        let prompt = "Analyze these 2 photos of the SAME food product. Photo 1=front label (read name, brand). Photo 2=nutrition table (read kcal, protein, carbs, fat, fiber, sugars, saturated fat per 100g). Return ONLY raw JSON: {\"productName\":\"Name\",\"brand\":\"Brand\",\"category\":\"Category\",\"servingSize\":\"100g\",\"calories\":123,\"protein\":10.5,\"carbs\":20.3,\"fat\":5.2,\"fiber\":2.0,\"sugars\":8.1,\"saturatedFat\":1.5} category must be one of: Meat and Fish, Fruits and Vegetables, Dairy and Eggs, Grains and Pasta, Legumes and Nuts, Condiments and Spices. calories=integer, others=decimal. Use 0 if unreadable."

        let body = buildImageRequestBody(prompt: prompt, imageBase64Strings: [frontBase64, nutritionBase64])
        let rawText = try await sendToolkitRequest(url: url, body: body, timeout: 120)
        let jsonText = extractJSON(from: rawText)

        guard let jsonData = jsonText.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
              let name = obj["productName"] as? String, !name.isEmpty else {
            throw AIServiceError.decodingError
        }
        return parsePantryProductResult(from: obj)
    }

    private static func analyzePantrySingleImage(url: URL, imageBase64: String, imageType: String) async throws -> PantryProductResult {
        let prompt = "Analyze this photo of a \(imageType). Extract product name, brand, nutritional values per 100g. Return ONLY raw JSON: {\"productName\":\"Name\",\"brand\":\"Brand\",\"category\":\"Category\",\"servingSize\":\"100g\",\"calories\":123,\"protein\":10.5,\"carbs\":20.3,\"fat\":5.2,\"fiber\":2.0,\"sugars\":8.1,\"saturatedFat\":1.5} category: Meat and Fish|Fruits and Vegetables|Dairy and Eggs|Grains and Pasta|Legumes and Nuts|Condiments and Spices. calories=integer, others=decimal. Use 0 if unknown."

        let body = buildImageRequestBody(prompt: prompt, imageBase64Strings: [imageBase64])
        let rawText = try await sendToolkitRequest(url: url, body: body, timeout: 90)
        let jsonText = extractJSON(from: rawText)

        guard let jsonData = jsonText.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            throw AIServiceError.decodingError
        }
        let name = obj["productName"] as? String ?? ""
        if name.isEmpty && (obj["calories"] == nil) {
            throw AIServiceError.decodingError
        }
        return parsePantryProductResult(from: obj)
    }

    static func buildImageRequestBody(prompt: String, imageBase64Strings: [String]) -> [String: Any] {
        var content: [[String: Any]] = [["type": "text", "text": prompt]]
        for base64 in imageBase64Strings {
            let dataURI = "data:image/jpeg;base64," + base64
            content.append(["type": "image", "image": dataURI])
        }
        return [
            "messages": [["role": "user", "content": content]]
        ]
    }

    static func buildTextRequestBody(prompt: String) -> [String: Any] {
        return [
            "messages": [["role": "user", "content": prompt]]
        ]
    }

    static func sendToolkitRequest(url: URL, body: [String: Any], timeout: TimeInterval) async throws -> String {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeout
        config.timeoutIntervalForResource = timeout + 30
        let session = URLSession(configuration: config)

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = timeout

        guard let httpBody = try? JSONSerialization.data(withJSONObject: body) else {
            throw AIServiceError.networkError("Error preparing the request.")
        }
        request.httpBody = httpBody

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await session.data(for: request)
        } catch let urlError as URLError {
            if urlError.code == .timedOut {
                throw AIServiceError.networkError("Server timeout. Please try again in a few seconds.")
            }
            if urlError.code == .networkConnectionLost || urlError.code == .notConnectedToInternet {
                throw AIServiceError.networkError("Connection lost. Check your internet connection.")
            }
            throw AIServiceError.networkError("Connection failed (\(urlError.code.rawValue)). Try again.")
        } catch {
            throw AIServiceError.networkError("Network error: \(error.localizedDescription)")
        }

        if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode != 200 {
            let code = httpResponse.statusCode
            if code == 413 {
                throw AIServiceError.networkError("Photos too large (413). Try again.")
            }
            if code >= 500 {
                throw AIServiceError.networkError("Server unavailable (\(code)). Try again in a few seconds.")
            }
            throw AIServiceError.networkError("Server error (\(code)). Try again.")
        }

        let rawText = String(data: data, encoding: .utf8) ?? ""
        guard !rawText.isEmpty else {
            throw AIServiceError.noContent
        }
        return rawText
    }

    static func extractJSON(from text: String) -> String {
        return extractFoodJSON(from: text)
    }

    static func extractFoodJSON(from rawText: String) -> String {
        var streamAccumulated = ""
        let lines = rawText.components(separatedBy: "\n")
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { continue }
            if trimmed.hasPrefix("0:") {
                let jsonEncoded = String(trimmed.dropFirst(2))
                if let d = jsonEncoded.data(using: .utf8),
                   let decoded = try? JSONDecoder().decode(String.self, from: d) {
                    streamAccumulated += decoded
                }
            } else if trimmed.hasPrefix("d:") {
                let jsonEncoded = String(trimmed.dropFirst(2))
                if let d = jsonEncoded.data(using: .utf8),
                   let decoded = try? JSONSerialization.jsonObject(with: d) as? [String: Any] {
                    if let finishReason = decoded["finishReason"] as? String, !finishReason.isEmpty {
                        continue
                    }
                }
            } else if trimmed.hasPrefix("e:") || trimmed.hasPrefix("f:") {
                continue
            } else if trimmed.hasPrefix("data: ") {
                let content = String(trimmed.dropFirst(6))
                guard content != "[DONE]" else { continue }
                if let d = content.data(using: .utf8),
                   let json = try? JSONSerialization.jsonObject(with: d) as? [String: Any] {
                    if let delta = json["textDelta"] as? String {
                        streamAccumulated += delta
                    } else if let choices = json["choices"] as? [[String: Any]],
                              let delta = choices.first?["delta"] as? [String: Any],
                              let c = delta["content"] as? String {
                        streamAccumulated += c
                    }
                }
            }
        }

        if streamAccumulated.isEmpty {
            if let d = rawText.data(using: .utf8),
               let obj = try? JSONSerialization.jsonObject(with: d) as? [String: Any] {
                let textKeys = ["text", "content", "message", "response", "output", "result"]
                for key in textKeys {
                    if let inner = obj[key] as? String, !inner.isEmpty {
                        streamAccumulated = inner
                        break
                    }
                }
                if streamAccumulated.isEmpty,
                   let choices = obj["choices"] as? [[String: Any]],
                   let first = choices.first {
                    if let msg = first["message"] as? [String: Any],
                       let content = msg["content"] as? String {
                        streamAccumulated = content
                    } else if let delta = first["delta"] as? [String: Any],
                              let content = delta["content"] as? String {
                        streamAccumulated = content
                    }
                }
                if streamAccumulated.isEmpty, obj["productName"] != nil {
                    return rawText
                }
                if streamAccumulated.isEmpty, obj["foodName"] != nil {
                    return rawText
                }
                if streamAccumulated.isEmpty, obj["name"] != nil, obj["calories"] != nil {
                    return rawText
                }
            }

            if streamAccumulated.isEmpty {
                if let d = rawText.data(using: .utf8),
                   let arr = try? JSONSerialization.jsonObject(with: d) as? [Any] {
                    for item in arr {
                        if let dict = item as? [String: Any], let text = dict["text"] as? String {
                            streamAccumulated += text
                        }
                    }
                }
            }
        }

        if streamAccumulated.isEmpty {
            streamAccumulated = rawText
        }

        let cleaned = streamAccumulated
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        return extractBalancedJSON(from: cleaned)
    }

    static func parseCalorieResult(from jsonText: String) -> CalorieAnalysisResult {
        guard let jsonData = jsonText.data(using: .utf8) else {
            return .fallback()
        }
        if let result = try? JSONDecoder().decode(CalorieAnalysisResult.self, from: jsonData) {
            return result
        }
        guard let partial = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            return .fallback()
        }
        let foodName = partial["foodName"] as? String ?? "Detected Meal"
        let calories = (partial["calories"] as? Int) ?? Int((partial["calories"] as? Double) ?? 400)
        let protein = (partial["protein"] as? Double) ?? Double((partial["protein"] as? Int) ?? 20)
        let carbs = (partial["carbs"] as? Double) ?? Double((partial["carbs"] as? Int) ?? 50)
        let fat = (partial["fat"] as? Double) ?? Double((partial["fat"] as? Int) ?? 12)
        let servingSize = partial["servingSize"] as? String ?? "1 serving"
        let confidence = partial["confidence"] as? String ?? "Medium"
        let notes = partial["notes"] as? String ?? ""
        var ingredients: [ScannedIngredient] = []
        if let rawIngredients = partial["ingredients"] as? [[String: Any]] {
            for item in rawIngredients {
                guard let name = item["name"] as? String else { continue }
                let qty = item["quantity"] as? String ?? "1 porzione"
                let cal = (item["calories"] as? Int) ?? Int((item["calories"] as? Double) ?? 0)
                let p = (item["protein"] as? Double) ?? Double((item["protein"] as? Int) ?? 0)
                let cb = (item["carbs"] as? Double) ?? Double((item["carbs"] as? Int) ?? 0)
                let f = (item["fat"] as? Double) ?? Double((item["fat"] as? Int) ?? 0)
                ingredients.append(ScannedIngredient(name: name, quantity: qty, calories: cal, protein: p, carbs: cb, fat: f))
            }
        }
        return CalorieAnalysisResult(
            foodName: foodName, calories: calories, protein: protein,
            carbs: carbs, fat: fat, servingSize: servingSize,
            confidence: confidence, notes: notes, ingredients: ingredients
        )
    }

    static func extractBalancedJSON(from text: String) -> String {
        guard let startIdx = text.firstIndex(of: "{") else { return text }
        var depth = 0
        var inString = false
        var escape = false
        var idx = startIdx
        while idx < text.endIndex {
            let ch = text[idx]
            if escape {
                escape = false
            } else if ch == "\\" && inString {
                escape = true
            } else if ch == "\"" {
                inString.toggle()
            } else if !inString {
                if ch == "{" { depth += 1 }
                else if ch == "}" {
                    depth -= 1
                    if depth == 0 {
                        return String(text[startIdx...idx])
                    }
                }
            }
            idx = text.index(after: idx)
        }
        return text
    }

    static func lookupBarcode(_ barcode: String) async throws -> PantryProductResult {
        if let offResult = try? await lookupBarcodeOpenFoodFacts(barcode) {
            return offResult
        }

        if useKimi {
            return try await lookupBarcodeWithKimi(barcode)
        }

        guard !toolkitURL.isEmpty, let url = URL(string: toolkitURL + "/agent/chat") else {
            throw AIServiceError.networkError("Prodotto non trovato nel database")
        }

        let exampleJSON = "{\"productName\":\"Barilla Spaghetti n.5\",\"brand\":\"Barilla\",\"category\":\"Grains and Pasta\",\"servingSize\":\"100g\",\"calories\":356,\"protein\":12.5,\"carbs\":71.2,\"fat\":1.5,\"fiber\":3.0,\"sugars\":3.5,\"saturatedFat\":0.3}"

        let prompt = """
        You are a food product database. Look up this barcode/EAN and return the product nutritional info.
        Barcode: \(barcode)

        Return ONLY a raw JSON object, no markdown, no explanation. Start with { end with }.
        Format: \(exampleJSON)

        Rules:
        - productName: the specific product name for this barcode
        - brand: manufacturer/brand name
        - category: one of "Meat and Fish", "Fruits and Vegetables", "Dairy and Eggs", "Grains and Pasta", "Legumes and Nuts", "Condiments and Spices"
        - servingSize: prefer "100g"
        - calories: integer kcal, protein/carbs/fat/fiber/sugars/saturatedFat: decimal grams
        - If you don't know the product, return productName as "Unknown"
        """

        let body = buildTextRequestBody(prompt: prompt)
        let rawText = try await sendToolkitRequest(url: url, body: body, timeout: 60)
        let jsonText = extractJSON(from: rawText)

        guard let jsonData = jsonText.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            throw AIServiceError.decodingError
        }

        let result = parsePantryProductResult(from: obj)
        if result.productName == "Unknown" || result.productName.isEmpty {
            throw AIServiceError.noContent
        }
        return result
    }

    static func lookupBarcodeOpenFoodFacts(_ barcode: String) async throws -> PantryProductResult {
        guard let url = URL(string: "https://world.openfoodfacts.org/api/v2/product/\(barcode).json?fields=product_name,brands,categories_tags,nutriments,serving_size,quantity") else {
            throw AIServiceError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue("MyWellnessAIBodyScanner iOS App - contact@mywellness.app", forHTTPHeaderField: "User-Agent")
        request.timeoutInterval = 15

        let (data, httpResponse) = try await URLSession.shared.data(for: request)

        guard let response = httpResponse as? HTTPURLResponse, response.statusCode == 200 else {
            throw AIServiceError.networkError("OpenFoodFacts non raggiungibile")
        }

        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let status = json["status"] as? Int, status == 1,
              let product = json["product"] as? [String: Any] else {
            throw AIServiceError.noContent
        }

        let productName = product["product_name"] as? String ?? "Prodotto"
        guard !productName.isEmpty else { throw AIServiceError.noContent }

        let brand = product["brands"] as? String ?? ""
        let servingSize = product["serving_size"] as? String ?? "100g"

        let nutriments = product["nutriments"] as? [String: Any] ?? [:]

        let calories = nutrimentInt(nutriments, keys: ["energy-kcal_100g", "energy-kcal"])
        let protein = nutrimentDouble(nutriments, keys: ["proteins_100g", "proteins"])
        let carbs = nutrimentDouble(nutriments, keys: ["carbohydrates_100g", "carbohydrates"])
        let fat = nutrimentDouble(nutriments, keys: ["fat_100g", "fat"])
        let fiber = nutrimentDouble(nutriments, keys: ["fiber_100g", "fiber"])
        let sugars = nutrimentDouble(nutriments, keys: ["sugars_100g", "sugars"])
        let saturatedFat = nutrimentDouble(nutriments, keys: ["saturated-fat_100g", "saturated-fat"])

        let categoryTags = product["categories_tags"] as? [String] ?? []
        let category = mapOFFCategoryToLocal(categoryTags)

        return PantryProductResult(
            productName: productName, brand: brand, category: category,
            servingSize: servingSize, calories: calories, protein: protein,
            carbs: carbs, fat: fat, fiber: fiber, sugars: sugars, saturatedFat: saturatedFat
        )
    }

    private static func nutrimentInt(_ n: [String: Any], keys: [String]) -> Int {
        for key in keys {
            if let v = n[key] as? Int { return v }
            if let v = n[key] as? Double { return Int(v) }
            if let v = n[key] as? String, let d = Double(v) { return Int(d) }
        }
        return 0
    }

    private static func nutrimentDouble(_ n: [String: Any], keys: [String]) -> Double {
        for key in keys {
            if let v = n[key] as? Double { return v }
            if let v = n[key] as? Int { return Double(v) }
            if let v = n[key] as? String, let d = Double(v) { return d }
        }
        return 0
    }

    private static func mapOFFCategoryToLocal(_ tags: [String]) -> String {
        let joined = tags.joined(separator: " ").lowercased()
        if joined.contains("meat") || joined.contains("fish") || joined.contains("poultry") || joined.contains("seafood") || joined.contains("carn") || joined.contains("pesc") {
            return "Meat and Fish"
        }
        if joined.contains("fruit") || joined.contains("vegetable") || joined.contains("frut") || joined.contains("verdur") {
            return "Fruits and Vegetables"
        }
        if joined.contains("dairy") || joined.contains("milk") || joined.contains("cheese") || joined.contains("egg") || joined.contains("latt") || joined.contains("formag") || joined.contains("uov") {
            return "Dairy and Eggs"
        }
        if joined.contains("grain") || joined.contains("pasta") || joined.contains("bread") || joined.contains("cereal") || joined.contains("rice") || joined.contains("pan") || joined.contains("ris") {
            return "Grains and Pasta"
        }
        if joined.contains("legum") || joined.contains("nut") || joined.contains("bean") || joined.contains("seed") || joined.contains("nocc") || joined.contains("fagioli") {
            return "Legumes and Nuts"
        }
        return "Condiments and Spices"
    }
}

nonisolated struct PantryProductResult: Sendable {
    let productName: String
    let brand: String
    let category: String
    let servingSize: String
    let calories: Int
    let protein: Double
    let carbs: Double
    let fat: Double
    let fiber: Double
    let sugars: Double
    let saturatedFat: Double
}

extension AIService {
    static func analyzeMealPlanText(text: String) async throws -> NutritionPlan {
        let truncated = String(text.prefix(20000))

        let mealPlanPrompt = """
        You are a nutrition expert. Extract ALL meals from this meal plan document for the ENTIRE week.
        The document is a meal plan from a doctor or nutritionist. Read it carefully and extract every meal, every ingredient, every quantity, and every nutritional value mentioned.

        TEXT:
        \(truncated)

        CRITICAL RULES:
        - Extract EXACTLY what is written in the plan. Do NOT invent or modify meals.
        - If the plan specifies days (Monday, Tuesday, etc.), map each meal to the correct day.
        - If the plan does not specify days, distribute the meals evenly across 7 days Monday-Sunday.
        - If the plan gives a single day template, replicate it across all 7 days.
        - Each meal must have: type (breakfast/lunch/dinner/snack), name, calories, protein, carbs, fat, prepTime, difficulty, and ingredients with amounts.
        - If calories/macros are not explicitly stated, estimate them based on the ingredients and quantities listed.
        - If ingredient quantities are listed (e.g. "100g chicken breast"), use those exact amounts.
        - type must be one of: breakfast, lunch, dinner, snack.
        - difficulty: Easy, Medium, Hard.
        - All text in \(aiLanguageName).

        Return ONLY valid JSON, no markdown, no explanation. Start with { and end with }.
        {"days":[{"dayName":"Monday","meals":[{"type":"breakfast","name":"Meal Name","calories":500,"protein":30.0,"carbs":45.0,"fat":20.0,"prepTime":15,"difficulty":"Easy","ingredients":[{"name":"Ingredient","amount":100.0,"unit":"g","calories":100}]}]}]}
        7 days Monday-Sunday. Do NOT include imageURL field.
        """

        var lastError: Error?

        if !toolkitURL.isEmpty, let url = URL(string: toolkitURL + "/agent/chat") {
            let body = buildTextRequestBody(prompt: mealPlanPrompt)
            for attempt in 0..<3 {
                do {
                    let rawText = try await sendToolkitRequest(url: url, body: body, timeout: 180)
                    let jsonText = extractJSON(from: rawText)
                    if let plan = parseMealPlanJSON(jsonText), !plan.days.isEmpty {
                        return plan
                    }
                    lastError = AIServiceError.decodingError
                } catch {
                    lastError = error
                    if attempt < 2 { try? await Task.sleep(for: .seconds(3)) }
                }
            }
        }

        if useKimi {
            for attempt in 0..<3 {
                do {
                    let rawText = try await KimiService.chatCompletionLarge(prompt: mealPlanPrompt, maxTokens: 16000, timeout: 180)
                    let jsonText = extractJSON(from: rawText)
                    if let plan = parseMealPlanJSON(jsonText), !plan.days.isEmpty {
                        return plan
                    }
                    lastError = AIServiceError.decodingError
                } catch {
                    lastError = error
                    if attempt < 2 { try? await Task.sleep(for: .seconds(3)) }
                }
            }
        }

        throw lastError ?? AIServiceError.networkError(Lang.s("upload_analysis_failed_detail"))
    }

    static func analyzeMealPlanImages(imageBase64Strings: [String]) async throws -> NutritionPlan {
        let imagePrompt = """
        You are a nutrition expert. These photos show a meal plan from a doctor or nutritionist.
        Read ALL the text visible in these photos. Extract every single meal, ingredient, quantity, and nutritional value you can see.

        CRITICAL RULES:
        - Extract EXACTLY what is written in the plan. Do NOT invent or modify meals.
        - If the plan specifies days (Monday, Tuesday, etc.), map each meal to the correct day.
        - If the plan does not specify days, distribute meals across 7 days Monday-Sunday.
        - If the plan gives a single day template, replicate it across all 7 days.
        - Each meal must have: type (breakfast/lunch/dinner/snack), name, calories, protein, carbs, fat, prepTime, difficulty, and ingredients with amounts.
        - If calories/macros are not explicitly stated, estimate them based on the ingredients and quantities visible.
        - type must be one of: breakfast, lunch, dinner, snack.
        - difficulty: Easy, Medium, Hard.
        - All text in \(aiLanguageName).

        Return ONLY valid JSON, no markdown, no explanation. Start with { and end with }.
        {"days":[{"dayName":"Monday","meals":[{"type":"breakfast","name":"Meal Name","calories":500,"protein":30.0,"carbs":45.0,"fat":20.0,"prepTime":15,"difficulty":"Easy","ingredients":[{"name":"Ingredient","amount":100.0,"unit":"g","calories":100}]}]}]}
        7 days Monday-Sunday. Do NOT include imageURL field.
        """

        var lastError: Error?

        if !toolkitURL.isEmpty, let url = URL(string: toolkitURL + "/agent/chat") {
            let body = buildImageRequestBody(prompt: imagePrompt, imageBase64Strings: imageBase64Strings)
            for attempt in 0..<3 {
                do {
                    let rawText = try await sendToolkitRequest(url: url, body: body, timeout: 180)
                    let jsonText = extractJSON(from: rawText)
                    if let plan = parseMealPlanJSON(jsonText), !plan.days.isEmpty {
                        return plan
                    }
                    lastError = AIServiceError.decodingError
                } catch {
                    lastError = error
                    if attempt < 2 { try? await Task.sleep(for: .seconds(3)) }
                }
            }
        }

        if useKimi {
            for attempt in 0..<3 {
                do {
                    let rawText = try await KimiService.visionCompletionLarge(prompt: imagePrompt, imageBase64Strings: imageBase64Strings, maxTokens: 16000, timeout: 180)
                    let jsonText = extractJSON(from: rawText)
                    if let plan = parseMealPlanJSON(jsonText), !plan.days.isEmpty {
                        return plan
                    }
                    lastError = AIServiceError.decodingError
                } catch {
                    lastError = error
                    if attempt < 2 { try? await Task.sleep(for: .seconds(3)) }
                }
            }
        }

        throw lastError ?? AIServiceError.networkError(Lang.s("upload_analysis_failed_detail"))
    }

    static func analyzeWorkoutPDF(pdfText: String) async throws -> WorkoutPlan {
        if useKimi {
            return try await analyzeWorkoutPDFWithKimi(pdfText: pdfText)
        }
        guard !toolkitURL.isEmpty, let url = URL(string: toolkitURL + "/agent/chat") else {
            throw AIServiceError.networkError("AI service not configured.")
        }

        let truncated = String(pdfText.prefix(8000))

        let prompt = """
        Extract ALL exercises from this workout plan. Return ONLY valid JSON, no markdown.

        CRITICAL RULES:
        - Every single exercise MUST be its own separate JSON object in the "exercises" array.
        - NEVER combine multiple exercises into one entry. If a day lists "Squats, Leg Press, Deadlifts, Barbell Rows, Calf Raises", each one must be a separate object with its own name, sets, and reps.
        - If sets/reps are not specified for an exercise, use reasonable defaults (3 sets, "10-12" reps).
        - The first exercise of each day should have category "warmup", the last one "cooldown", all others "main".
        - Default rest 60s between exercises, 90s for compound movements.
        - 7 days Monday-Sunday. Days not in the plan should have isRestDay=true and empty exercises array.
        - All text in \(aiLanguageName).

        TEXT:
        \(truncated)

        JSON format (each exercise is a SEPARATE object):
        {"days":[{"dayName":"Monday","focus":"Chest","durationMinutes":60,"isRestDay":false,"caloriesBurned":300,"exercises":[{"name":"Warm-up","sets":1,"reps":"5-10 min","restSeconds":0,"muscleGroups":["Full Body"],"category":"warmup"},{"name":"Bench Press","sets":4,"reps":"8-10","restSeconds":90,"muscleGroups":["Chest"],"category":"main"},{"name":"Incline Dumbbell Press","sets":3,"reps":"10-12","restSeconds":60,"muscleGroups":["Chest"],"category":"main"}]}]}

        WRONG (never do this): {"name":"Warm-up","sets":1,"reps":"Squats, Leg Press, Deadlifts","category":"warmup"}
        CORRECT: each of Squats, Leg Press, Deadlifts must be separate objects with category "main".
        """

        let body = buildTextRequestBody(prompt: prompt)

        var lastError: Error?
        for attempt in 0..<2 {
            do {
                let rawText = try await sendToolkitRequest(url: url, body: body, timeout: 60)
                let jsonText = extractJSON(from: rawText)
                if let plan = parseWorkoutPlanJSON(jsonText), !plan.days.isEmpty {
                    return plan
                }
            } catch {
                lastError = error
            }
            if attempt < 1 {
                try? await Task.sleep(for: .seconds(2.0))
            }
        }
        throw lastError ?? AIServiceError.networkError("Failed to analyze the workout plan.")
    }

    static func parsePantryProductResult(from obj: [String: Any]) -> PantryProductResult {
        let productName = obj["productName"] as? String ?? "Scanned Product"
        let brand = obj["brand"] as? String ?? ""
        let category = obj["category"] as? String ?? "Condiments and Spices"
        let servingSize = obj["servingSize"] as? String ?? "100g"
        let calories = (obj["calories"] as? Int) ?? Int((obj["calories"] as? Double) ?? 0)
        let protein = (obj["protein"] as? Double) ?? Double((obj["protein"] as? Int) ?? 0)
        let carbs = (obj["carbs"] as? Double) ?? Double((obj["carbs"] as? Int) ?? 0)
        let fat = (obj["fat"] as? Double) ?? Double((obj["fat"] as? Int) ?? 0)
        let fiber = (obj["fiber"] as? Double) ?? Double((obj["fiber"] as? Int) ?? 0)
        let sugars = (obj["sugars"] as? Double) ?? Double((obj["sugars"] as? Int) ?? 0)
        let saturatedFat = (obj["saturatedFat"] as? Double) ?? Double((obj["saturatedFat"] as? Int) ?? 0)
        return PantryProductResult(
            productName: productName, brand: brand, category: category,
            servingSize: servingSize, calories: calories, protein: protein,
            carbs: carbs, fat: fat, fiber: fiber, sugars: sugars, saturatedFat: saturatedFat
        )
    }
}

nonisolated private struct NutritionPlanResponse: Codable, Sendable {
    let days: [DayPlan]
}

extension AIService {
    static func generateScanNutritionModifications(
        scanResult: BodyScan2Result,
        currentPlan: NutritionPlan,
        profile: UserProfile,
        quizPreferences: MealPlanQuizPreferences? = nil
    ) async throws -> (modifications: ScanPlanModifications, modifiedPlan: NutritionPlan) {
        if useKimi {
            return try await generateScanNutritionModificationsWithKimi(scanResult: scanResult, currentPlan: currentPlan, profile: profile, quizPreferences: quizPreferences)
        }
        guard !toolkitURL.isEmpty, let url = URL(string: toolkitURL + "/agent/chat") else {
            let fallbackMods = ScanPlanModifications(
                nutritionSummary: "Nessuna modifica disponibile",
                workoutSummary: "",
                nutritionChanges: [],
                workoutChanges: []
            )
            return (fallbackMods, currentPlan)
        }

        let currentPlanSummary = summarizeNutritionPlan(currentPlan)
        let bodyContext = "Body scan: Somatotype=\(scanResult.somatotype), BodyFat=\(scanResult.estimatedBodyFat), BiologicalAge=\(scanResult.biologicalAge), MuscleDefinition=\(scanResult.muscleDefinition), Bloating=\(scanResult.bloatingPercentage), WeakPoints=\(scanResult.weakPoints.joined(separator: ", ")), StrongPoints=\(scanResult.strongPoints.joined(separator: ", ")), FocusAreas=\(scanResult.focusAreas.joined(separator: ", "))"

        var dietInfo = profile.dietType.rawValue
        var intolerancesInfo = ""
        if let quiz = quizPreferences {
            if !quiz.dietType.isEmpty { dietInfo = quiz.dietType }
            if !quiz.intolerances.isEmpty || !quiz.customIntolerances.isEmpty {
                var all = quiz.intolerances
                if !quiz.customIntolerances.isEmpty { all.append(quiz.customIntolerances) }
                intolerancesInfo = " Intolerances: \(all.joined(separator: ", "))."
            }
        }

        let prompt = """
        You are a nutrition expert. The user already has an existing meal plan. Based on a NEW body scan, suggest SMALL targeted modifications to their CURRENT plan. Do NOT recreate the plan from scratch.

        Profile: Goal=\(profile.goal.rawValue), Diet=\(dietInfo), \(Int(profile.dailyCalorieTarget))kcal/day, \(profile.gender.rawValue), \(Int(profile.currentWeightKg))kg\(intolerancesInfo)
        \(bodyContext)

        CURRENT PLAN SUMMARY:
        \(currentPlanSummary)

        Based on the new body scan results, suggest only the necessary changes. Keep most of the plan intact. Only modify meals that need adjustment based on the scan findings.

        Return ONLY valid JSON with TWO sections:
        1. "modifications" - description of changes
        2. "days" - the FULL modified plan (same structure as before, with the small changes applied)

        JSON format:
        {"modifications":{"nutritionSummary":"Summary of nutrition plan changes","workoutSummary":"","nutritionChanges":[{"dayName":"Monday","changeType":"replace","description":"Replaced lunch with higher protein meal","reason":"High body fat, more protein needed"}],"workoutChanges":[]},"days":[{"dayName":"Monday","meals":[{"type":"breakfast","name":"Name","calories":500,"protein":30.0,"carbs":45.0,"fat":20.0,"prepTime":15,"difficulty":"Easy","ingredients":[{"name":"Ing","amount":100.0,"unit":"g","calories":100}]}]}]}

        RULES:
        - Keep at least 70% of meals unchanged from the current plan
        - Only modify meals that directly address scan findings
        - nutritionChanges should list ONLY the specific meals you changed and why
        - nutritionSummary: brief \(aiLanguageName) summary of all nutrition changes
        - All text in \(aiLanguageName)
        - 7 days Monday-Sunday
        """

        let body = buildTextRequestBody(prompt: prompt)
        for attempt in 0..<3 {
            do {
                let rawText = try await sendToolkitRequest(url: url, body: body, timeout: 180)
                let jsonText = extractJSON(from: rawText)
                if let result = parseModifiedNutritionResponse(jsonText) {
                    return result
                }
            } catch {
                if attempt < 2 { try? await Task.sleep(for: .seconds(Double(attempt + 1) * 2.0)) }
            }
        }

        let fallbackMods = ScanPlanModifications(
            nutritionSummary: Lang.s("no_modifications_available"),
            workoutSummary: "",
            nutritionChanges: [],
            workoutChanges: []
        )
        return (fallbackMods, currentPlan)
    }

    static func generateScanWorkoutModifications(
        scanResult: BodyScan2Result,
        currentPlan: WorkoutPlan,
        profile: UserProfile,
        workoutQuizPreferences: WorkoutQuizPreferences? = nil
    ) async throws -> (modifications: ScanPlanModifications, modifiedPlan: WorkoutPlan) {
        if useKimi {
            return try await generateScanWorkoutModificationsWithKimi(scanResult: scanResult, currentPlan: currentPlan, profile: profile, workoutQuizPreferences: workoutQuizPreferences)
        }
        guard !toolkitURL.isEmpty, let url = URL(string: toolkitURL + "/agent/chat") else {
            let fallbackMods = ScanPlanModifications(
                nutritionSummary: "",
                workoutSummary: Lang.s("no_modifications_available"),
                nutritionChanges: [],
                workoutChanges: []
            )
            return (fallbackMods, currentPlan)
        }

        let currentPlanSummary = summarizeWorkoutPlan(currentPlan)
        let bodyContext = "Body scan: Somatotype=\(scanResult.somatotype), BodyFat=\(scanResult.estimatedBodyFat), BiologicalAge=\(scanResult.biologicalAge), MuscleDefinition=\(scanResult.muscleDefinition), WeakPoints=\(scanResult.weakPoints.joined(separator: ", ")), StrongPoints=\(scanResult.strongPoints.joined(separator: ", ")), FocusAreas=\(scanResult.focusAreas.joined(separator: ", ")), RecommendedSplit=\(scanResult.trainingSplit), RecommendedDays=\(scanResult.trainingDaysPerWeek)"

        var extraInfo = ""
        var goalInfo = profile.goal.rawValue
        if let quiz = workoutQuizPreferences {
            if !quiz.fitnessGoal.isEmpty { goalInfo = quiz.fitnessGoal }
            if !quiz.trainingLocation.isEmpty { extraInfo += " Location: \(quiz.trainingLocation)." }
            if !quiz.equipmentCategory.isEmpty { extraInfo += " Equipment: \(quiz.equipmentCategory)." }
            if !quiz.jointPain.isEmpty { extraInfo += " Joint pain: \(quiz.jointPain.joined(separator: ", ")). AVOID exercises that stress these areas." }
        }

        let prompt = """
        You are a fitness expert. The user already has an existing workout plan. Based on a NEW body scan, suggest SMALL targeted modifications to their CURRENT plan. Do NOT recreate the plan from scratch.

        Profile: Goal=\(goalInfo), \(profile.gender.rawValue), \(Int(profile.currentWeightKg))kg, Age=\(profile.age)\(extraInfo)
        \(bodyContext)

        CURRENT PLAN SUMMARY:
        \(currentPlanSummary)

        Based on the new body scan results, suggest only the necessary exercise changes. Keep the overall structure and most exercises intact.

        Return ONLY valid JSON with TWO sections:
        {"modifications":{"nutritionSummary":"","workoutSummary":"Summary of workout plan changes","nutritionChanges":[],"workoutChanges":[{"dayName":"Monday","changeType":"replace","description":"Added chest exercise","reason":"Chest identified as weak point"}]},"days":[{"dayName":"Monday","focus":"Chest & Triceps","durationMinutes":60,"isRestDay":false,"caloriesBurned":350,"exercises":[{"name":"Bench Press","sets":4,"reps":"8-10","restSeconds":90,"muscleGroups":["Chest","Triceps"],"category":"main","difficulty":"Intermediate","exerciseDescription":"Flat barbell bench press","formTips":["Keep shoulder blades retracted"],"durationMinutes":0}]}]}

        RULES:
        - Keep at least 70% of exercises unchanged from the current plan
        - Only modify exercises that directly address scan findings (weak points, focus areas)
        - workoutChanges should list ONLY the specific exercises you changed and why
        - workoutSummary: brief \(aiLanguageName) summary of all workout changes
        - category must be: warmup, main, or cooldown
        - All text in \(aiLanguageName)
        - 7 days Monday-Sunday
        """

        let body = buildTextRequestBody(prompt: prompt)
        for attempt in 0..<3 {
            do {
                let rawText = try await sendToolkitRequest(url: url, body: body, timeout: 180)
                let jsonText = extractJSON(from: rawText)
                if let result = parseModifiedWorkoutResponse(jsonText) {
                    return result
                }
            } catch {
                if attempt < 2 { try? await Task.sleep(for: .seconds(Double(attempt + 1) * 2.0)) }
            }
        }

        let fallbackMods = ScanPlanModifications(
            nutritionSummary: "",
            workoutSummary: Lang.s("no_modifications_available"),
            nutritionChanges: [],
            workoutChanges: []
        )
        return (fallbackMods, currentPlan)
    }

    static func summarizeNutritionPlan(_ plan: NutritionPlan) -> String {
        var summary = ""
        for day in plan.days {
            let mealNames = day.meals.map { "\($0.type.rawValue): \($0.name) (\($0.calories)kcal)" }.joined(separator: ", ")
            summary += "\(day.dayName): \(mealNames) [Total: \(day.totalCalories)kcal]\n"
        }
        return summary
    }

    static func summarizeWorkoutPlan(_ plan: WorkoutPlan) -> String {
        var summary = ""
        for day in plan.days {
            if day.isRestDay {
                summary += "\(day.dayName): REST DAY\n"
            } else {
                let exerciseNames = day.exercises.filter { $0.category == .main }.map { "\($0.name) (\($0.sets)x\($0.reps))" }.joined(separator: ", ")
                summary += "\(day.dayName): \(day.focus) — \(exerciseNames) [\(day.durationMinutes)min]\n"
            }
        }
        return summary
    }

    static func parseModifiedNutritionResponse(_ jsonText: String) -> (modifications: ScanPlanModifications, modifiedPlan: NutritionPlan)? {
        guard let jsonData = jsonText.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else { return nil }

        let mods: ScanPlanModifications
        if let modsObj = obj["modifications"] as? [String: Any],
           let modsData = try? JSONSerialization.data(withJSONObject: modsObj),
           let decoded = try? JSONDecoder().decode(ScanPlanModifications.self, from: modsData) {
            mods = decoded
        } else {
            mods = ScanPlanModifications(nutritionSummary: "", workoutSummary: "", nutritionChanges: [], workoutChanges: [])
        }

        guard let daysArr = obj["days"] as? [[String: Any]] else { return nil }

        let wrappedObj: [String: Any] = ["days": daysArr]
        guard let wrappedData = try? JSONSerialization.data(withJSONObject: wrappedObj),
              let planResponse = try? JSONDecoder().decode(NutritionPlanResponse.self, from: wrappedData),
              !planResponse.days.isEmpty else {
            return nil
        }

        let normalizedDays = planResponse.days.map { DayPlan(id: $0.id, dayName: DayNameNormalizer.normalize($0.dayName), meals: $0.meals) }
        return (mods, NutritionPlan(days: normalizedDays))
    }

    static func modifyTodaySession(currentDay: WorkoutDay, userRequest: String, profile: UserProfile) async throws -> WorkoutDay {
        if useKimi {
            return try await modifyTodaySessionWithKimi(currentDay: currentDay, userRequest: userRequest, profile: profile)
        }
        guard !toolkitURL.isEmpty, let url = URL(string: toolkitURL + "/agent/chat") else {
            throw AIServiceError.networkError("AI service not configured.")
        }

        let exerciseSummary = currentDay.exercises.map { ex in
            "\(ex.name) (\(ex.sets)x\(ex.reps), \(ex.category.rawValue), muscles: \(ex.muscleGroups.joined(separator: ",")))"
        }.joined(separator: "; ")

        let prompt = """
        You are a fitness expert. The user wants to modify TODAY's workout session based on their request.
        Modify ONLY what the user asks. Keep everything else unchanged.

        Profile: \(profile.gender.rawValue), \(Int(profile.currentWeightKg))kg, Age=\(profile.age), Goal=\(profile.goal.rawValue)
        Today's session: \(currentDay.dayName) — \(currentDay.focus)
        Current exercises: \(exerciseSummary)

        User request: "\(userRequest)"

        Return ONLY valid JSON for the modified day:
        {"dayName":"\(currentDay.dayName)","focus":"...","durationMinutes":\(currentDay.durationMinutes),"isRestDay":false,"caloriesBurned":\(currentDay.caloriesBurned),"exercises":[{"name":"...","sets":4,"reps":"8-10","restSeconds":90,"muscleGroups":["Chest"],"category":"main","difficulty":"Intermediate","exerciseDescription":"...","formTips":["..."],"loadTips":["..."],"durationMinutes":0}]}
        category must be: warmup, main, or cooldown.
        All text in \(aiLanguageName).
        """

        let body = buildTextRequestBody(prompt: prompt)
        for attempt in 0..<3 {
            do {
                let rawText = try await sendToolkitRequest(url: url, body: body, timeout: 120)
                let jsonText = extractJSON(from: rawText)
                if let day = parseSingleWorkoutDayJSON(jsonText) {
                    return day
                }
            } catch {
                if attempt < 2 { try? await Task.sleep(for: .seconds(Double(attempt + 1) * 2.0)) }
            }
        }
        throw AIServiceError.networkError("Failed to modify session.")
    }

    private static func modifyTodaySessionWithKimi(currentDay: WorkoutDay, userRequest: String, profile: UserProfile) async throws -> WorkoutDay {
        let exerciseSummary = currentDay.exercises.map { ex in
            "\(ex.name) (\(ex.sets)x\(ex.reps), \(ex.category.rawValue), muscles: \(ex.muscleGroups.joined(separator: ",")))"
        }.joined(separator: "; ")

        let prompt = """
        You are a fitness expert. The user wants to modify TODAY's workout session based on their request.
        Modify ONLY what the user asks. Keep everything else unchanged.

        Profile: \(profile.gender.rawValue), \(Int(profile.currentWeightKg))kg, Age=\(profile.age), Goal=\(profile.goal.rawValue)
        Today's session: \(currentDay.dayName) — \(currentDay.focus)
        Current exercises: \(exerciseSummary)

        User request: "\(userRequest)"

        Return ONLY valid JSON for the modified day:
        {"dayName":"\(currentDay.dayName)","focus":"...","durationMinutes":\(currentDay.durationMinutes),"isRestDay":false,"caloriesBurned":\(currentDay.caloriesBurned),"exercises":[{"name":"...","sets":4,"reps":"8-10","restSeconds":90,"muscleGroups":["Chest"],"category":"main","difficulty":"Intermediate","exerciseDescription":"...","formTips":["..."],"loadTips":["..."],"durationMinutes":0}]}
        category must be: warmup, main, or cooldown.
        All text in \(aiLanguageName).
        """

        for attempt in 0..<3 {
            do {
                let rawText = try await KimiService.chatCompletion(prompt: prompt, timeout: 120)
                let jsonText = extractJSON(from: rawText)
                if let day = parseSingleWorkoutDayJSON(jsonText) {
                    return day
                }
            } catch {
                if attempt < 2 { try? await Task.sleep(for: .seconds(Double(attempt + 1) * 2.0)) }
            }
        }
        throw AIServiceError.networkError("Failed to modify session.")
    }

    static func parseSingleWorkoutDayJSON(_ jsonText: String) -> WorkoutDay? {
        guard let jsonData = jsonText.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else { return nil }

        let dayName = obj["dayName"] as? String ?? ""
        let focus = obj["focus"] as? String ?? ""
        let duration = obj["durationMinutes"] as? Int ?? 0
        let isRest = obj["isRestDay"] as? Bool ?? false
        let calories = obj["caloriesBurned"] as? Int ?? 0

        guard let exercisesArr = obj["exercises"] as? [[String: Any]] else { return nil }

        var exercises: [Exercise] = []
        for exObj in exercisesArr {
            let name = exObj["name"] as? String ?? "Exercise"
            let sets = exObj["sets"] as? Int ?? 3
            let reps = exObj["reps"] as? String ?? "10"
            let rest = exObj["restSeconds"] as? Int ?? 60
            let muscles = exObj["muscleGroups"] as? [String] ?? []
            let catRaw = (exObj["category"] as? String ?? "main").lowercased()
            let cat: ExerciseCategory = catRaw.contains("warm") ? .warmup : catRaw.contains("cool") ? .cooldown : .main
            let diff = exObj["difficulty"] as? String ?? ""
            let desc = exObj["exerciseDescription"] as? String ?? ""
            let tips = exObj["formTips"] as? [String] ?? []
            let load = exObj["loadTips"] as? [String] ?? []
            let dur = exObj["durationMinutes"] as? Int ?? 0

            exercises.append(Exercise(
                name: name, sets: sets, reps: reps, restSeconds: rest,
                muscleGroups: muscles, category: cat, difficulty: diff,
                exerciseDescription: desc, formTips: tips, loadTips: load, durationMinutes: dur
            ))
        }

        guard !exercises.isEmpty else { return nil }

        return WorkoutDay(
            dayName: dayName, focus: focus, durationMinutes: duration,
            exercises: exercises, isRestDay: isRest, caloriesBurned: calories
        )
    }

    static func suggestExercises(userRequest: String, currentDay: WorkoutDay, profile: UserProfile) async throws -> [Exercise] {
        let exerciseSummary = currentDay.exercises.map { $0.name }.joined(separator: ", ")

        let prompt = """
        You are a fitness expert. The user wants to add an exercise to their workout day.
        Analyze their request and suggest exercises.

        Profile: \(profile.gender.rawValue), \(Int(profile.currentWeightKg))kg, Age=\(profile.age), Goal=\(profile.goal.rawValue)
        Today's session: \(currentDay.dayName) — \(currentDay.focus)
        Current exercises: \(exerciseSummary)

        User request: "\(userRequest)"

        RULES:
        - If the request is SPECIFIC (e.g. "bench press", "squat 4x8"), return exactly 1 exercise matching what they asked.
        - If the request is GENERIC or VAGUE (e.g. "chest exercise", "something for legs", "an ab exercise"), return exactly 3 different exercise options for the user to choose from.
        - Never return more than 3 exercises.
        - Each exercise must be complete with sets, reps, rest, muscle groups, difficulty, description, and form tips.
        - Do NOT include exercises already in the current plan: \(exerciseSummary)
        - All text in \(aiLanguageName).

        Return ONLY valid JSON array:
        [{"name":"Exercise Name","sets":4,"reps":"8-10","restSeconds":90,"muscleGroups":["Chest","Triceps"],"category":"main","difficulty":"Intermediate","exerciseDescription":"Brief description","formTips":["Tip 1"],"loadTips":["Suggested load"],"durationMinutes":0}]
        """

        if useKimi {
            for attempt in 0..<3 {
                do {
                    let rawText = try await KimiService.chatCompletion(prompt: prompt, timeout: 60)
                    let jsonText = extractJSON(from: rawText)
                    if let exercises = parseExerciseSuggestions(from: jsonText) {
                        return exercises
                    }
                } catch {
                    if attempt < 2 { try? await Task.sleep(for: .seconds(Double(attempt + 1) * 1.5)) }
                }
            }
            throw AIServiceError.networkError("Failed to get exercise suggestions.")
        }

        guard !toolkitURL.isEmpty, let url = URL(string: toolkitURL + "/agent/chat") else {
            throw AIServiceError.networkError("AI service not configured.")
        }

        let body = buildTextRequestBody(prompt: prompt)
        for attempt in 0..<3 {
            do {
                let rawText = try await sendToolkitRequest(url: url, body: body, timeout: 60)
                let jsonText = extractJSON(from: rawText)
                if let exercises = parseExerciseSuggestions(from: jsonText) {
                    return exercises
                }
            } catch {
                if attempt < 2 { try? await Task.sleep(for: .seconds(Double(attempt + 1) * 1.5)) }
            }
        }
        throw AIServiceError.networkError("Failed to get exercise suggestions.")
    }

    private static func parseExerciseSuggestions(from jsonText: String) -> [Exercise]? {
        let text = jsonText.trimmingCharacters(in: .whitespacesAndNewlines)
        var arrayText = text
        if text.hasPrefix("{") {
            arrayText = "[\(text)]"
        }
        if !arrayText.hasPrefix("[") {
            if let startIdx = arrayText.firstIndex(of: "[") {
                arrayText = String(arrayText[startIdx...])
            }
        }
        if let endIdx = arrayText.lastIndex(of: "]") {
            arrayText = String(arrayText[...endIdx])
        }

        guard let data = arrayText.data(using: .utf8),
              let arr = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]],
              !arr.isEmpty else { return nil }

        var exercises: [Exercise] = []
        for obj in arr.prefix(3) {
            let name = obj["name"] as? String ?? "Exercise"
            let sets = (obj["sets"] as? Int) ?? Int((obj["sets"] as? Double) ?? 3)
            let reps = obj["reps"] as? String ?? "10"
            let rest = (obj["restSeconds"] as? Int) ?? Int((obj["restSeconds"] as? Double) ?? 60)
            let muscles = obj["muscleGroups"] as? [String] ?? []
            let catRaw = (obj["category"] as? String ?? "main").lowercased()
            let cat: ExerciseCategory = catRaw.contains("warm") ? .warmup : catRaw.contains("cool") ? .cooldown : .main
            let diff = obj["difficulty"] as? String ?? "Intermediate"
            let desc = obj["exerciseDescription"] as? String ?? ""
            let tips = obj["formTips"] as? [String] ?? []
            let load = obj["loadTips"] as? [String] ?? []
            let dur = (obj["durationMinutes"] as? Int) ?? Int((obj["durationMinutes"] as? Double) ?? 0)

            exercises.append(Exercise(
                name: name, sets: sets, reps: reps, restSeconds: rest,
                muscleGroups: muscles, category: cat, difficulty: diff,
                exerciseDescription: desc, formTips: tips, loadTips: load, durationMinutes: dur
            ))
        }
        return exercises.isEmpty ? nil : exercises
    }

    static func exerciseChatReply(chatHistory: [[String: String]], currentDay: WorkoutDay, profile: UserProfile) async throws -> ExerciseChatResponse {
        let exerciseSummary = currentDay.exercises.map { $0.name }.joined(separator: ", ")
        let lang = aiLanguageName

        let systemPrompt = """
        You are a friendly fitness expert AI assistant helping a user add an exercise to their workout.
        You must ALWAYS respond in \(lang).

        User profile: \(profile.gender.rawValue), \(Int(profile.currentWeightKg))kg, Age=\(profile.age), Goal=\(profile.goal.rawValue)
        Today's session: \(currentDay.dayName) — \(currentDay.focus)
        Current exercises: \(exerciseSummary.isEmpty ? "None" : exerciseSummary)

        CONVERSATION RULES:
        1. Have a natural conversation to understand what exercise the user wants.
        2. If the user is vague (e.g. "something for chest"), ask clarifying questions one at a time: which specific movement, preferred sets/reps, difficulty level, etc.
        3. Keep questions SHORT (1-2 sentences max). Be conversational and friendly.
        4. Do NOT suggest exercises already in the plan: \(exerciseSummary)
        5. When you have enough info to define a complete exercise, OR the user gives a specific exercise name with details, include the exercise JSON in your response.

        RESPONSE FORMAT — ALWAYS return valid JSON:
        {
            "message": "Your conversational reply to the user in \(lang)",
            "exerciseReady": false
        }

        When the exercise is fully defined:
        {
            "message": "Here's the exercise I've prepared for you!",
            "exerciseReady": true,
            "exercise": {
                "name": "Exercise Name",
                "sets": 4,
                "reps": "8-10",
                "restSeconds": 90,
                "muscleGroups": ["Chest", "Triceps"],
                "category": "main",
                "difficulty": "Intermediate",
                "exerciseDescription": "Brief description",
                "formTips": ["Tip 1"],
                "durationMinutes": 0
            }
        }

        Return ONLY the JSON object. No markdown, no extra text.
        """

        let messages = chatHistory.map { dict -> [String: Any] in
            return dict as [String: Any]
        }

        var rawText: String
        if useKimi {
            rawText = try await KimiService.multiTurnChat(messages: messages, systemPrompt: systemPrompt, timeout: 60)
            let cleaned = rawText
                .replacingOccurrences(of: "```json", with: "")
                .replacingOccurrences(of: "```", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            return parseExerciseChatResponse(cleaned)
        } else {
            guard !toolkitURL.isEmpty, let url = URL(string: toolkitURL + "/agent/chat") else {
                throw AIServiceError.networkError("AI service not configured.")
            }
            let fullMessages: [[String: Any]] = [
                ["role": "user", "content": systemPrompt + "\n\nConversation so far:\n" + chatHistory.map { "\($0["role"] ?? ""): \($0["content"] ?? "")" }.joined(separator: "\n")]
            ]
            let body: [String: Any] = ["messages": fullMessages]
            rawText = try await sendToolkitRequest(url: url, body: body, timeout: 60)
            let jsonText = extractJSON(from: rawText)
            return parseExerciseChatResponse(jsonText)
        }
    }

    private static func parseExerciseChatResponse(_ text: String) -> ExerciseChatResponse {
        let cleaned = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let data = cleaned.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return ExerciseChatResponse(message: cleaned.isEmpty ? "..." : cleaned, exerciseReady: false, exercise: nil)
        }

        let message = obj["message"] as? String ?? "..."
        let ready = obj["exerciseReady"] as? Bool ?? false
        var exercise: Exercise?

        if ready, let exObj = obj["exercise"] as? [String: Any] {
            let name = exObj["name"] as? String ?? "Exercise"
            let sets = (exObj["sets"] as? Int) ?? Int((exObj["sets"] as? Double) ?? 3)
            let reps = exObj["reps"] as? String ?? "10"
            let rest = (exObj["restSeconds"] as? Int) ?? Int((exObj["restSeconds"] as? Double) ?? 60)
            let muscles = exObj["muscleGroups"] as? [String] ?? []
            let catRaw = (exObj["category"] as? String ?? "main").lowercased()
            let cat: ExerciseCategory = catRaw.contains("warm") ? .warmup : catRaw.contains("cool") ? .cooldown : .main
            let diff = exObj["difficulty"] as? String ?? "Intermediate"
            let desc = exObj["exerciseDescription"] as? String ?? ""
            let tips = exObj["formTips"] as? [String] ?? []
            let dur = (exObj["durationMinutes"] as? Int) ?? Int((exObj["durationMinutes"] as? Double) ?? 0)

            exercise = Exercise(
                name: name, sets: sets, reps: reps, restSeconds: rest,
                muscleGroups: muscles, category: cat, difficulty: diff,
                exerciseDescription: desc, formTips: tips, durationMinutes: dur
            )
        }

        return ExerciseChatResponse(message: message, exerciseReady: ready, exercise: exercise)
    }

    static func suggestIngredientSubstitutes(ingredient: Ingredient, mealName: String, profile: UserProfile) async throws -> [Ingredient] {
        let aiResult = try? await suggestIngredientSubstitutesFromAI(ingredient: ingredient, mealName: mealName, profile: profile)
        if let result = aiResult, !result.isEmpty {
            return result
        }
        return localIngredientSubstitutes(for: ingredient)
    }

    private static func suggestIngredientSubstitutesFromAI(ingredient: Ingredient, mealName: String, profile: UserProfile) async throws -> [Ingredient] {
        guard !toolkitURL.isEmpty, let url = URL(string: toolkitURL + "/agent/chat") else {
            throw AIServiceError.networkError("AI service not configured.")
        }

        let prompt = """
        You are a nutrition expert. Suggest exactly 3 alternative ingredients to replace "\(ingredient.name)" (\(String(format: "%.0f", ingredient.amount))\(ingredient.unit), \(ingredient.calories) kcal) in the meal "\(mealName)".
        User goal: \(profile.goal.rawValue), diet: \(profile.dietType.rawValue).

        Rules:
        - Similar calories (within ±30%)
        - Same meal context
        - Common ingredients

        RESPOND WITH ONLY THIS JSON, nothing else:
        [{"name":"Name","amount":100.0,"unit":"g","calories":150},{"name":"Name2","amount":120.0,"unit":"g","calories":140},{"name":"Name3","amount":80.0,"unit":"g","calories":160}]
        All names in \(aiLanguageName). No markdown, no explanation, ONLY the JSON array.
        """

        let body = buildTextRequestBody(prompt: prompt)
        let rawText = try await sendToolkitRequest(url: url, body: body, timeout: 60)
        let streamText = extractStreamText(from: rawText)
        let cleanedText = streamText
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let jsonString = extractJSONArray(from: cleanedText)

        guard let jsonData = jsonString.data(using: .utf8) else {
            return []
        }

        if let arr = try? JSONSerialization.jsonObject(with: jsonData) as? [[String: Any]] {
            let parsed = parseIngredientArray(arr)
            if !parsed.isEmpty { return parsed }
        }

        if let wrapper = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
           let arr = wrapper["ingredients"] as? [[String: Any]] ?? wrapper["substitutes"] as? [[String: Any]] {
            let parsed = parseIngredientArray(arr)
            if !parsed.isEmpty { return parsed }
        }

        return []
    }

    private static func localIngredientSubstitutes(for ingredient: Ingredient) -> [Ingredient] {
        let name = ingredient.name.lowercased()
        let cal = ingredient.calories
        let amt = ingredient.amount
        let unit = ingredient.unit

        let proteinSources: [(String, Int)] = [
            ("Petto di pollo", 165), ("Petto di tacchino", 135), ("Tofu", 76),
            ("Salmone", 208), ("Tonno al naturale", 116), ("Uova", 155),
            ("Ricotta", 174), ("Yogurt greco", 97), ("Tempeh", 192),
            ("Seitan", 370), ("Gamberi", 99), ("Merluzzo", 82),
            ("Bresaola", 151), ("Lenticchie cotte", 116), ("Ceci cotti", 164)
        ]
        let carbSources: [(String, Int)] = [
            ("Riso basmati", 130), ("Pasta integrale", 124), ("Quinoa", 120),
            ("Patate dolci", 86), ("Farro", 128), ("Couscous", 112),
            ("Pane integrale", 247), ("Avena", 389), ("Orzo", 123),
            ("Bulgur", 83), ("Miglio", 119), ("Gnocchi", 133)
        ]
        let fatSources: [(String, Int)] = [
            ("Avocado", 160), ("Olio d'oliva", 884), ("Mandorle", 579),
            ("Noci", 654), ("Semi di chia", 486), ("Burro di arachidi", 588),
            ("Semi di lino", 534), ("Anacardi", 553), ("Pistacchi", 562),
            ("Cocco grattugiato", 354), ("Olive", 115), ("Tahini", 595)
        ]
        let vegSources: [(String, Int)] = [
            ("Broccoli", 34), ("Spinaci", 23), ("Zucchine", 17),
            ("Peperoni", 31), ("Pomodori", 18), ("Carote", 41),
            ("Cavolfiore", 25), ("Lattuga", 15), ("Cetrioli", 16),
            ("Melanzane", 25), ("Fagiolini", 31), ("Asparagi", 20)
        ]

        var pool: [(String, Int)]
        if name.contains("pollo") || name.contains("tacchino") || name.contains("manzo") || name.contains("pesce") || name.contains("salmone") || name.contains("tonno") || name.contains("uov") || name.contains("tofu") || name.contains("gamberi") || name.contains("merluzzo") || name.contains("bresaola") || name.contains("prosciutto") {
            pool = proteinSources
        } else if name.contains("riso") || name.contains("pasta") || name.contains("pane") || name.contains("patata") || name.contains("quinoa") || name.contains("farro") || name.contains("avena") || name.contains("gnocchi") || name.contains("couscous") {
            pool = carbSources
        } else if name.contains("olio") || name.contains("avocado") || name.contains("mandorl") || name.contains("noc") || name.contains("semi") || name.contains("burro") || name.contains("olive") {
            pool = fatSources
        } else if name.contains("broccol") || name.contains("spinac") || name.contains("zucchin") || name.contains("peperoni") || name.contains("pomodor") || name.contains("carot") || name.contains("lattug") || name.contains("insalata") || name.contains("verdur") {
            pool = vegSources
        } else if cal > 300 {
            pool = fatSources + proteinSources
        } else if cal > 100 {
            pool = proteinSources + carbSources
        } else {
            pool = vegSources + proteinSources
        }

        let filtered = pool.filter { !$0.0.lowercased().contains(name) && !name.contains($0.0.lowercased()) }
        let source = filtered.isEmpty ? pool : filtered
        let shuffled = source.shuffled()
        let selected = Array(shuffled.prefix(3))

        return selected.map { item in
            let ratio = amt / 100.0
            let adjustedCal = Int(Double(item.1) * ratio)
            return Ingredient(name: item.0, amount: amt, unit: unit, calories: adjustedCal)
        }
    }

    private static func extractStreamText(from rawText: String) -> String {
        var accumulated = ""
        let lines = rawText.components(separatedBy: "\n")
        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty else { continue }
            if trimmed.hasPrefix("0:") {
                let jsonEncoded = String(trimmed.dropFirst(2))
                if let d = jsonEncoded.data(using: .utf8),
                   let decoded = try? JSONDecoder().decode(String.self, from: d) {
                    accumulated += decoded
                }
            } else if trimmed.hasPrefix("d:") || trimmed.hasPrefix("e:") || trimmed.hasPrefix("f:") {
                continue
            } else if trimmed.hasPrefix("data: ") {
                let content = String(trimmed.dropFirst(6))
                guard content != "[DONE]" else { continue }
                if let d = content.data(using: .utf8),
                   let json = try? JSONSerialization.jsonObject(with: d) as? [String: Any] {
                    if let delta = json["textDelta"] as? String {
                        accumulated += delta
                    } else if let choices = json["choices"] as? [[String: Any]],
                              let delta = choices.first?["delta"] as? [String: Any],
                              let c = delta["content"] as? String {
                        accumulated += c
                    }
                }
            }
        }
        if accumulated.isEmpty {
            if let d = rawText.data(using: .utf8),
               let obj = try? JSONSerialization.jsonObject(with: d) as? [String: Any] {
                let textKeys = ["text", "content", "message", "response", "output", "result"]
                for key in textKeys {
                    if let inner = obj[key] as? String, !inner.isEmpty {
                        return inner
                    }
                }
            }
            return rawText
        }
        return accumulated
    }

    private static func extractJSONArray(from text: String) -> String {
        guard let startIdx = text.firstIndex(of: "[") else { return text }
        var depth = 0
        var inString = false
        var escape = false
        var idx = startIdx
        while idx < text.endIndex {
            let ch = text[idx]
            if escape {
                escape = false
            } else if ch == "\\" && inString {
                escape = true
            } else if ch == "\"" {
                inString.toggle()
            } else if !inString {
                if ch == "[" { depth += 1 }
                else if ch == "]" {
                    depth -= 1
                    if depth == 0 {
                        return String(text[startIdx...idx])
                    }
                }
            }
            idx = text.index(after: idx)
        }
        return text
    }

    private static func parseIngredientArray(_ arr: [[String: Any]]) -> [Ingredient] {
        arr.compactMap { obj in
            guard let name = obj["name"] as? String else { return nil }
            let amount = (obj["amount"] as? Double) ?? Double((obj["amount"] as? Int) ?? 100)
            let unit = (obj["unit"] as? String) ?? "g"
            let calories = (obj["calories"] as? Int) ?? Int((obj["calories"] as? Double) ?? 0)
            return Ingredient(name: name, amount: amount, unit: unit, calories: calories)
        }
    }

    static func parseModifiedWorkoutResponse(_ jsonText: String) -> (modifications: ScanPlanModifications, modifiedPlan: WorkoutPlan)? {
        guard let jsonData = jsonText.data(using: .utf8),
              let obj = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else { return nil }

        let mods: ScanPlanModifications
        if let modsObj = obj["modifications"] as? [String: Any],
           let modsData = try? JSONSerialization.data(withJSONObject: modsObj),
           let decoded = try? JSONDecoder().decode(ScanPlanModifications.self, from: modsData) {
            mods = decoded
        } else {
            mods = ScanPlanModifications(nutritionSummary: "", workoutSummary: "", nutritionChanges: [], workoutChanges: [])
        }

        guard let daysArr = obj["days"] as? [[String: Any]] else { return nil }

        let wrappedObj: [String: Any] = ["days": daysArr]
        guard let wrappedData = try? JSONSerialization.data(withJSONObject: wrappedObj) else { return nil }

        let wrappedText = String(data: wrappedData, encoding: .utf8) ?? ""
        if let plan = parseWorkoutPlanJSON(wrappedText) {
            return (mods, plan)
        }
        return nil
    }
}
