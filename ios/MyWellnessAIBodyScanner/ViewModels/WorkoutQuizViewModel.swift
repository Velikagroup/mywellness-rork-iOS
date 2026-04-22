import Foundation
import SwiftUI

@Observable
@MainActor
class WorkoutQuizViewModel {
    var preferences: WorkoutQuizPreferences = WorkoutQuizPreferences()
    var currentStep: Int = 0
    var expandedCategoryId: String? = nil
    var isGenerating: Bool = false
    var generationProgress: Double = 0
    var currentGenerationStep: Int = 0
    var generationError: String?
    var isComplete: Bool = false

    var generationSteps: [String] {
        [
            Lang.s("wgen_analyzing_profile"),
            Lang.s("wgen_processing_sport"),
            Lang.s("wgen_designing_split"),
            Lang.s("wgen_selecting_exercises"),
            Lang.s("wgen_validating"),
            Lang.s("wgen_calibrating"),
            Lang.s("wgen_building_plan")
        ]
    }

    var totalSteps: Int {
        if preferences.isPerformance == true {
            return 11
        }
        return 9
    }

    var currentVisibleStep: Int {
        if preferences.isPerformance == true {
            return currentStep + 1
        } else {
            if currentStep <= 1 {
                return currentStep + 1
            } else {
                return currentStep - 1
            }
        }
    }

    var stepLabel: String {
        "\(currentVisibleStep)/\(totalSteps)"
    }

    var canContinue: Bool {
        switch currentStep {
        case 0: return !preferences.fitnessGoal.isEmpty
        case 1: return preferences.isPerformance != nil
        default:
            if preferences.isPerformance == true {
                return canContinuePerformanceStep(currentStep)
            } else {
                return canContinueWellnessStep(currentStep)
            }
        }
    }

    private func canContinuePerformanceStep(_ step: Int) -> Bool {
        switch step {
        case 4: return !preferences.trainingFrequency.isEmpty
        case 5: return !preferences.strengthLevel.isEmpty
        case 6: return preferences.daysPerWeek > 0 && preferences.preferredDays.count == preferences.daysPerWeek
        case 7: return !preferences.sessionDuration.isEmpty
        case 8: return !preferences.trainingLocation.isEmpty
        case 9: return !preferences.equipmentCategory.isEmpty
        case 10: return !preferences.jointPain.isEmpty
        default: return true
        }
    }

    private func canContinueWellnessStep(_ step: Int) -> Bool {
        switch step {
        case 4: return !preferences.trainingFrequency.isEmpty
        case 5: return !preferences.strengthLevel.isEmpty
        case 6: return preferences.daysPerWeek > 0 && preferences.preferredDays.count == preferences.daysPerWeek
        case 7: return !preferences.sessionDuration.isEmpty
        case 8: return !preferences.trainingLocation.isEmpty
        case 9: return !preferences.equipmentCategory.isEmpty
        case 10: return !preferences.jointPain.isEmpty
        default: return true
        }
    }

    var isLastStep: Bool {
        return currentStep == 10
    }

    func nextStep() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            if preferences.isPerformance != true && currentStep == 1 {
                currentStep = 4
            } else {
                currentStep += 1
            }
        }
    }

    func previousStep() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) {
            if currentStep > 0 {
                if preferences.isPerformance != true && currentStep == 4 {
                    currentStep = 1
                } else {
                    currentStep -= 1
                }
            }
        }
    }

    func toggleCategory(_ id: String) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            if expandedCategoryId == id {
                expandedCategoryId = nil
            } else {
                expandedCategoryId = id
            }
        }
    }

    func selectSport(_ sport: String) {
        withAnimation(.spring(response: 0.25)) {
            preferences.selectedSport = sport
        }
    }

    var sportQuestions: [SportQuestion] {
        WorkoutQuizStaticData.questions(for: preferences.selectedSport)
    }

    func sportAnswer(for questionId: String) -> String {
        preferences.sportAnswers[questionId] ?? ""
    }

    func setSportAnswer(_ value: String, for questionId: String) {
        preferences.sportAnswers[questionId] = value
    }

    func togglePreferredDay(_ day: String) {
        if preferences.preferredDays.contains(day) {
            preferences.preferredDays.removeAll { $0 == day }
        } else {
            if preferences.preferredDays.count < preferences.daysPerWeek {
                preferences.preferredDays.append(day)
            }
        }
    }

    func toggleJointPain(_ area: String) {
        if area == "No Pain" {
            preferences.jointPain = ["No Pain"]
            return
        }
        preferences.jointPain.removeAll { $0 == "No Pain" }
        if preferences.jointPain.contains(area) {
            preferences.jointPain.removeAll { $0 == area }
        } else {
            preferences.jointPain.append(area)
        }
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
        appVM.workoutQuizPreferences = preferences
        var generationDone = false

        for i in 0..<generationSteps.count {
            currentGenerationStep = i

            let stepDuration: Double
            switch i {
            case 0: stepDuration = 0.3
            case 1: stepDuration = 0.3
            case 2: stepDuration = 0.4
            case 3: stepDuration = 0.5
            case 4: stepDuration = 0.3
            case 5: stepDuration = 0.3
            case 6: stepDuration = 0.3
            default: stepDuration = 0.3
            }

            let steps = 5
            for s in 0..<steps {
                try? await Task.sleep(for: .seconds(stepDuration / Double(steps)))
                let baseProgress = Double(i) / Double(generationSteps.count)
                let stepProgress = Double(s + 1) / Double(steps) / Double(generationSteps.count)
                generationProgress = baseProgress + stepProgress

                if i == 3 && s == 1 && !generationDone {
                    generationDone = true
                    do {
                        try await appVM.regenerateWorkoutWithQuiz(preferences: preferences)
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
}
