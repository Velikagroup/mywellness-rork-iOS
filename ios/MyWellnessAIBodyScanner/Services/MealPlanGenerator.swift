import Foundation

enum MealPlanGenerator {
    static func generateSafe(profile: UserProfile, preferences: MealPlanQuizPreferences?) -> NutritionPlan {
        let plan = generate(profile: profile, preferences: preferences)
        guard !plan.days.isEmpty else {
            return MealLocalization.localizePlan(DefaultData.nutritionPlan(for: profile))
        }
        return plan
    }

    static func generate(profile: UserProfile, preferences: MealPlanQuizPreferences?) -> NutritionPlan {
        let dietTag: DietTag
        if let quiz = preferences, !quiz.dietType.isEmpty {
            dietTag = DietTag.from(quizDietName: quiz.dietType)
        } else {
            dietTag = DietTag.from(profileDiet: profile.dietType)
        }

        let dailyTarget = Int(profile.dailyCalorieTarget)
        let intolerances = preferences?.intolerances ?? []
        let customIntol = preferences?.customIntolerances ?? ""
        var allIntolerances = intolerances
        if !customIntol.isEmpty { allIntolerances.append(customIntol) }

        let mealStructure = determineMealStructure(preferences: preferences, dailyTarget: dailyTarget)
        let cookingDifficulty = preferences?.cookingTime ?? .moderate

        let weekDays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]

        let breakfasts = filteredMeals(diet: dietTag, type: .breakfast, intolerances: allIntolerances)
        let lunches = filteredMeals(diet: dietTag, type: .lunch, intolerances: allIntolerances)
        let dinners = filteredMeals(diet: dietTag, type: .dinner, intolerances: allIntolerances)
        let morningSnacks = filteredSnacks(diet: dietTag, slot: .morning, intolerances: allIntolerances)
        let afternoonSnacks = filteredSnacks(diet: dietTag, slot: .afternoon, intolerances: allIntolerances)
        let preNightSnacks = filteredSnacks(diet: dietTag, slot: .preNight, intolerances: allIntolerances)


        let cheatDayName = resolveCheatDay(preferences?.cheatMeal?.day)
        let cheatMealType = resolveCheatMealType(preferences?.cheatMeal?.mealType)

        var usedBreakfasts: Set<String> = []
        var usedLunches: Set<String> = []
        var usedDinners: Set<String> = []
        var usedSnacks: Set<String> = []

        var dayPlans: [DayPlan] = []

        for (index, dayName) in weekDays.enumerated() {
            var dayMeals: [Meal] = []
            let isCheatDay = (cheatDayName == dayName)

            for slot in mealStructure.slots {
                let targetKcal = slot.calories

                switch slot.type {
                case .breakfast:
                    if let meal = pickBest(from: breakfasts, target: targetKcal, difficulty: cookingDifficulty, used: &usedBreakfasts, seed: index) {
                        dayMeals.append(scaleMeal(meal, targetCalories: targetKcal))
                    }
                case .lunch:
                    if isCheatDay && cheatMealType == .lunch {
                        dayMeals.append(makeFreeMeal(type: .lunch))
                    } else if let meal = pickBest(from: lunches, target: targetKcal, difficulty: cookingDifficulty, used: &usedLunches, seed: index) {
                        dayMeals.append(scaleMeal(meal, targetCalories: targetKcal))
                    }
                case .dinner:
                    if isCheatDay && cheatMealType == .dinner {
                        dayMeals.append(makeFreeMeal(type: .dinner))
                    } else if let meal = pickBest(from: dinners, target: targetKcal, difficulty: cookingDifficulty, used: &usedDinners, seed: index) {
                        dayMeals.append(scaleMeal(meal, targetCalories: targetKcal))
                    }
                case .snack:
                    let snackPool: [Meal]
                    switch slot.snackSlot {
                    case .morning: snackPool = morningSnacks
                    case .afternoon: snackPool = afternoonSnacks
                    case .preNight: snackPool = preNightSnacks
                    case .none: snackPool = morningSnacks + afternoonSnacks + preNightSnacks
                    }
                    if let meal = pickBest(from: snackPool, target: targetKcal, difficulty: cookingDifficulty, used: &usedSnacks, seed: index) {
                        dayMeals.append(scaleMeal(meal, targetCalories: targetKcal))
                    }
                }
            }

            if !dayMeals.isEmpty {
                dayPlans.append(DayPlan(dayName: dayName, meals: dayMeals))
            }
        }

        if dayPlans.isEmpty {
            return MealLocalization.localizePlan(DefaultData.nutritionPlan(for: profile))
        }

        return MealLocalization.localizePlan(NutritionPlan(days: dayPlans))
    }

    static func makeFreeMeal(type: Meal.MealType) -> Meal {
        Meal(
            type: type,
            name: Lang.s("free_meal_name"),
            calories: 0,
            protein: 0,
            carbs: 0,
            fat: 0,
            prepTime: 0,
            difficulty: .easy,
            ingredients: [],
            isCheatMeal: true
        )
    }

    private static func filteredMeals(diet: DietTag, type: Meal.MealType, intolerances: [String]) -> [Meal] {
        var catalog = MealDatabase.meals(forDiet: diet, type: type)
        if catalog.isEmpty {
            catalog = MealDatabase.meals(forDiet: .balanced, type: type)
        }
        let filtered = MealDatabase.filterIntolerances(catalog, intolerances: intolerances)
        return (filtered.isEmpty ? catalog : filtered).map { $0.meal }
    }

    private static func filteredSnacks(diet: DietTag, slot: SnackSlot, intolerances: [String]) -> [Meal] {
        var catalog = MealDatabase.snacks(forDiet: diet, slot: slot)
        if catalog.isEmpty {
            catalog = MealDatabase.snacks(forDiet: .balanced, slot: slot)
        }
        if catalog.isEmpty {
            catalog = MealDatabase.allMeals.filter { $0.meal.type == .snack && $0.dietTags.contains(diet) }
        }
        if catalog.isEmpty {
            catalog = MealDatabase.allMeals.filter { $0.meal.type == .snack }
        }
        let filtered = MealDatabase.filterIntolerances(catalog, intolerances: intolerances)
        return (filtered.isEmpty ? catalog : filtered).map { $0.meal }
    }

    private static func pickBest(from pool: [Meal], target: Int, difficulty: MealPlanQuizPreferences.CookingTime, used: inout Set<String>, seed: Int) -> Meal? {
        guard !pool.isEmpty else { return nil }

        let maxPrepTime: Int
        switch difficulty {
        case .quick: maxPrepTime = 20
        case .moderate: maxPrepTime = 35
        case .relaxed: maxPrepTime = 999
        }

        let timeFiltered = pool.filter { $0.prepTime <= maxPrepTime }
        let candidates = timeFiltered.isEmpty ? pool : timeFiltered

        let unused = candidates.filter { !used.contains($0.name) }
        let searchPool = unused.isEmpty ? candidates : unused

        let sorted = searchPool.sorted { a, b in
            let diffA = abs(a.calories - target)
            let diffB = abs(b.calories - target)
            if diffA != diffB { return diffA < diffB }
            return stableHash(a.name, seed: seed) < stableHash(b.name, seed: seed)
        }

        guard let picked = sorted.first else { return nil }
        used.insert(picked.name)
        return picked
    }

    private static func stableHash(_ string: String, seed: Int) -> Int {
        var h = seed &* 31
        for char in string.unicodeScalars {
            h = h &* 31 &+ Int(char.value)
        }
        return abs(h)
    }

    static func scaleMeal(_ meal: Meal, targetCalories: Int) -> Meal {
        guard meal.calories > 0 else { return meal }
        let factor = Double(targetCalories) / Double(meal.calories)
        if factor > 0.85 && factor < 1.15 { return meal }

        var scaled = meal
        scaled.id = UUID()
        scaled.calories = targetCalories
        scaled.protein = round(meal.protein * factor * 10) / 10
        scaled.carbs = round(meal.carbs * factor * 10) / 10
        scaled.fat = round(meal.fat * factor * 10) / 10
        scaled.ingredients = meal.ingredients.map { ing in
            Ingredient(
                name: ing.name,
                amount: round(ing.amount * factor * 10) / 10,
                unit: ing.unit,
                calories: max(1, Int(round(Double(ing.calories) * factor)))
            )
        }
        return scaled
    }

    static func pickReplacementMeal(for mealType: Meal.MealType, diet: DietTag, targetCalories: Int, intolerances: [String], excludeNames: [String]) -> Meal? {
        let catalog: [CatalogMeal]
        if mealType == .snack {
            catalog = MealDatabase.allMeals.filter { $0.meal.type == .snack && $0.dietTags.contains(diet) }
        } else {
            catalog = MealDatabase.meals(forDiet: diet, type: mealType)
        }
        let filtered = MealDatabase.filterIntolerances(catalog, intolerances: intolerances)
        let pool = (filtered.isEmpty ? catalog : filtered).map { $0.meal }
        let available = pool.filter { !excludeNames.contains($0.name) }
        let candidates = available.isEmpty ? pool : available

        guard !candidates.isEmpty else { return nil }

        let sorted = candidates.sorted { abs($0.calories - targetCalories) < abs($1.calories - targetCalories) }
        guard let picked = sorted.first else { return nil }
        return MealLocalization.localizeMeal(scaleMeal(picked, targetCalories: targetCalories))
    }

    private static func shortDay(for dayName: String) -> String {
        switch dayName {
        case "Monday": return "Mon"
        case "Tuesday": return "Tue"
        case "Wednesday": return "Wed"
        case "Thursday": return "Thu"
        case "Friday": return "Fri"
        case "Saturday": return "Sat"
        case "Sunday": return "Sun"
        default: return String(dayName.prefix(3))
        }
    }

    private static func filteredCheatMeals(diet: DietTag, type: Meal.MealType, intolerances: [String]) -> [Meal] {
        let source: [CatalogMeal] = type == .lunch ? MealDatabase.cheatLunchMeals : MealDatabase.cheatDinnerMeals
        var catalog = source.filter { $0.dietTags.contains(diet) }
        if catalog.isEmpty {
            catalog = source.filter { $0.dietTags.contains(.balanced) }
        }
        if catalog.isEmpty {
            catalog = source
        }
        let filtered = MealDatabase.filterIntolerances(catalog, intolerances: intolerances)
        return (filtered.isEmpty ? catalog : filtered).map { $0.meal }
    }

    private static func resolveCheatDay(_ localizedDay: String?) -> String? {
        guard let day = localizedDay else { return nil }
        let langKeys = ["mon", "tue", "wed", "thu", "fri", "sat", "sun"]
        let fullDays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
        for (i, key) in langKeys.enumerated() {
            if Lang.s(key) == day {
                return fullDays[i]
            }
        }
        let dayLower = day.lowercased()
        let shortMap: [(keys: [String], full: String)] = [
            (["mon", "lun", "mo", "seg"], "Monday"),
            (["tue", "mar", "di", "ter"], "Tuesday"),
            (["wed", "mer", "mi", "qua"], "Wednesday"),
            (["thu", "gio", "jue", "do", "jeu", "qui"], "Thursday"),
            (["fri", "ven", "vie", "fr", "sex"], "Friday"),
            (["sat", "sab", "sáb", "sa", "sam"], "Saturday"),
            (["sun", "dom", "so", "dim"], "Sunday")
        ]
        for entry in shortMap {
            if entry.keys.contains(where: { dayLower.hasPrefix($0) }) {
                return entry.full
            }
        }
        return nil
    }

    private static func resolveCheatMealType(_ localizedType: String?) -> Meal.MealType? {
        guard let mt = localizedType?.lowercased() else { return nil }
        if mt.contains("lunch") || mt.contains("pranzo") || mt.contains("almuerzo") || mt.contains("mittag") || mt.contains("déjeuner") || mt.contains("almoço") {
            return .lunch
        }
        if mt.contains("dinner") || mt.contains("cena") || mt.contains("abend") || mt.contains("dîner") || mt.contains("jantar") {
            return .dinner
        }
        return nil
    }
}

struct MealSlot: Sendable {
    let type: Meal.MealType
    let calories: Int
    let snackSlot: SnackSlot?

    init(type: Meal.MealType, calories: Int, snackSlot: SnackSlot? = nil) {
        self.type = type
        self.calories = calories
        self.snackSlot = snackSlot
    }
}

struct MealStructure: Sendable {
    let slots: [MealSlot]
}

extension MealPlanGenerator {
    static func determineMealStructure(preferences: MealPlanQuizPreferences?, dailyTarget: Int) -> MealStructure {
        guard let quiz = preferences else {
            let perMeal = dailyTarget / 3
            return MealStructure(slots: [
                MealSlot(type: .breakfast, calories: perMeal),
                MealSlot(type: .lunch, calories: perMeal),
                MealSlot(type: .dinner, calories: dailyTarget - perMeal * 2)
            ])
        }

        let count = max(quiz.mealsCount, 1)

        if quiz.wantsFasting {
            return fastingStructure(window: quiz.fastingWindow, count: count, dailyTarget: dailyTarget)
        }

        switch count {
        case 1:
            return MealStructure(slots: [MealSlot(type: .lunch, calories: dailyTarget)])
        case 2:
            let half = dailyTarget / 2
            return MealStructure(slots: [
                MealSlot(type: .lunch, calories: half),
                MealSlot(type: .dinner, calories: dailyTarget - half)
            ])
        case 3:
            let perMeal = dailyTarget / 3
            return MealStructure(slots: [
                MealSlot(type: .breakfast, calories: perMeal),
                MealSlot(type: .lunch, calories: perMeal),
                MealSlot(type: .dinner, calories: dailyTarget - perMeal * 2)
            ])
        case 4:
            let mainKcal = Int(Double(dailyTarget) * 0.3)
            let snackKcal = dailyTarget - mainKcal * 3
            return MealStructure(slots: [
                MealSlot(type: .breakfast, calories: mainKcal),
                MealSlot(type: .lunch, calories: mainKcal),
                MealSlot(type: .snack, calories: snackKcal, snackSlot: .afternoon),
                MealSlot(type: .dinner, calories: mainKcal)
            ])
        case 5:
            let mainKcal = Int(Double(dailyTarget) * 0.27)
            let snackKcal = (dailyTarget - mainKcal * 3) / 2
            return MealStructure(slots: [
                MealSlot(type: .breakfast, calories: mainKcal),
                MealSlot(type: .snack, calories: snackKcal, snackSlot: .morning),
                MealSlot(type: .lunch, calories: mainKcal),
                MealSlot(type: .snack, calories: snackKcal, snackSlot: .afternoon),
                MealSlot(type: .dinner, calories: mainKcal)
            ])
        case 6:
            let mainKcal = Int(Double(dailyTarget) * 0.25)
            let snackKcal = (dailyTarget - mainKcal * 3) / 3
            return MealStructure(slots: [
                MealSlot(type: .breakfast, calories: mainKcal),
                MealSlot(type: .snack, calories: snackKcal, snackSlot: .morning),
                MealSlot(type: .lunch, calories: mainKcal),
                MealSlot(type: .snack, calories: snackKcal, snackSlot: .afternoon),
                MealSlot(type: .dinner, calories: mainKcal),
                MealSlot(type: .snack, calories: snackKcal, snackSlot: .preNight)
            ])
        default:
            let mainKcal = Int(Double(dailyTarget) * 0.22)
            let snackKcal = (dailyTarget - mainKcal * 3) / 4
            return MealStructure(slots: [
                MealSlot(type: .breakfast, calories: mainKcal),
                MealSlot(type: .snack, calories: snackKcal, snackSlot: .morning),
                MealSlot(type: .lunch, calories: mainKcal),
                MealSlot(type: .snack, calories: snackKcal, snackSlot: .afternoon),
                MealSlot(type: .dinner, calories: mainKcal),
                MealSlot(type: .snack, calories: snackKcal, snackSlot: .preNight),
                MealSlot(type: .snack, calories: snackKcal, snackSlot: .preNight)
            ])
        }
    }

    private static func fastingStructure(window: MealPlanQuizPreferences.FastingWindow, count: Int, dailyTarget: Int) -> MealStructure {
        let skipBreakfast = window == .skipBreakfast

        switch count {
        case 1:
            return MealStructure(slots: [
                MealSlot(type: skipBreakfast ? .lunch : .breakfast, calories: dailyTarget)
            ])
        case 2:
            let half = dailyTarget / 2
            if skipBreakfast {
                return MealStructure(slots: [
                    MealSlot(type: .lunch, calories: half),
                    MealSlot(type: .dinner, calories: dailyTarget - half)
                ])
            } else {
                return MealStructure(slots: [
                    MealSlot(type: .breakfast, calories: half),
                    MealSlot(type: .lunch, calories: dailyTarget - half)
                ])
            }
        case 3:
            let mainKcal = Int(Double(dailyTarget) * 0.4)
            let snackKcal = dailyTarget - mainKcal * 2
            if skipBreakfast {
                return MealStructure(slots: [
                    MealSlot(type: .lunch, calories: mainKcal),
                    MealSlot(type: .snack, calories: snackKcal, snackSlot: .afternoon),
                    MealSlot(type: .dinner, calories: mainKcal)
                ])
            } else {
                return MealStructure(slots: [
                    MealSlot(type: .breakfast, calories: mainKcal),
                    MealSlot(type: .snack, calories: snackKcal, snackSlot: .morning),
                    MealSlot(type: .lunch, calories: mainKcal)
                ])
            }
        default:
            let mainKcal = Int(Double(dailyTarget) * 0.35)
            let snackKcal = (dailyTarget - mainKcal * 2) / max(count - 2, 1)
            var slots: [MealSlot] = []
            if skipBreakfast {
                slots.append(MealSlot(type: .lunch, calories: mainKcal))
                for i in 0..<(count - 2) {
                    slots.append(MealSlot(type: .snack, calories: snackKcal, snackSlot: i == 0 ? .afternoon : .preNight))
                }
                slots.append(MealSlot(type: .dinner, calories: mainKcal))
            } else {
                slots.append(MealSlot(type: .breakfast, calories: mainKcal))
                for i in 0..<(count - 2) {
                    slots.append(MealSlot(type: .snack, calories: snackKcal, snackSlot: i == 0 ? .morning : .afternoon))
                }
                slots.append(MealSlot(type: .lunch, calories: mainKcal))
            }
            return MealStructure(slots: slots)
        }
    }
}
