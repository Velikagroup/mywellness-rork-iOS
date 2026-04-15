import Foundation

enum MealLocalization {
    static func localizePlan(_ plan: NutritionPlan) -> NutritionPlan {
        let lang = UserDefaults.standard.string(forKey: "appLanguage") ?? "en"
        guard lang != "it" else { return plan }
        let days = plan.days.map { day in
            DayPlan(dayName: day.dayName, meals: day.meals.map { localizeMeal($0, lang: lang) })
        }
        return NutritionPlan(days: days)
    }

    static func localizeMeal(_ meal: Meal, lang: String? = nil) -> Meal {
        let language = lang ?? (UserDefaults.standard.string(forKey: "appLanguage") ?? "en")
        guard language != "it" else { return meal }
        if meal.isCheatMeal { return meal }

        var localized = meal
        localized.name = translateName(meal.name, to: language)
        localized.ingredients = meal.ingredients.map { translateIngredient($0, to: language) }
        if let steps = meal.preparationSteps {
            localized.preparationSteps = translateSteps(forMeal: meal.name, steps: steps, to: language)
        }
        return localized
    }

    private static func translateName(_ name: String, to lang: String) -> String {
        let dict: [String: String]
        switch lang {
        case "es": dict = MealTranslationsES.mealNames
        case "de": dict = MealTranslationsDE.mealNames
        case "fr": dict = MealTranslationsFR.mealNames
        case "pt": dict = MealTranslationsPT.mealNames
        default: dict = MealTranslationsEN.mealNames
        }
        return dict[name] ?? name
    }

    private static func translateIngredient(_ ingredient: Ingredient, to lang: String) -> Ingredient {
        let nameDict: [String: String]
        let unitDict: [String: String]
        switch lang {
        case "es":
            nameDict = MealTranslationsES.ingredientNames
            unitDict = MealTranslationsES.unitNames
        case "de":
            nameDict = MealTranslationsDE.ingredientNames
            unitDict = MealTranslationsDE.unitNames
        case "fr":
            nameDict = MealTranslationsFR.ingredientNames
            unitDict = MealTranslationsFR.unitNames
        case "pt":
            nameDict = MealTranslationsPT.ingredientNames
            unitDict = MealTranslationsPT.unitNames
        default:
            nameDict = MealTranslationsEN.ingredientNames
            unitDict = MealTranslationsEN.unitNames
        }
        return Ingredient(
            name: nameDict[ingredient.name] ?? ingredient.name,
            amount: ingredient.amount,
            unit: unitDict[ingredient.unit] ?? ingredient.unit,
            calories: ingredient.calories
        )
    }

    private static func translateSteps(forMeal italianName: String, steps: [String], to lang: String) -> [String] {
        let dict: [String: [String]]
        switch lang {
        case "es": dict = MealTranslationsES.mealSteps
        case "de": dict = MealTranslationsDE.mealSteps
        case "fr": dict = MealTranslationsFR.mealSteps
        case "pt": dict = MealTranslationsPT.mealSteps
        default: dict = MealTranslationsEN.mealSteps
        }
        if let translated = dict[italianName], translated.count == steps.count {
            return translated
        }
        return steps
    }
}
