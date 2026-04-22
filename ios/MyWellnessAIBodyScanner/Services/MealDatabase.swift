import Foundation

nonisolated enum DietTag: String, CaseIterable, Sendable {
    case mediterranean, lowCarb, softLowCarb, ketogenic, paleo, carnivore, vegan, vegetarian, balanced

    static func from(profileDiet: UserProfile.DietType) -> DietTag {
        switch profileDiet {
        case .mediterranean: return .mediterranean
        case .lowCarb: return .lowCarb
        case .softLowCarb: return .softLowCarb
        case .ketogenic: return .ketogenic
        case .paleo: return .paleo
        case .carnivore: return .carnivore
        case .vegan: return .vegan
        case .vegetarian: return .vegetarian
        case .standard, .none: return .balanced
        }
    }

    static func from(quizDietName: String) -> DietTag {
        let l = quizDietName.lowercased()
        if l.contains("mediterran") || l.contains("méditerran") { return .mediterranean }
        if l.contains("keto") || l.contains("chetogen") || l.contains("cétogène") || l.contains("cetogén") || l.contains("cetogên") { return .ketogenic }
        if (l.contains("soft") || l.contains("sanft") || l.contains("léger") || l.contains("leve") || l.contains("suave") || l.contains("ridott")) && (l.contains("low") || l.contains("carb") || l.contains("glucid")) { return .softLowCarb }
        if l.contains("low carb") || l.contains("low-carb") || l.contains("baja en carb") || l.contains("faible en glucid") { return .lowCarb }
        if l.contains("paleo") || l.contains("paléo") { return .paleo }
        if l.contains("carniv") || l.contains("karnivor") { return .carnivore }
        if l.contains("vegan") || l.contains("végétalien") || l.contains("vegana") { return .vegan }
        if l.contains("vegetari") || l.contains("végétarien") { return .vegetarian }
        return .balanced
    }
}

nonisolated enum SnackSlot: String, Sendable {
    case morning, afternoon, preNight
}

nonisolated struct CatalogMeal: Sendable {
    let meal: Meal
    let dietTags: Set<DietTag>
    let snackSlot: SnackSlot?

    init(meal: Meal, dietTags: Set<DietTag>, snackSlot: SnackSlot? = nil) {
        self.meal = meal
        self.dietTags = dietTags
        self.snackSlot = snackSlot
    }
}

enum MealDatabase {
    static var allMeals: [CatalogMeal] {
        breakfastMeals + lunchMeals + dinnerMeals + snackMeals
    }

    static func meals(forDiet diet: DietTag, type: Meal.MealType) -> [CatalogMeal] {
        allMeals.filter { $0.dietTags.contains(diet) && $0.meal.type == type }
    }

    static func snacks(forDiet diet: DietTag, slot: SnackSlot) -> [CatalogMeal] {
        allMeals.filter { $0.dietTags.contains(diet) && $0.meal.type == .snack && $0.snackSlot == slot }
    }

    static func filterIntolerances(_ meals: [CatalogMeal], intolerances: [String]) -> [CatalogMeal] {
        guard !intolerances.isEmpty else { return meals }
        let lowered = intolerances.map { $0.lowercased() }
        return meals.filter { catalog in
            !catalog.meal.ingredients.contains { ingredient in
                let ingLower = ingredient.name.lowercased()
                return lowered.contains { intol in
                    checkIntolerance(ingredient: ingLower, intolerance: intol)
                }
            }
        }
    }

    private static func checkIntolerance(ingredient: String, intolerance: String) -> Bool {
        let map: [String: [String]] = [
            "lattosio": ["latte", "yogurt", "formaggio", "burro", "panna", "ricotta", "mozzarella", "parmigiano", "feta", "cream", "cheese", "butter", "milk"],
            "glutine": ["pane", "pasta", "farina", "grano", "orzo", "segale", "bread", "flour", "wheat", "couscous", "bulgur", "cracker", "toast", "wrap", "pita", "tortilla", "avena", "oat"],
            "frutta a guscio": ["noci", "mandorle", "nocciole", "pistacchi", "anacardi", "walnut", "almond", "hazelnut", "pistachio", "cashew", "pecan"],
            "uova": ["uovo", "uova", "egg"],
            "soia": ["soia", "tofu", "tempeh", "edamame", "soy"],
            "pesce": ["pesce", "salmone", "tonno", "merluzzo", "branzino", "fish", "salmon", "tuna", "cod", "gamberi", "shrimp", "sgombro", "sardine", "orata"],
            "arachidi": ["arachidi", "peanut", "burro di arachidi"],
            "sesamo": ["sesamo", "tahini", "sesame"],
            "solfiti": ["vino", "wine", "aceto", "vinegar"],
            "istamina": ["tonno", "salmone", "avocado", "spinaci", "pomodor"],
            "fruttosio": ["miele", "mela", "pera", "honey", "apple", "pear", "agave"],
            "sorbitolo": ["mela", "pera", "prugna", "apple", "pear", "plum"],
            "lactose": ["latte", "yogurt", "formaggio", "burro", "panna", "ricotta", "mozzarella", "parmigiano", "feta", "cream", "cheese", "butter", "milk"],
            "gluten": ["pane", "pasta", "farina", "grano", "bread", "flour", "wheat", "couscous", "bulgur", "cracker", "toast", "wrap", "pita", "avena", "oat"],
            "nuts": ["noci", "mandorle", "nocciole", "pistacchi", "anacardi", "walnut", "almond", "hazelnut", "pistachio", "cashew"],
            "eggs": ["uovo", "uova", "egg"],
            "soy": ["soia", "tofu", "tempeh", "edamame", "soy"],
            "fish": ["pesce", "salmone", "tonno", "merluzzo", "branzino", "fish", "salmon", "tuna", "gamberi", "shrimp"],
            "peanuts": ["arachidi", "peanut"],
        ]

        for (key, ingredients) in map {
            if intolerance.contains(key) {
                if ingredients.contains(where: { ingredient.contains($0) }) {
                    return true
                }
            }
        }
        return false
    }
}
