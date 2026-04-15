import SwiftUI

struct ReplaceMealSheet: View {
    let meal: Meal
    let onReplace: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    @Environment(AppViewModel.self) private var appVM
    @State private var suggestions: [Meal] = []

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack(spacing: 6) {
                    HStack(spacing: 10) {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.title3)
                            .foregroundStyle(Color.wellnessTeal)
                        Text(Lang.s("replace_meal"))
                            .font(.title3.bold())
                    }
                    Text(Lang.s("replace_meal_desc"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 16)
                .padding(.horizontal, 20)

                VStack(alignment: .leading, spacing: 6) {
                    Text(Lang.s("current_meal"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(meal.name)
                                .font(.headline)
                            Text("\(meal.calories) kcal · P\(Int(meal.protein))g · C\(Int(meal.carbs))g · G\(Int(meal.fat))g")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                }
                .padding(14)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .padding(.horizontal, 20)
                .padding(.top, 16)

                if suggestions.isEmpty {
                    VStack(spacing: 12) {
                        ProgressView()
                            .tint(Color.wellnessTeal)
                        Text(Lang.s("finding_alternatives"))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        VStack(spacing: 8) {
                            ForEach(suggestions) { suggestion in
                                Button {
                                    replaceMeal(with: suggestion)
                                } label: {
                                    HStack(spacing: 12) {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(suggestion.name)
                                                .font(.subheadline.weight(.semibold))
                                                .foregroundStyle(.primary)
                                                .lineLimit(2)
                                                .multilineTextAlignment(.leading)
                                            HStack(spacing: 6) {
                                                Text("\(suggestion.calories) kcal")
                                                    .font(.caption.weight(.semibold))
                                                    .foregroundStyle(Color.wellnessTeal)
                                                Text("·")
                                                    .foregroundStyle(.tertiary)
                                                Text("P\(Int(suggestion.protein))g")
                                                    .font(.caption2)
                                                    .foregroundStyle(.red)
                                                Text("C\(Int(suggestion.carbs))g")
                                                    .font(.caption2)
                                                    .foregroundStyle(.blue)
                                                Text("G\(Int(suggestion.fat))g")
                                                    .font(.caption2)
                                                    .foregroundStyle(.orange)
                                            }
                                            if let steps = suggestion.preparationSteps, !steps.isEmpty {
                                                Text("\(suggestion.prepTime) min · \(suggestion.difficulty.localizedName)")
                                                    .font(.caption2)
                                                    .foregroundStyle(.tertiary)
                                            }
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.right")
                                            .font(.caption)
                                            .foregroundStyle(.tertiary)
                                    }
                                    .padding(14)
                                    .background(Color(.secondarySystemBackground))
                                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 12)
                        .padding(.bottom, 20)
                    }
                    .scrollIndicators(.hidden)
                }
            }
            .navigationTitle(Lang.s("replace_meal"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.secondary)
                            .frame(width: 30, height: 30)
                            .background(Color(.systemGray5))
                            .clipShape(Circle())
                    }
                }
            }
        }
        .task {
            loadSuggestions()
        }
    }

    private func loadSuggestions() {
        let dietTag: DietTag
        if let quiz = appVM.quizPreferences, !quiz.dietType.isEmpty {
            dietTag = DietTag.from(quizDietName: quiz.dietType)
        } else {
            dietTag = DietTag.from(profileDiet: appVM.userProfile.dietType)
        }

        let intolerances = appVM.quizPreferences?.intolerances ?? []
        let existingNames = appVM.nutritionPlan.days.flatMap { $0.meals.map { $0.name } }

        var results: [Meal] = []
        for _ in 0..<5 {
            if let replacement = MealPlanGenerator.pickReplacementMeal(
                for: meal.type,
                diet: dietTag,
                targetCalories: meal.calories,
                intolerances: intolerances,
                excludeNames: existingNames + results.map { $0.name } + [meal.name]
            ) {
                results.append(replacement)
            }
        }

        suggestions = results
    }

    private func replaceMeal(with newMeal: Meal) {
        var updatedMeal = newMeal
        updatedMeal.imageURL = MealImageService.shared.cachedImageURL(forMealName: newMeal.name)
        for dayIndex in appVM.nutritionPlan.days.indices {
            if let mealIndex = appVM.nutritionPlan.days[dayIndex].meals.firstIndex(where: { $0.id == meal.id }) {
                appVM.nutritionPlan.days[dayIndex].meals[mealIndex] = updatedMeal
                appVM.saveCurrentProfile()
                if updatedMeal.imageURL == nil {
                    Task {
                        if let url = await MealImageService.shared.generateImageForSingleMeal(updatedMeal) {
                            appVM.nutritionPlan.days[dayIndex].meals[mealIndex].imageURL = url
                            appVM.saveCurrentProfile()
                        }
                    }
                }
                break
            }
        }
        dismiss()
    }
}
