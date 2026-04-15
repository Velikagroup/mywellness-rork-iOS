import SwiftUI

struct MealDetailView: View {
    let meal: Meal
    @Environment(\.dismiss) private var dismiss
    @Environment(AppViewModel.self) private var appVM
    @State private var ingredientToRemove: Ingredient?
    @State private var ingredientToSubstitute: Ingredient?
    @State private var isSubstituting: Bool = false
    @State private var substituteError: String?

    private var liveMeal: Meal {
        appVM.mealById(meal.id) ?? meal
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    mealImage
                    VStack(spacing: 16) {
                        nutritionSummary
                        metaInfo
                        ingredientsList
                        if let steps = liveMeal.preparationSteps, !steps.isEmpty {
                            preparationSection(steps: steps)
                        }
                    }
                    .padding(20)
                    .padding(.bottom, 8)
                }
            }
            .scrollIndicators(.hidden)
            .navigationTitle(liveMeal.name)
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
            .safeAreaInset(edge: .bottom) {
                bottomButtons
            }
            .alert(Lang.s("remove_ingredient_title"), isPresented: Binding(
                get: { ingredientToRemove != nil },
                set: { if !$0 { ingredientToRemove = nil } }
            )) {
                Button(Lang.s("cancel"), role: .cancel) {
                    ingredientToRemove = nil
                }
                Button(Lang.s("delete"), role: .destructive) {
                    if let ingredient = ingredientToRemove {
                        withAnimation {
                            appVM.removeIngredient(mealId: meal.id, ingredientId: ingredient.id)
                        }
                        ingredientToRemove = nil
                    }
                }
            } message: {
                if let ingredient = ingredientToRemove {
                    Text(Lang.s("remove_ingredient_msg") + " \(ingredient.name)?")
                }
            }
            .sheet(item: $ingredientToSubstitute) { ingredient in
                SubstituteIngredientSheet(
                    mealId: meal.id,
                    ingredient: ingredient,
                    mealName: liveMeal.name,
                    isSubstituting: $isSubstituting,
                    substituteError: $substituteError
                )
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)
            }
        }
    }

    private var mealImage: some View {
        Color(.systemGray6)
            .frame(maxWidth: .infinity)
            .frame(height: 240)
            .overlay {
                AsyncImage(url: URL(string: liveMeal.imageURL ?? "")) { phase in
                    if let image = phase.image {
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .allowsHitTesting(false)
                    } else if phase.error != nil {
                        Image(systemName: "fork.knife")
                            .font(.largeTitle)
                            .foregroundStyle(.tertiary)
                    } else {
                        ProgressView().tint(Color.wellnessTeal)
                    }
                }
            }
            .clipped()
    }

    private var nutritionSummary: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "chart.bar.fill")
                    .foregroundStyle(Color.wellnessTeal)
                    .font(.subheadline)
                Text(Lang.s("nutritional_summary"))
                    .font(.headline)
            }

            HStack(spacing: 0) {
                VStack(spacing: 4) {
                    Text("\(liveMeal.calories)")
                        .font(.system(.title, weight: .bold))
                        .foregroundStyle(Color.wellnessTeal)
                    Text("kcal")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)

                macroRing(value: liveMeal.protein, label: Lang.s("protein_g"), color: Color(red: 0.98, green: 0.28, blue: 0.40))
                macroRing(value: liveMeal.carbs, label: Lang.s("carbs_g"), color: Color(red: 0.24, green: 0.56, blue: 0.98))
                macroRing(value: liveMeal.fat, label: Lang.s("fat_g"), color: Color(red: 0.98, green: 0.72, blue: 0.18))
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func macroRing(value: Double, label: String, color: Color) -> some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 5)
                Circle()
                    .trim(from: 0, to: min(value / 100, 1))
                    .stroke(color, style: .init(lineWidth: 5, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.6), value: value)
                Text(String(format: "%.1f", value))
                    .font(.system(.subheadline, weight: .bold))
                    .foregroundStyle(color)
            }
            .frame(width: 64, height: 64)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    private var metaInfo: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: "clock")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
                Text("\(Lang.s("prep_label")) \(liveMeal.prepTime) min")
                    .font(.subheadline)
            }
            Spacer()
            Divider().frame(height: 20)
            Spacer()
            HStack(spacing: 8) {
                Image(systemName: "chef.hat.fill")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
                Text("\(Lang.s("difficulty_label")) \(liveMeal.difficulty.localizedName)")
                    .font(.subheadline)
            }
        }
        .padding(14)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var ingredientsList: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "leaf.fill")
                    .foregroundStyle(Color.wellnessTeal)
                    .font(.subheadline)
                Text(Lang.s("ingredients"))
                    .font(.headline)
            }

            VStack(spacing: 0) {
                ForEach(Array(liveMeal.ingredients.enumerated()), id: \.element.id) { index, ingredient in
                    VStack(spacing: 0) {
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(ingredient.name)
                                    .font(.subheadline.weight(.medium))
                                Text("\(String(format: "%.0f", ingredient.amount))\(ingredient.unit)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text("\(ingredient.calories) kcal")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.secondary)
                            HStack(spacing: 4) {
                                Button {
                                    ingredientToSubstitute = ingredient
                                } label: {
                                    Image(systemName: "arrow.2.squarepath")
                                        .font(.system(size: 14))
                                        .foregroundStyle(Color.wellnessTeal)
                                        .frame(width: 32, height: 32)
                                        .background(Color.wellnessTeal.opacity(0.1))
                                        .clipShape(Circle())
                                }
                                .buttonStyle(.plain)

                                Button {
                                    ingredientToRemove = ingredient
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .font(.system(size: 14))
                                        .foregroundStyle(.red)
                                        .frame(width: 32, height: 32)
                                        .background(Color.red.opacity(0.1))
                                        .clipShape(Circle())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 14)

                        if index < liveMeal.ingredients.count - 1 {
                            Divider()
                                .padding(.horizontal, 14)
                        }
                    }
                }
            }
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }

    private func preparationSection(steps: [String]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(Lang.s("preparation"))
                .font(.headline)

            VStack(alignment: .leading, spacing: 10) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top, spacing: 10) {
                        Text("\(index + 1).")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.wellnessTeal)
                            .frame(width: 22, alignment: .leading)
                        Text(step)
                            .font(.subheadline)
                            .foregroundStyle(.primary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }

    private var bottomButtons: some View {
        HStack(spacing: 12) {
            Button {
                dismiss()
            } label: {
                Text(Lang.s("close"))
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color(.secondarySystemBackground))
                    .foregroundStyle(.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }

            Button {
                dismiss()
            } label: {
                Text(Lang.s("save"))
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color.wellnessTeal)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.regularMaterial)
    }
}

struct SubstituteIngredientSheet: View {
    let mealId: UUID
    let ingredient: Ingredient
    let mealName: String
    @Binding var isSubstituting: Bool
    @Binding var substituteError: String?
    @Environment(AppViewModel.self) private var appVM
    @Environment(\.dismiss) private var dismiss
    @State private var suggestions: [Ingredient] = []
    @State private var isLoading: Bool = false
    @State private var hasLoaded: Bool = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if isLoading {
                    loadingView
                } else if suggestions.isEmpty && hasLoaded {
                    errorView
                } else if !suggestions.isEmpty {
                    suggestionsList
                } else {
                    Color.clear
                }
            }
            .navigationTitle(Lang.s("substitute_ingredient"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(Lang.s("cancel")) {
                        dismiss()
                    }
                }
            }
        }
        .task {
            await loadSuggestions()
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.3)
                .tint(Color.wellnessTeal)
            Text(Lang.s("finding_substitutes"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var errorView: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 36))
                .foregroundStyle(.orange)
            Text(Lang.s("no_substitutes_found"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button {
                Task { await loadSuggestions() }
            } label: {
                Text(Lang.s("retry_generation"))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(Color.wellnessTeal)
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var suggestionsList: some View {
        ScrollView {
            VStack(spacing: 12) {
                HStack(spacing: 10) {
                    Image(systemName: "arrow.2.squarepath")
                        .foregroundStyle(Color.wellnessTeal)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(Lang.s("replacing"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(ingredient.name)
                            .font(.subheadline.weight(.semibold))
                    }
                    Spacer()
                    Text("\(ingredient.calories) kcal")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                .padding(14)
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                ForEach(suggestions) { suggestion in
                    Button {
                        appVM.substituteIngredient(mealId: mealId, ingredientId: ingredient.id, newIngredient: suggestion)
                        dismiss()
                    } label: {
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(suggestion.name)
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(.primary)
                                Text("\(String(format: "%.0f", suggestion.amount))\(suggestion.unit)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text("\(suggestion.calories) kcal")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(Color.wellnessTeal)
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
            .padding(20)
        }
    }

    private func loadSuggestions() async {
        isLoading = true
        hasLoaded = false
        suggestions = []

        do {
            let result = try await AIService.suggestIngredientSubstitutes(
                ingredient: ingredient,
                mealName: mealName,
                profile: appVM.userProfile
            )
            suggestions = result
        } catch {
            substituteError = error.localizedDescription
        }

        isLoading = false
        hasLoaded = true
    }
}
