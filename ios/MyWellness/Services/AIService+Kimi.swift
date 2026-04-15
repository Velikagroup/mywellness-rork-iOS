import Foundation
import UIKit

extension AIService {

    static func analyzeCaloriesWithKimi(imageBase64: String) async throws -> CalorieAnalysisResult {
        var lastError: Error?
        for attempt in 0..<3 {
            do {
                let result = try await performCalorieAnalysisWithKimi(imageBase64: imageBase64)
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

    private static func performCalorieAnalysisWithKimi(imageBase64: String) async throws -> CalorieAnalysisResult {
        let step1Prompt = """
        You are a food recognition expert. Analyze this photo and identify EVERY visible food item.
        For each item, estimate the approximate portion size.
        Return ONLY a raw JSON object with this format:
        {"foods":[{"name":"Food name","portion":"estimated portion like 150g or 1 cup"}],"mealDescription":"Brief description of the overall meal"}
        Be specific. List each food item separately. If you see a plate with multiple items, list each one.
        """

        let step1RawText = try await KimiService.visionCompletion(prompt: step1Prompt, imageBase64Strings: [imageBase64], timeout: 90)
        let step1JSON = extractFoodJSON(from: step1RawText)

        var foodList = step1JSON
        if let data = step1JSON.data(using: String.Encoding.utf8),
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

        let step2RawText = try await KimiService.chatCompletion(prompt: step2Prompt, timeout: 90)
        let step2JSON = extractFoodJSON(from: step2RawText)
        let result = parseCalorieResult(from: step2JSON)
        if result.calories == 0 && result.foodName == "Detected Meal" {
            throw AIServiceError.decodingError
        }
        return result
    }

    static func lookupIngredientNutritionWithKimi(name: String) async throws -> ScannedIngredient {
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

        let rawText = try await KimiService.chatCompletion(prompt: prompt, timeout: 30)
        let jsonText = extractJSON(from: rawText)

        guard let jsonData = jsonText.data(using: String.Encoding.utf8),
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

    static func analyzeNutritionTableWithKimi(imageBase64: String) async throws -> NutritionTableResult {
        let prompt = """
        Read this nutrition label. Return ONLY raw JSON:
        {"productName":"Name","servingSize":"100g","calories":250,"totalFat":8.0,"saturatedFat":3.0,"carbohydrates":35.0,"sugars":12.0,"protein":10.0,"salt":0.5,"fiber":3.0}
        Read exact values from label. Use 0 for missing values.
        """

        let rawText = try await KimiService.visionCompletion(prompt: prompt, imageBase64Strings: [imageBase64], timeout: 90)
        let jsonText = extractJSON(from: rawText)

        guard let jsonData = jsonText.data(using: String.Encoding.utf8),
              let result = try? JSONDecoder().decode(NutritionTableResult.self, from: jsonData) else {
            return NutritionTableResult(
                productName: "Product", servingSize: "100g", calories: 250,
                totalFat: 8, saturatedFat: 3, carbohydrates: 35,
                sugars: 12, protein: 10, salt: 0.5, fiber: 3
            )
        }
        return result
    }

    static func analyzeFullBodyScanWithKimi(frontBase64: String?, rightBase64: String?, backBase64: String?, leftBase64: String?, profile: UserProfile) async throws -> BodyScan2Result {
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
        - fatDistributionSummary: A detailed description of WHERE fat is stored on the body (e.g. "Fat primarily concentrated in the lower abdomen and inner thighs, with moderate accumulation around hips and minimal upper body fat")
        - bloatingAreas: List of specific body areas showing signs of bloating/water retention (e.g. ["Lower abdomen", "Ankles", "Face"])
        - strongPoints: 5-7 specific strengths observed (be VERY specific, reference exact body parts)
        - weakPoints: 5-7 specific weak points (be VERY specific, mention exact muscles/areas that need work)

        Return ONLY raw JSON:
        {"somatotype":"Mesomorph","estimatedBodyFat":"19-20%","biologicalAge":"25","muscleDefinition":"Moderate","bloatingPercentage":"10-15%","skinTexture":"Normal, well hydrated","strongPoints":["Well-developed deltoids with good roundness","Proportioned quadriceps with visible separation"],"weakPoints":["Undefined lower abdomen with visible fat accumulation","Gluteal muscles lack volume and firmness","Inner thighs show excess fat"],"overallAssessment":"Detailed assessment in \(aiLanguageName)","posturalNotes":"Postural notes in \(aiLanguageName)","fatDistributionSummary":"Detailed fat distribution description in \(aiLanguageName)","bloatingAreas":["Lower abdomen","Ankles"],"bodyRegions":[{"region":"Shoulders & Arms","muscleDefinition":"Good deltoid development, biceps partially visible","fatDistribution":"Minimal fat on arms","bloating":"None","score":7,"notes":"Detailed notes","improvementTips":["Tip 1","Tip 2"]},{"region":"Chest","muscleDefinition":"Moderate","fatDistribution":"Light fat layer","bloating":"None","score":6,"notes":"Notes","improvementTips":["Tip"]},{"region":"Abdomen","muscleDefinition":"Low","fatDistribution":"Concentrated in lower abs","bloating":"Moderate in lower area","score":4,"notes":"Notes","improvementTips":["Tip"]},{"region":"Back","muscleDefinition":"Moderate lat width","fatDistribution":"Light fat on lower back","bloating":"None","score":6,"notes":"Notes","improvementTips":["Tip"]},{"region":"Glutes","muscleDefinition":"Needs more development","fatDistribution":"Moderate around hips","bloating":"None","score":5,"notes":"Gluteal muscles lack volume","improvementTips":["Hip thrusts 3x12","Bulgarian split squats"]},{"region":"Upper Legs","muscleDefinition":"Moderate quad definition","fatDistribution":"Inner thigh fat accumulation","bloating":"Minimal","score":6,"notes":"Notes","improvementTips":["Tip"]},{"region":"Lower Legs","muscleDefinition":"Calves well developed","fatDistribution":"Minimal","bloating":"None","score":7,"notes":"Notes","improvementTips":["Tip"]}],"dailyCalories":\(Int(profile.dailyCalorieTarget)),"proteinGrams":\(Int(profile.proteinTarget)),"carbsGrams":\(Int(profile.carbsTarget)),"fatGrams":\(Int(profile.fatTarget)),"nutritionRecommendations":["Rec 1 in \(aiLanguageName)","Rec 2"],"sampleMeals":[{"name":"Protein breakfast","type":"breakfast","calories":450,"description":"Description in \(aiLanguageName)"}],"trainingDaysPerWeek":4,"trainingSplit":"Upper/Lower Split","focusAreas":["Chest","Legs"],"sampleExercises":[{"name":"Bench Press","sets":4,"reps":"8-10","muscleGroup":"Chest"}],"trainingRecommendations":["Rec 1 in \(aiLanguageName)"]}

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
        - strongPoints: array of 5-7 VERY SPECIFIC physical strong points observed in the photos, in \(aiLanguageName). Reference exact muscles and body parts.
        - weakPoints: array of 5-7 VERY SPECIFIC physical weak points/areas to improve observed in the photos, in \(aiLanguageName). Reference exact muscles and body parts.
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

        let rawText = try await KimiService.visionCompletion(prompt: prompt, imageBase64Strings: images, timeout: 180)
        let jsonText = extractJSON(from: rawText)

        guard let jsonData = jsonText.data(using: String.Encoding.utf8),
              let result = try? JSONDecoder().decode(BodyScan2Result.self, from: jsonData) else {
            return BodyScan2Result.fallback()
        }
        return result
    }

    static func generateMealPlanWithKimi(for profile: UserProfile, quizPreferences: MealPlanQuizPreferences? = nil) async throws -> NutritionPlan {
        var dietInfo = profile.dietType.rawValue
        var intolerancesInfo = ""
        var fastingInfo = ""
        var mealsInfo = "Include breakfast, lunch, and dinner for each day."
        var cookingInfo = ""
        var cheatMealInfo = ""

        if let quiz = quizPreferences {
            if !quiz.dietType.isEmpty { dietInfo = quiz.dietType }
            if !quiz.intolerances.isEmpty || !quiz.customIntolerances.isEmpty {
                var allIntolerances = quiz.intolerances
                if !quiz.customIntolerances.isEmpty { allIntolerances.append(quiz.customIntolerances) }
                intolerancesInfo = "\n- Food intolerances/allergies: \(allIntolerances.joined(separator: ", ")). NEVER include these foods or derivatives."
            }
            let totalKcal = Int(profile.dailyCalorieTarget)
            if quiz.wantsFasting {
                let window = quiz.fastingWindow == .skipBreakfast ? "12:00-20:00 (skip breakfast)" : "08:00-16:00 (skip dinner)"
                fastingInfo = "\n- Intermittent fasting: 16/8 protocol, eating window \(window)"
                switch quiz.mealsCount {
                case 1:
                    mealsInfo = quiz.fastingWindow == .skipBreakfast
                        ? "Include exactly 1 meal per day: lunch (\(totalKcal) kcal)."
                        : "Include exactly 1 meal per day: breakfast (\(totalKcal) kcal)."
                case 2:
                    let perMeal = totalKcal / 2
                    mealsInfo = quiz.fastingWindow == .skipBreakfast
                        ? "Include exactly 2 meals per day: lunch (\(perMeal) kcal) and dinner (\(perMeal) kcal)."
                        : "Include exactly 2 meals per day: breakfast (\(perMeal) kcal) and lunch (\(perMeal) kcal)."
                case 3:
                    let mainKcal = Int(Double(totalKcal) * 0.4)
                    let snackKcal = totalKcal - mainKcal * 2
                    mealsInfo = quiz.fastingWindow == .skipBreakfast
                        ? "Include exactly 3 meals: lunch (\(mainKcal) kcal), snack (\(snackKcal) kcal), dinner (\(mainKcal) kcal)."
                        : "Include exactly 3 meals: breakfast (\(mainKcal) kcal), snack (\(snackKcal) kcal), lunch (\(mainKcal) kcal)."
                default:
                    let perMeal = totalKcal / 2
                    mealsInfo = quiz.fastingWindow == .skipBreakfast
                        ? "Include exactly 2 meals per day: lunch (\(perMeal) kcal) and dinner (\(perMeal) kcal)."
                        : "Include exactly 2 meals per day: breakfast (\(perMeal) kcal) and lunch (\(perMeal) kcal)."
                }
            } else {
                let perMeal = totalKcal / max(quiz.mealsCount, 1)
                switch quiz.mealsCount {
                case 1: mealsInfo = "Include exactly 1 meal per day: lunch (\(totalKcal) kcal)."
                case 2: mealsInfo = "Include exactly 2 meals per day: lunch (\(perMeal) kcal) and dinner (\(perMeal) kcal)."
                case 3: mealsInfo = "Include exactly 3 meals per day: breakfast (\(perMeal) kcal), lunch (\(perMeal) kcal), and dinner (\(perMeal) kcal)."
                case 4:
                    let mainKcal = Int(Double(totalKcal) * 0.3)
                    let snackKcal = totalKcal - mainKcal * 3
                    mealsInfo = "Include exactly 4 meals: breakfast (\(mainKcal) kcal), lunch (\(mainKcal) kcal), snack (\(snackKcal) kcal), dinner (\(mainKcal) kcal)."
                case 5:
                    let mainKcal = Int(Double(totalKcal) * 0.27)
                    let snackKcal = (totalKcal - mainKcal * 3) / 2
                    mealsInfo = "Include exactly 5 meals: breakfast (\(mainKcal) kcal), snack (\(snackKcal) kcal), lunch (\(mainKcal) kcal), snack (\(snackKcal) kcal), dinner (\(mainKcal) kcal)."
                default: mealsInfo = "Include breakfast, lunch, and dinner for each day."
                }
            }
            switch quiz.cookingTime {
            case .quick: cookingInfo = "\n- Cooking time: Quick recipes only (10-20 minutes max)"
            case .moderate: cookingInfo = "\n- Cooking time: Moderate recipes (20-30 minutes)"
            case .relaxed: cookingInfo = "\n- Cooking time: Elaborate recipes allowed (30+ minutes)"
            }
            if let cheat = quiz.cheatMeal {
                let dayMap = ["Mon": "Monday", "Tue": "Tuesday", "Wed": "Wednesday", "Thu": "Thursday", "Fri": "Friday", "Sat": "Saturday", "Sun": "Sunday"]
                let fullDay = dayMap[cheat.day] ?? cheat.day
                cheatMealInfo = "\n- Free meal: On \(fullDay) \(cheat.mealType.lowercased()), DO NOT generate any meal. Instead put a placeholder with name \"Pasto Libero\", calories 0, protein 0, carbs 0, fat 0, prepTime 0, difficulty Easy, empty ingredients array."
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

        let targetKcal = Int(profile.dailyCalorieTarget)
        var lastError: Error?
        for attempt in 0..<3 {
            do {
                let rawText = try await KimiService.chatCompletion(prompt: prompt, timeout: 180)
                let jsonText = extractJSON(from: rawText)
                if var plan = parseMealPlanJSON(jsonText) {
                    plan = normalizePlanCalories(plan, target: targetKcal)
                    return plan
                }
            } catch {
                lastError = error
            }
            if attempt < 2 {
                try? await Task.sleep(for: .seconds(Double(attempt + 1) * 2.0))
            }
        }
        if let err = lastError { throw err }
        return DefaultData.nutritionPlan(for: profile)
    }

    static func generateWorkoutPlanWithKimi(for profile: UserProfile, workoutQuizPreferences: WorkoutQuizPreferences? = nil) async throws -> WorkoutPlan {
        var sportInfo = ""
        var goalInfo = profile.goal.rawValue
        var extraInfo = ""

        if let quiz = workoutQuizPreferences {
            if !quiz.fitnessGoal.isEmpty { goalInfo = quiz.fitnessGoal }
            if quiz.isPerformance == true, !quiz.selectedSport.isEmpty {
                sportInfo = "\n- Training style: \(quiz.selectedSport) (performance-oriented)"
                if !quiz.sportAnswers.isEmpty {
                    let answers = quiz.sportAnswers.map { "\($0.key): \($0.value)" }.joined(separator: ", ")
                    sportInfo += "\n- Sport-specific data: \(answers)"
                }
            }
            if !quiz.trainingFrequency.isEmpty { extraInfo += "\n- Current training frequency: \(quiz.trainingFrequency)" }
            if !quiz.strengthLevel.isEmpty { extraInfo += "\n- Strength level: \(quiz.strengthLevel)" }
            if quiz.daysPerWeek > 0 { extraInfo += "\n- Desired training days per week: \(quiz.daysPerWeek)" }
            if !quiz.preferredDays.isEmpty { extraInfo += "\n- Preferred days: \(quiz.preferredDays.joined(separator: ", "))" }
            if !quiz.sessionDuration.isEmpty { extraInfo += "\n- Session duration: \(quiz.sessionDuration) minutes" }
            if !quiz.trainingLocation.isEmpty { extraInfo += "\n- Training location: \(quiz.trainingLocation)" }
            if !quiz.equipmentCategory.isEmpty { extraInfo += "\n- Equipment: \(quiz.equipmentCategory)" }
            if !quiz.jointPain.isEmpty { extraInfo += "\n- Joint pain: \(quiz.jointPain.joined(separator: ", ")). AVOID exercises that stress these areas." }
        }

        let daysCount = workoutQuizPreferences?.daysPerWeek ?? 7
        let preferredDaysList = workoutQuizPreferences?.preferredDays ?? ["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"]
        let durationMin = Int(workoutQuizPreferences?.sessionDuration ?? "45") ?? 45

        let prompt = """
        Generate a 7-day workout plan. Return ONLY valid JSON, no markdown.
        Profile: Goal=\(goalInfo), \(profile.gender.rawValue), \(Int(profile.currentWeightKg))kg, Age=\(profile.age)\(sportInfo)\(extraInfo)
        JSON format: {"days":[{"dayName":"Monday","focus":"Chest & Triceps","durationMinutes":60,"isRestDay":false,"caloriesBurned":350,"exercises":[{"name":"Bench Press","sets":4,"reps":"8-10","restSeconds":90,"muscleGroups":["Chest","Triceps"],"category":"main","difficulty":"Intermediate","exerciseDescription":"Flat barbell bench press","formTips":["Keep shoulder blades retracted"],"durationMinutes":0}]}]}
        category must be: warmup, main, or cooldown. Include 1-2 warmup, 4-6 main, 1-2 cooldown exercises per day.
        7 days Monday-Sunday. The user wants to train \(daysCount) days. Make the other days rest days (isRestDay=true, minimal exercises). Preferred training days: \(preferredDaysList.joined(separator: ", ")). Target session duration: ~\(durationMin) min.
        """

        var lastError: Error?
        for attempt in 0..<3 {
            do {
                let rawText = try await KimiService.chatCompletion(prompt: prompt, timeout: 180)
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
        if let err = lastError { throw err }
        return WorkoutLocalization.localizePlan(DefaultData.workoutPlan(for: profile))
    }

    static func generateScanBasedMealPlanWithKimi(scanResult: BodyScan2Result, profile: UserProfile, quizPreferences: MealPlanQuizPreferences? = nil) async throws -> NutritionPlan {
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
        IMPORTANT: Adapt the nutrition plan specifically to address the weak points and body composition findings.
        Include breakfast, lunch, dinner, and 1-2 snacks per day.
        IMPORTANT: Each day MUST have DIFFERENT meals. Never repeat the same dish on multiple days. Vary dishes, ingredients, cuisines and cooking styles across the 7 days. Slight natural variations in macros between days (+/- 5-15%) are encouraged.
        JSON format: {"days":[{"dayName":"Monday","meals":[{"type":"breakfast","name":"Name","calories":500,"protein":30.0,"carbs":45.0,"fat":20.0,"prepTime":15,"difficulty":"Easy","ingredients":[{"name":"Ing","amount":100.0,"unit":"g","calories":100}]}]}]}
        type must be one of: breakfast, lunch, dinner, snack. difficulty: Easy, Medium, Hard.
        CRITICAL CALORIE RULE: The sum of ALL meal calories for each day MUST equal EXACTLY \(Int(profile.dailyCalorieTarget)) kcal. Not approximately, not close — EXACTLY \(Int(profile.dailyCalorieTarget)). Adjust portion sizes to hit this number precisely. Before outputting, verify that the sum of calories of all meals for each day equals \(Int(profile.dailyCalorieTarget)).
        7 days Monday-Sunday. Do NOT include imageURL field. All meal names and ingredient names in \(aiLanguageName).
        """

        let targetKcal = Int(profile.dailyCalorieTarget)
        for attempt in 0..<3 {
            do {
                let rawText = try await KimiService.chatCompletion(prompt: prompt, timeout: 180)
                let jsonText = extractJSON(from: rawText)
                if var plan = parseMealPlanJSON(jsonText) {
                    plan = normalizePlanCalories(plan, target: targetKcal)
                    return plan
                }
            } catch {
                if attempt < 2 { try? await Task.sleep(for: .seconds(Double(attempt + 1) * 2.0)) }
            }
        }
        return DefaultData.nutritionPlan(for: profile)
    }

    static func generateScanBasedWorkoutPlanWithKimi(scanResult: BodyScan2Result, profile: UserProfile, workoutQuizPreferences: WorkoutQuizPreferences? = nil) async throws -> WorkoutPlan {
        var extraInfo = ""
        var goalInfo = profile.goal.rawValue
        if let quiz = workoutQuizPreferences {
            if !quiz.fitnessGoal.isEmpty { goalInfo = quiz.fitnessGoal }
            if !quiz.trainingLocation.isEmpty { extraInfo += " Location: \(quiz.trainingLocation)." }
            if !quiz.equipmentCategory.isEmpty { extraInfo += " Equipment: \(quiz.equipmentCategory)." }
            if !quiz.jointPain.isEmpty { extraInfo += " Joint pain: \(quiz.jointPain.joined(separator: ", ")). AVOID exercises that stress these areas." }
            if !quiz.sessionDuration.isEmpty { extraInfo += " Session duration: \(quiz.sessionDuration) min." }
        }

        let bodyContext = "Body scan results: Somatotype=\(scanResult.somatotype), BodyFat=\(scanResult.estimatedBodyFat), BiologicalAge=\(scanResult.biologicalAge), MuscleDefinition=\(scanResult.muscleDefinition), WeakPoints=\(scanResult.weakPoints.joined(separator: ", ")), StrongPoints=\(scanResult.strongPoints.joined(separator: ", ")), FocusAreas=\(scanResult.focusAreas.joined(separator: ", ")), RecommendedSplit=\(scanResult.trainingSplit), RecommendedDays=\(scanResult.trainingDaysPerWeek)"

        let daysCount = workoutQuizPreferences?.daysPerWeek ?? scanResult.trainingDaysPerWeek

        let prompt = """
        Generate a 7-day workout plan PERSONALIZED based on body scan analysis. Return ONLY valid JSON, no markdown.
        Profile: Goal=\(goalInfo), \(profile.gender.rawValue), \(Int(profile.currentWeightKg))kg, Age=\(profile.age)\(extraInfo)
        \(bodyContext)
        IMPORTANT: Design the workout plan to specifically target the weak points and focus areas.
        JSON format: {"days":[{"dayName":"Monday","focus":"Chest & Triceps","durationMinutes":60,"isRestDay":false,"caloriesBurned":350,"exercises":[{"name":"Bench Press","sets":4,"reps":"8-10","restSeconds":90,"muscleGroups":["Chest","Triceps"],"category":"main","difficulty":"Intermediate","exerciseDescription":"Flat barbell bench press","formTips":["Keep shoulder blades retracted"],"durationMinutes":0}]}]}
        category must be: warmup, main, or cooldown. Include 1-2 warmup, 4-6 main, 1-2 cooldown exercises per training day.
        7 days Monday-Sunday. EXACTLY \(daysCount) training days (isRestDay=false) and EXACTLY \(7 - daysCount) rest days (isRestDay=true). You MUST return exactly \(daysCount) non-rest days. Do NOT return fewer or more training days than \(daysCount).
        """

        for attempt in 0..<3 {
            do {
                let rawText = try await KimiService.chatCompletion(prompt: prompt, timeout: 180)
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

    static func analyzeImageForPantryWithKimi(imageBase64: String) async throws -> PantryProductResult {
        let prompt = "Analyze this photo of a food product. Extract product name, brand, nutritional values per 100g. Return ONLY raw JSON: {\"productName\":\"Name\",\"brand\":\"Brand\",\"category\":\"Category\",\"servingSize\":\"100g\",\"calories\":123,\"protein\":10.5,\"carbs\":20.3,\"fat\":5.2,\"fiber\":2.0,\"sugars\":8.1,\"saturatedFat\":1.5} category: Meat and Fish|Fruits and Vegetables|Dairy and Eggs|Grains and Pasta|Legumes and Nuts|Condiments and Spices. calories=integer, others=decimal. Use 0 if unknown."

        let rawText = try await KimiService.visionCompletion(prompt: prompt, imageBase64Strings: [imageBase64], timeout: 90)
        let jsonText = extractJSON(from: rawText)

        guard let jsonData = jsonText.data(using: String.Encoding.utf8),
              let obj = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            throw AIServiceError.decodingError
        }
        return parsePantryProductResult(from: obj)
    }

    static func analyzePantryProductWithKimi(frontBase64: String?, nutritionBase64: String?) async throws -> PantryProductResult {
        guard frontBase64 != nil || nutritionBase64 != nil else {
            throw AIServiceError.networkError("No images to analyze.")
        }

        if let front = frontBase64, let nutrition = nutritionBase64 {
            for attempt in 0..<3 {
                do {
                    let prompt = "Analyze these 2 photos of the SAME food product. Photo 1=front label (read name, brand). Photo 2=nutrition table (read kcal, protein, carbs, fat, fiber, sugars, saturated fat per 100g). Return ONLY raw JSON: {\"productName\":\"Name\",\"brand\":\"Brand\",\"category\":\"Category\",\"servingSize\":\"100g\",\"calories\":123,\"protein\":10.5,\"carbs\":20.3,\"fat\":5.2,\"fiber\":2.0,\"sugars\":8.1,\"saturatedFat\":1.5} category must be one of: Meat and Fish, Fruits and Vegetables, Dairy and Eggs, Grains and Pasta, Legumes and Nuts, Condiments and Spices. calories=integer, others=decimal. Use 0 if unreadable."

                    let rawText = try await KimiService.visionCompletion(prompt: prompt, imageBase64Strings: [front, nutrition], timeout: 120)
                    let jsonText = extractJSON(from: rawText)

                    guard let jsonData = jsonText.data(using: String.Encoding.utf8),
                          let obj = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
                          let name = obj["productName"] as? String, !name.isEmpty else {
                        if attempt < 2 {
                            try? await Task.sleep(for: .seconds(Double(attempt + 1) * 1.5))
                            continue
                        }
                        throw AIServiceError.decodingError
                    }
                    return parsePantryProductResult(from: obj)
                } catch {
                    if attempt < 2 {
                        try? await Task.sleep(for: .seconds(Double(attempt + 1) * 1.5))
                        continue
                    }
                    throw error
                }
            }
        }

        let singleBase64 = frontBase64 ?? nutritionBase64!
        let imageType = frontBase64 != nil ? "front label of a food product (read product name, brand, ingredients)" : "nutrition facts table (read exact values for calories, protein, carbs, fat)"
        let prompt = "Analyze this photo of a \(imageType). Extract product name, brand, nutritional values per 100g. Return ONLY raw JSON: {\"productName\":\"Name\",\"brand\":\"Brand\",\"category\":\"Category\",\"servingSize\":\"100g\",\"calories\":123,\"protein\":10.5,\"carbs\":20.3,\"fat\":5.2,\"fiber\":2.0,\"sugars\":8.1,\"saturatedFat\":1.5} category: Meat and Fish|Fruits and Vegetables|Dairy and Eggs|Grains and Pasta|Legumes and Nuts|Condiments and Spices. calories=integer, others=decimal. Use 0 if unknown."

        var lastError: Error?
        for attempt in 0..<3 {
            do {
                let rawText = try await KimiService.visionCompletion(prompt: prompt, imageBase64Strings: [singleBase64], timeout: 90)
                let jsonText = extractJSON(from: rawText)
                guard let jsonData = jsonText.data(using: String.Encoding.utf8),
                      let obj = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
                    throw AIServiceError.decodingError
                }
                return parsePantryProductResult(from: obj)
            } catch {
                lastError = error
                if attempt < 2 { try? await Task.sleep(for: .seconds(Double(attempt + 1) * 1.5)) }
            }
        }
        throw lastError ?? AIServiceError.networkError("Analysis failed after multiple attempts.")
    }

    static func lookupBarcodeWithKimi(_ barcode: String) async throws -> PantryProductResult {
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

        let rawText = try await KimiService.chatCompletion(prompt: prompt, timeout: 60)
        let jsonText = extractJSON(from: rawText)

        guard let jsonData = jsonText.data(using: String.Encoding.utf8),
              let obj = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            throw AIServiceError.decodingError
        }

        let result = parsePantryProductResult(from: obj)
        if result.productName == "Unknown" || result.productName.isEmpty {
            throw AIServiceError.noContent
        }
        return result
    }

    static func generateScanNutritionModificationsWithKimi(
        scanResult: BodyScan2Result,
        currentPlan: NutritionPlan,
        profile: UserProfile,
        quizPreferences: MealPlanQuizPreferences? = nil
    ) async throws -> (modifications: ScanPlanModifications, modifiedPlan: NutritionPlan) {
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

        Return ONLY valid JSON:
        {"modifications":{"nutritionSummary":"Summary of nutrition plan changes","workoutSummary":"","nutritionChanges":[{"dayName":"Monday","changeType":"replace","description":"Replaced lunch","reason":"More protein needed"}],"workoutChanges":[]},"days":[{"dayName":"Monday","meals":[{"type":"breakfast","name":"Name","calories":500,"protein":30.0,"carbs":45.0,"fat":20.0,"prepTime":15,"difficulty":"Easy","ingredients":[{"name":"Ing","amount":100.0,"unit":"g","calories":100}]}]}]}

        RULES:
        - Keep at least 70% of meals unchanged
        - nutritionSummary in \(aiLanguageName)
        - All text in \(aiLanguageName)
        - 7 days Monday-Sunday
        """

        for attempt in 0..<3 {
            do {
                let rawText = try await KimiService.chatCompletion(prompt: prompt, timeout: 180)
                let jsonText = extractJSON(from: rawText)
                if let result = parseModifiedNutritionResponse(jsonText) {
                    return result
                }
            } catch {
                if attempt < 2 { try? await Task.sleep(for: .seconds(Double(attempt + 1) * 2.0)) }
            }
        }

        let fallbackMods = ScanPlanModifications(nutritionSummary: Lang.s("no_modifications_available"), workoutSummary: "", nutritionChanges: [], workoutChanges: [])
        return (fallbackMods, currentPlan)
    }

    static func generateScanWorkoutModificationsWithKimi(
        scanResult: BodyScan2Result,
        currentPlan: WorkoutPlan,
        profile: UserProfile,
        workoutQuizPreferences: WorkoutQuizPreferences? = nil
    ) async throws -> (modifications: ScanPlanModifications, modifiedPlan: WorkoutPlan) {
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
        You are a fitness expert. The user already has an existing workout plan. Based on a NEW body scan, suggest SMALL targeted modifications. Do NOT recreate from scratch.

        Profile: Goal=\(goalInfo), \(profile.gender.rawValue), \(Int(profile.currentWeightKg))kg, Age=\(profile.age)\(extraInfo)
        \(bodyContext)

        CURRENT PLAN SUMMARY:
        \(currentPlanSummary)

        Return ONLY valid JSON:
        {"modifications":{"nutritionSummary":"","workoutSummary":"Summary of workout changes","nutritionChanges":[],"workoutChanges":[{"dayName":"Monday","changeType":"replace","description":"Added chest exercise","reason":"Chest weak point"}]},"days":[{"dayName":"Monday","focus":"Chest & Triceps","durationMinutes":60,"isRestDay":false,"caloriesBurned":350,"exercises":[{"name":"Bench Press","sets":4,"reps":"8-10","restSeconds":90,"muscleGroups":["Chest","Triceps"],"category":"main","difficulty":"Intermediate","exerciseDescription":"Flat barbell bench press","formTips":["Keep shoulder blades retracted"],"durationMinutes":0}]}]}

        RULES:
        - Keep at least 70% of exercises unchanged
        - workoutSummary in \(aiLanguageName)
        - category: warmup, main, or cooldown
        - All text in \(aiLanguageName)
        - 7 days Monday-Sunday
        """

        for attempt in 0..<3 {
            do {
                let rawText = try await KimiService.chatCompletion(prompt: prompt, timeout: 180)
                let jsonText = extractJSON(from: rawText)
                if let result = parseModifiedWorkoutResponse(jsonText) {
                    return result
                }
            } catch {
                if attempt < 2 { try? await Task.sleep(for: .seconds(Double(attempt + 1) * 2.0)) }
            }
        }

        let fallbackMods = ScanPlanModifications(nutritionSummary: "", workoutSummary: Lang.s("no_modifications_available"), nutritionChanges: [], workoutChanges: [])
        return (fallbackMods, currentPlan)
    }

    static func analyzeWorkoutPDFWithKimi(pdfText: String) async throws -> WorkoutPlan {
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

        for attempt in 0..<2 {
            do {
                let rawText = try await KimiService.chatCompletion(prompt: prompt, timeout: 60)
                let jsonText = extractJSON(from: rawText)
                if let plan = parseWorkoutPlanJSON(jsonText), !plan.days.isEmpty {
                    return plan
                }
            } catch {
                if attempt < 1 { try? await Task.sleep(for: .seconds(2.0)) }
            }
        }
        throw AIServiceError.networkError("Failed to analyze the workout plan.")
    }
}
