import SwiftUI

struct CalorieAnalysisResultView: View {
    let result: CalorieAnalysisResult
    let image: UIImage?
    @Environment(\.dismiss) private var dismiss
    @State private var editableIngredients: [ScannedIngredient] = []
    @State private var editingIngredient: ScannedIngredient? = nil
    @State private var showAddIngredient: Bool = false

    private var totalCalories: Int {
        editableIngredients.isEmpty ? result.calories : editableIngredients.reduce(0) { $0 + $1.calories }
    }

    private var totalProtein: Double {
        editableIngredients.isEmpty ? result.protein : editableIngredients.reduce(0.0) { $0 + $1.protein }
    }

    private var totalCarbs: Double {
        editableIngredients.isEmpty ? result.carbs : editableIngredients.reduce(0.0) { $0 + $1.carbs }
    }

    private var totalFat: Double {
        editableIngredients.isEmpty ? result.fat : editableIngredients.reduce(0.0) { $0 + $1.fat }
    }

    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    if image != nil {
                        imageHeader
                    } else {
                        barcodeHeader
                    }
                    VStack(spacing: 20) {
                        foodNameCard
                        macroGrid
                        ingredientsBreakdown
                        servingCard
                        notesCard
                        doneButton
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 24)
                    .padding(.bottom, 40)
                }
            }
        }
        .preferredColorScheme(.light)
        .onAppear {
            if !result.ingredients.isEmpty {
                editableIngredients = result.ingredients
            } else {
                editableIngredients = [
                    ScannedIngredient(
                        name: result.foodName,
                        quantity: result.servingSize,
                        calories: result.calories,
                        protein: result.protein,
                        carbs: result.carbs,
                        fat: result.fat
                    )
                ]
            }
        }
        .sheet(item: $editingIngredient) { ingredient in
            CalorieIngredientEditSheet(ingredient: ingredient) { updated in
                if let idx = editableIngredients.firstIndex(where: { $0.id == updated.id }) {
                    withAnimation(.spring(response: 0.35)) {
                        editableIngredients[idx] = updated
                    }
                }
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showAddIngredient) {
            CalorieAddIngredientSheet { newIngredient in
                withAnimation(.spring(response: 0.35)) {
                    editableIngredients.append(newIngredient)
                }
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
    }

    private var imageHeader: some View {
        ZStack(alignment: .topLeading) {
            Color(.secondarySystemBackground)
                .frame(height: 260)
                .overlay {
                    if let img = image {
                        Image(uiImage: img)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .allowsHitTesting(false)
                    }
                }
                .clipShape(.rect(cornerRadius: 0))

            LinearGradient(
                colors: [.black.opacity(0.7), .clear],
                startPoint: .bottom,
                endPoint: .top
            )
            .frame(height: 260)

            Button { dismiss() } label: {
                ZStack {
                    Circle()
                        .fill(.black.opacity(0.4))
                        .frame(width: 36, height: 36)
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.white)
                }
            }
            .padding(20)
            .padding(.top, 48)
        }
        .frame(height: 260)
    }

    private var barcodeHeader: some View {
        HStack {
            Button { dismiss() } label: {
                ZStack {
                    Circle()
                        .fill(Color(.systemGray5))
                        .frame(width: 36, height: 36)
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
            }
            Spacer()
            HStack(spacing: 6) {
                Image(systemName: "barcode.viewfinder")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(Color.wellnessTeal)
                Text(Lang.s("barcode_product"))
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.primary)
            }
            Spacer()
            Color.clear.frame(width: 36, height: 36)
        }
        .padding(.horizontal, 20)
        .padding(.top, 60)
        .padding(.bottom, 8)
    }

    private var foodNameCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(result.foodName)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(.primary)
                    Text(result.servingSize)
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                confidenceBadge
            }

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(totalCalories)")
                    .font(.system(size: 48, weight: .heavy))
                    .foregroundStyle(Color(red: 0.17, green: 0.60, blue: 0.52))
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.35), value: totalCalories)
                Text("kcal")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color(red: 0.17, green: 0.60, blue: 0.52))
                Spacer()
                if editableIngredients.count > 1 {
                    Text("\(editableIngredients.count) \(Lang.s("ingredients_count"))")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color(.systemGray5))
                        .clipShape(Capsule())
                }
            }
        }
        .padding(20)
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: 16))
    }

    private var confidenceBadge: some View {
        let color: Color = result.confidence == "High" ? .green : result.confidence == "Medium" ? .orange : .red
        return Text(result.confidence)
            .font(.system(size: 12, weight: .semibold))
            .foregroundStyle(color)
            .padding(.horizontal, 12)
            .padding(.vertical, 5)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
    }

    private var macroGrid: some View {
        HStack(spacing: 12) {
            macroPill(label: Lang.s("protein"), value: totalProtein, unit: "g", color: Color(red: 0.17, green: 0.60, blue: 0.52))
            macroPill(label: Lang.s("carbs"), value: totalCarbs, unit: "g", color: .orange)
            macroPill(label: Lang.s("fat"), value: totalFat, unit: "g", color: Color(red: 0.72, green: 0.08, blue: 0.08))
        }
    }

    private func macroPill(label: String, value: Double, unit: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Text(String(format: "%.1f%@", value, unit))
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(color)
                .contentTransition(.numericText())
                .animation(.spring(response: 0.35), value: value)
            Text(label)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(color.opacity(0.08))
        .clipShape(.rect(cornerRadius: 14))
    }

    private var ingredientsBreakdown: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "list.bullet")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.wellnessTeal)
                Text(Lang.s("ingredients"))
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.primary)
                Spacer()
                Button {
                    showAddIngredient = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                        Text(Lang.s("add"))
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.wellnessTeal)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 4)

            if editableIngredients.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "fork.knife")
                        .font(.title2)
                        .foregroundStyle(.tertiary)
                    Text(Lang.s("no_ingredients"))
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
            } else {
                VStack(spacing: 0) {
                    ForEach(editableIngredients) { ingredient in
                        editableIngredientRow(ingredient)
                        if ingredient.id != editableIngredients.last?.id {
                            Divider()
                                .padding(.leading, 16)
                        }
                    }
                }
                .background(Color(.tertiarySystemBackground))
                .clipShape(.rect(cornerRadius: 14))
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: 16))
    }

    private func editableIngredientRow(_ ingredient: ScannedIngredient) -> some View {
        HStack(spacing: 10) {
            VStack(alignment: .leading, spacing: 2) {
                Text(ingredient.name)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)
                Text(ingredient.quantity)
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            HStack(spacing: 8) {
                ingredientMacroTag(Lang.s("protein_short"), value: ingredient.protein, color: Color(red: 0.17, green: 0.60, blue: 0.52))
                ingredientMacroTag(Lang.s("carbs_short"), value: ingredient.carbs, color: .orange)
                ingredientMacroTag(Lang.s("fat_short"), value: ingredient.fat, color: Color(red: 0.72, green: 0.08, blue: 0.08))
            }

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text("\(ingredient.calories)")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color.wellnessTeal)
                Text("kcal")
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
            }
            .frame(minWidth: 50, alignment: .trailing)

            Button {
                editingIngredient = ingredient
            } label: {
                Image(systemName: "pencil")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.wellnessTeal)
                    .frame(width: 28, height: 28)
                    .background(Color.wellnessTeal.opacity(0.10))
                    .clipShape(.rect(cornerRadius: 7))
            }
            .buttonStyle(.plain)

            Button {
                withAnimation(.spring(response: 0.35)) {
                    editableIngredients.removeAll { $0.id == ingredient.id }
                }
            } label: {
                Image(systemName: "minus.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(.red.opacity(0.75))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }

    private func ingredientMacroTag(_ label: String, value: Double, color: Color) -> some View {
        HStack(spacing: 3) {
            Circle()
                .fill(color)
                .frame(width: 5, height: 5)
            Text(String(format: "%@ %.0fg", label, value))
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal, 5)
        .padding(.vertical, 3)
        .background(color.opacity(0.06))
        .clipShape(Capsule())
    }

    private var servingCard: some View {
        HStack {
            Image(systemName: "scalemass")
                .font(.system(size: 18))
                .foregroundStyle(Color.wellnessTeal)
            Text(Lang.s("serving_size"))
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
            Spacer()
            Text(result.servingSize)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.primary)
        }
        .padding(16)
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: 14))
    }

    private var notesCard: some View {
        Group {
            if !result.notes.isEmpty {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 18))
                        .foregroundStyle(Color.wellnessTeal)
                    Text(result.notes)
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.wellnessTeal.opacity(0.06))
                .clipShape(.rect(cornerRadius: 14))
            }
        }
    }

    private var doneButton: some View {
        Button { dismiss() } label: {
            Text(Lang.s("done"))
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.wellnessTeal)
                .clipShape(.rect(cornerRadius: 16))
        }
    }
}

private struct CalorieIngredientEditSheet: View {
    let ingredient: ScannedIngredient
    let onSave: (ScannedIngredient) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var name: String
    @State private var quantity: String
    @State private var caloriesText: String
    @State private var proteinText: String
    @State private var carbsText: String
    @State private var fatText: String
    @State private var baseQuantityGrams: Double
    @State private var baseCalories: Double
    @State private var baseProtein: Double
    @State private var baseCarbs: Double
    @State private var baseFat: Double

    init(ingredient: ScannedIngredient, onSave: @escaping (ScannedIngredient) -> Void) {
        self.ingredient = ingredient
        self.onSave = onSave
        _name = State(initialValue: ingredient.name)
        _quantity = State(initialValue: ingredient.quantity)
        _caloriesText = State(initialValue: "\(ingredient.calories)")
        _proteinText = State(initialValue: String(format: "%.1f", ingredient.protein))
        _carbsText = State(initialValue: String(format: "%.1f", ingredient.carbs))
        _fatText = State(initialValue: String(format: "%.1f", ingredient.fat))
        let parsed = CalorieIngredientEditSheet.parseGramsStatic(from: ingredient.quantity) ?? 100
        _baseQuantityGrams = State(initialValue: parsed)
        _baseCalories = State(initialValue: Double(ingredient.calories))
        _baseProtein = State(initialValue: ingredient.protein)
        _baseCarbs = State(initialValue: ingredient.carbs)
        _baseFat = State(initialValue: ingredient.fat)
    }

    private static func parseGramsStatic(from text: String) -> Double? {
        let cleaned = text.trimmingCharacters(in: .whitespaces).lowercased().replacingOccurrences(of: "g", with: "").replacingOccurrences(of: ",", with: ".").trimmingCharacters(in: .whitespaces)
        return Double(cleaned)
    }

    private func recalculateMacros() {
        guard baseQuantityGrams > 0, let newGrams = Self.parseGramsStatic(from: quantity), newGrams > 0 else { return }
        let ratio = newGrams / baseQuantityGrams
        caloriesText = "\(Int(round(baseCalories * ratio)))"
        proteinText = String(format: "%.1f", baseProtein * ratio)
        carbsText = String(format: "%.1f", baseCarbs * ratio)
        fatText = String(format: "%.1f", baseFat * ratio)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(Lang.s("ingredient")) {
                    TextField(Lang.s("ingredient_name_placeholder"), text: $name)
                    TextField(Lang.s("quantity_placeholder"), text: $quantity)
                        .keyboardType(.decimalPad)
                        .onChange(of: quantity) { _, _ in
                            recalculateMacros()
                        }
                }
                Section(Lang.s("nutritional_values")) {
                    HStack {
                        Text(Lang.s("calories"))
                        Spacer()
                        TextField("kcal", text: $caloriesText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    HStack {
                        Text(Lang.s("protein"))
                        Spacer()
                        TextField("g", text: $proteinText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    HStack {
                        Text(Lang.s("carbs"))
                        Spacer()
                        TextField("g", text: $carbsText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    HStack {
                        Text(Lang.s("fat"))
                        Spacer()
                        TextField("g", text: $fatText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                }
            }
            .navigationTitle(Lang.s("edit_ingredient"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(Lang.s("cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(Lang.s("save")) {
                        var updated = ingredient
                        updated.name = name.isEmpty ? ingredient.name : name
                        updated.quantity = quantity
                        updated.calories = Int(caloriesText) ?? ingredient.calories
                        updated.protein = Double(proteinText.replacingOccurrences(of: ",", with: ".")) ?? ingredient.protein
                        updated.carbs = Double(carbsText.replacingOccurrences(of: ",", with: ".")) ?? ingredient.carbs
                        updated.fat = Double(fatText.replacingOccurrences(of: ",", with: ".")) ?? ingredient.fat
                        onSave(updated)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}

private struct CalorieAddIngredientSheet: View {
    let onAdd: (ScannedIngredient) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    @State private var quantity: String = ""
    @State private var caloriesText: String = ""
    @State private var proteinText: String = "0"
    @State private var carbsText: String = "0"
    @State private var fatText: String = "0"
    @State private var isLookingUp: Bool = false
    @State private var lookupError: String? = nil
    @State private var aiFilledFields: Bool = false
    @State private var baseQuantityGrams: Double = 100
    @State private var baseCalories: Double = 0
    @State private var baseProtein: Double = 0
    @State private var baseCarbs: Double = 0
    @State private var baseFat: Double = 0

    private var canAdd: Bool { !name.isEmpty && !caloriesText.isEmpty && Int(caloriesText) != nil }

    private func parseGrams(from text: String) -> Double? {
        let cleaned = text.trimmingCharacters(in: .whitespaces).lowercased().replacingOccurrences(of: "g", with: "").replacingOccurrences(of: ",", with: ".").trimmingCharacters(in: .whitespaces)
        return Double(cleaned)
    }

    private func recalculateMacros() {
        guard baseQuantityGrams > 0, let newGrams = parseGrams(from: quantity), newGrams > 0 else { return }
        let ratio = newGrams / baseQuantityGrams
        caloriesText = "\(Int(round(baseCalories * ratio)))"
        proteinText = String(format: "%.1f", baseProtein * ratio)
        carbsText = String(format: "%.1f", baseCarbs * ratio)
        fatText = String(format: "%.1f", baseFat * ratio)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    HStack(spacing: 10) {
                        TextField(Lang.s("ingredient_name_placeholder"), text: $name)
                            .autocorrectionDisabled()
                            .onChange(of: name) { _, _ in
                                aiFilledFields = false
                                lookupError = nil
                            }
                        if isLookingUp {
                            ProgressView()
                                .scaleEffect(0.85)
                                .tint(Color.wellnessTeal)
                        } else {
                            Button {
                                Task { await lookupWithAI() }
                            } label: {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundStyle(name.trimmingCharacters(in: .whitespaces).isEmpty ? Color.secondary : Color.wellnessTeal)
                            }
                            .buttonStyle(.plain)
                            .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                        }
                    }
                } header: {
                    Text(Lang.s("ingredient"))
                } footer: {
                    if aiFilledFields {
                        Label(Lang.s("values_autofilled_ai"), systemImage: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.green)
                    } else if let err = lookupError {
                        Text(err)
                            .font(.caption)
                            .foregroundStyle(.red)
                    } else {
                        Text(Lang.s("type_name_tap_ai"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Section(Lang.s("quantity_placeholder")) {
                    TextField(Lang.s("quantity_placeholder"), text: $quantity)
                        .keyboardType(.decimalPad)
                        .onChange(of: quantity) { _, _ in
                            if aiFilledFields {
                                recalculateMacros()
                            }
                        }
                }

                Section(Lang.s("nutritional_values")) {
                    HStack {
                        Text(Lang.s("calories"))
                        Spacer()
                        TextField("kcal", text: $caloriesText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                            .foregroundStyle(aiFilledFields ? Color.wellnessTeal : .primary)
                    }
                    HStack {
                        Text(Lang.s("protein"))
                        Spacer()
                        TextField("g", text: $proteinText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                            .foregroundStyle(aiFilledFields ? Color.wellnessTeal : .primary)
                    }
                    HStack {
                        Text(Lang.s("carbs"))
                        Spacer()
                        TextField("g", text: $carbsText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                            .foregroundStyle(aiFilledFields ? Color.wellnessTeal : .primary)
                    }
                    HStack {
                        Text(Lang.s("fat"))
                        Spacer()
                        TextField("g", text: $fatText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                            .foregroundStyle(aiFilledFields ? Color.wellnessTeal : .primary)
                    }
                }
            }
            .navigationTitle(Lang.s("add_ingredient"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(Lang.s("cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(Lang.s("add")) {
                        guard let cal = Int(caloriesText) else { return }
                        let ingredient = ScannedIngredient(
                            name: name,
                            quantity: quantity.isEmpty ? "100g" : quantity,
                            calories: cal,
                            protein: Double(proteinText.replacingOccurrences(of: ",", with: ".")) ?? 0,
                            carbs: Double(carbsText.replacingOccurrences(of: ",", with: ".")) ?? 0,
                            fat: Double(fatText.replacingOccurrences(of: ",", with: ".")) ?? 0
                        )
                        onAdd(ingredient)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(!canAdd)
                }
            }
        }
    }

    private func lookupWithAI() async {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        isLookingUp = true
        lookupError = nil
        aiFilledFields = false
        defer { isLookingUp = false }
        do {
            let result = try await AIService.lookupIngredientNutrition(name: trimmed)
            name = result.name
            quantity = result.quantity
            baseQuantityGrams = parseGrams(from: result.quantity) ?? 100
            baseCalories = Double(result.calories)
            baseProtein = result.protein
            baseCarbs = result.carbs
            baseFat = result.fat
            caloriesText = "\(result.calories)"
            proteinText = String(format: "%.1f", result.protein)
            carbsText = String(format: "%.1f", result.carbs)
            fatText = String(format: "%.1f", result.fat)
            aiFilledFields = true
        } catch {
            lookupError = Lang.s("unable_retrieve_values")
        }
    }
}
