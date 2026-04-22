import Foundation
import SwiftUI

@Observable
@MainActor
class MealPlanQuizViewModel {
    var preferences: MealPlanQuizPreferences = MealPlanQuizPreferences()
    var currentStep: Int = 0
    var isGenerating: Bool = false
    var generationProgress: Double = 0
    var currentGenerationStep: Int = 0
    var generationError: String?
    var isComplete: Bool = false

    var dietOptions: [(name: String, subtitle: String, emoji: String)] {
        [
            (Lang.s("diet_mediterranean"), Lang.s("diet_mediterranean_desc"), "🍝"),
            (Lang.s("diet_low_carb"), Lang.s("diet_low_carb_desc"), "🥩"),
            (Lang.s("diet_soft_low_carb"), Lang.s("diet_soft_low_carb_desc"), "🥗"),
            (Lang.s("diet_paleo"), Lang.s("diet_paleo_desc"), "🦴"),
            (Lang.s("diet_ketogenic"), Lang.s("diet_ketogenic_desc"), "🥓"),
            (Lang.s("diet_carnivore"), Lang.s("diet_carnivore_desc"), "🍖"),
            (Lang.s("diet_vegetarian"), Lang.s("diet_vegetarian_desc"), "🥕"),
            (Lang.s("diet_vegan"), Lang.s("diet_vegan_desc"), "🌱")
        ]
    }

    let intoleranceKeys: [String] = [
        "intol_lactose", "intol_gluten", "intol_nuts", "intol_eggs",
        "intol_soy", "intol_fish", "intol_peanuts", "intol_sesame",
        "intol_sulfites", "intol_histamine", "intol_fructose", "intol_sorbitol"
    ]

    var intoleranceOptions: [String] {
        intoleranceKeys.map { Lang.s($0) }
    }

    var weekDays: [String] {
        [Lang.s("mon"), Lang.s("tue"), Lang.s("wed"), Lang.s("thu"), Lang.s("fri"), Lang.s("sat"), Lang.s("sun")]
    }

    var generationSteps: [String] {
        [
            Lang.s("gen_step_metabolic"),
            Lang.s("gen_step_caloric"),
            Lang.s("gen_step_balancing"),
            Lang.s("gen_step_plan"),
            Lang.s("gen_step_validation"),
            Lang.s("gen_step_images"),
            Lang.s("gen_step_saving")
        ]
    }

    var totalSteps: Int {
        if preferences.wantsFasting {
            return 7
        }
        return 6
    }

    var stepLabel: String {
        let visibleStep: Int
        if preferences.wantsFasting {
            switch currentStep {
            case 0: visibleStep = 1
            case 1: visibleStep = 2
            case 2: visibleStep = 3
            case 3: visibleStep = 4
            case 4: visibleStep = 5
            case 6: visibleStep = 6
            case 7: visibleStep = 7
            default: visibleStep = currentStep + 1
            }
        } else {
            switch currentStep {
            case 0: visibleStep = 1
            case 1: visibleStep = 2
            case 2: visibleStep = 3
            case 5: visibleStep = 4
            case 6: visibleStep = 5
            case 7: visibleStep = 6
            default: visibleStep = currentStep + 1
            }
        }
        return "\(visibleStep)/\(totalSteps)"
    }

    var canContinue: Bool {
        switch currentStep {
        case 0: return !preferences.dietType.isEmpty
        case 1: return true
        case 2: return true
        case 3: return preferences.wantsFasting
        case 4: return preferences.wantsFasting && preferences.mealsCount > 0
        case 5: return !preferences.wantsFasting && preferences.mealsCount > 0
        default: return true
        }
    }

    func nextStep() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            if currentStep == 2 && !preferences.wantsFasting {
                currentStep = 5
            } else if currentStep == 4 && preferences.wantsFasting {
                currentStep = 6
            } else if currentStep == 5 && !preferences.wantsFasting {
                currentStep = 6
            } else {
                currentStep += 1
            }
        }
    }

    func previousStep() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            if currentStep == 5 && !preferences.wantsFasting {
                currentStep = 2
            } else if currentStep == 6 && !preferences.wantsFasting {
                currentStep = 5
            } else if currentStep == 6 && preferences.wantsFasting {
                currentStep = 4
            } else if currentStep > 0 {
                currentStep -= 1
            }
        }
    }

    var currentStepType: QuizStepType {
        switch currentStep {
        case 0: return .dietType
        case 1: return .intolerances
        case 2: return .fasting
        case 3: return .eatingWindow
        case 4: return .mealsInWindow
        case 5: return .regularMealsCount
        case 6: return .cookingTime
        case 7: return .cheatMeal
        default: return .dietType
        }
    }

    enum QuizStepType {
        case dietType, intolerances, fasting, eatingWindow, mealsInWindow, regularMealsCount, cookingTime, cheatMeal
    }

    func toggleIntolerance(_ intolerance: String) {
        if preferences.intolerances.contains(intolerance) {
            preferences.intolerances.removeAll { $0 == intolerance }
        } else {
            preferences.intolerances.append(intolerance)
        }
    }

    func toggleCheatMeal(day: String, mealType: String) {
        let selection = MealPlanQuizPreferences.CheatMealSelection(day: day, mealType: mealType)
        if preferences.cheatMeal == selection {
            preferences.cheatMeal = nil
        } else {
            preferences.cheatMeal = selection
        }
    }

    func kcalPerMeal(dailyTarget: Double) -> Int {
        guard preferences.mealsCount > 0 else { return 0 }
        return Int(dailyTarget / Double(preferences.mealsCount))
    }

    func startGeneration(appVM: AppViewModel) {
        isGenerating = true
        generationProgress = 0
        currentGenerationStep = 0
        generationError = nil

        Task {
            await simulateProgressAndGenerate(appVM: appVM)
        }
    }

    private func simulateProgressAndGenerate(appVM: AppViewModel) async {
        var generationDone = false

        for i in 0..<generationSteps.count {
            currentGenerationStep = i

            let stepDuration: Double
            switch i {
            case 0: stepDuration = 0.3
            case 1: stepDuration = 0.4
            case 2: stepDuration = 0.5
            case 3: stepDuration = 0.6
            case 4: stepDuration = 0.3
            case 5: stepDuration = 0.4
            case 6: stepDuration = 0.3
            default: stepDuration = 0.3
            }

            let steps = 5
            for s in 0..<steps {
                try? await Task.sleep(for: .seconds(stepDuration / Double(steps)))
                let baseProgress = Double(i) / Double(generationSteps.count)
                let stepProgress = Double(s + 1) / Double(steps) / Double(generationSteps.count)
                generationProgress = baseProgress + stepProgress

                if i == 2 && s == 1 && !generationDone {
                    generationDone = true
                    do {
                        appVM.quizPreferences = preferences
                        try await appVM.regenerateWithQuiz(preferences: preferences)
                    } catch {
                        generationError = error.localizedDescription
                    }
                }
            }
        }

        generationProgress = 1.0
        currentGenerationStep = generationSteps.count

        appVM.isGeneratingPlan = false

        try? await Task.sleep(for: .seconds(0.3))
        isGenerating = false
        isComplete = true
    }

    func generationStepText(index: Int, bmr: Double, calories: Double) -> String {
        generationSteps[index]
            .replacingOccurrences(of: "{bmr}", with: "\(Int(bmr))")
            .replacingOccurrences(of: "{calories}", with: "\(Int(calories))")
    }
}
