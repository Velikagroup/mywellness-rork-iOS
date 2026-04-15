import SwiftUI

struct MealPhotoScanView: View {
    let meal: Meal
    let onAdd: (CalorieAnalysisResult, UIImage?) -> Void
    var openCameraOnAppear: Bool = false
    @Environment(\.dismiss) private var dismiss
    @State private var selectedImage: UIImage?
    @State private var isAnalyzing: Bool = false
    @State private var baseResult: CalorieAnalysisResult?
    @State private var editableIngredients: [ScannedIngredient] = []
    @State private var errorMessage: String?
    @State private var showCameraPicker: Bool = false
    @State private var editingIngredient: ScannedIngredient? = nil
    @State private var showAddIngredient: Bool = false

    private var totalCalories: Int {
        editableIngredients.isEmpty ? (baseResult?.calories ?? 0) : editableIngredients.reduce(0) { $0 + $1.calories }
    }

    private var totalProtein: Double {
        editableIngredients.isEmpty ? (baseResult?.protein ?? 0) : editableIngredients.reduce(0.0) { $0 + $1.protein }
    }

    private var totalCarbs: Double {
        editableIngredients.isEmpty ? (baseResult?.carbs ?? 0) : editableIngredients.reduce(0.0) { $0 + $1.carbs }
    }

    private var totalFat: Double {
        editableIngredients.isEmpty ? (baseResult?.fat ?? 0) : editableIngredients.reduce(0.0) { $0 + $1.fat }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    mealHeader
                    imageSection
                    if isAnalyzing {
                        analyzingSection
                    } else if baseResult != nil {
                        summaryCard
                        ingredientsCard
                        actionButtons
                    }
                    if let err = errorMessage {
                        Text(err)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                }
                .padding(20)
                .padding(.bottom, 40)
            }
            .navigationTitle("\(Lang.s("scan_meal_title")) \(meal.type.localizedName)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(Lang.s("cancel")) { dismiss() }
                }
            }
        }
        .onAppear {
            if openCameraOnAppear { showCameraPicker = true }
        }
        .fullScreenCover(isPresented: $showCameraPicker) {
            CameraCapturePicker { image in
                showCameraPicker = false
                guard let image else { return }
                selectedImage = image
                baseResult = nil
                editableIngredients = []
                errorMessage = nil
                Task { await analyzeImage(image) }
            }
            .ignoresSafeArea()
        }
        .sheet(item: $editingIngredient) { ingredient in
            IngredientEditSheet(ingredient: ingredient) { updated in
                if let idx = editableIngredients.firstIndex(where: { $0.id == updated.id }) {
                    editableIngredients[idx] = updated
                }
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showAddIngredient) {
            AddIngredientSheet { newIngredient in
                withAnimation(.spring(response: 0.35)) {
                    editableIngredients.append(newIngredient)
                }
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
    }

    private var mealHeader: some View {
        VStack(spacing: 6) {
            HStack(spacing: 10) {
                Image(systemName: meal.type.icon)
                    .font(.title3)
                    .foregroundStyle(Color.wellnessTeal)
                Text(meal.name)
                    .font(.headline)
                    .lineLimit(1)
            }
            Text(Lang.s("take_photo_analyze"))
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }

    private var imageSection: some View {
        Button(action: { showCameraPicker = true }) {
            if let img = selectedImage {
                Color(.secondarySystemBackground)
                    .frame(height: 200)
                    .overlay {
                        Image(uiImage: img)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .allowsHitTesting(false)
                    }
                    .clipShape(.rect(cornerRadius: 20))
                    .overlay(alignment: .bottomTrailing) {
                        if !isAnalyzing && baseResult != nil {
                            Label(Lang.s("change_photo"), systemImage: "camera.fill")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(.black.opacity(0.55))
                                .clipShape(.capsule)
                                .padding(12)
                        }
                    }
            } else {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.secondarySystemBackground))
                    .frame(height: 200)
                    .overlay {
                        VStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(Color.wellnessTeal.opacity(0.12))
                                    .frame(width: 72, height: 72)
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 30))
                                    .foregroundStyle(Color.wellnessTeal)
                            }
                            VStack(spacing: 4) {
                                Text(Lang.s("tap_take_photo"))
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.primary)
                                Text(Lang.s("take_food_photo"))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
            }
        }
        .buttonStyle(.plain)
    }

    private var analyzingSection: some View {
        VStack(spacing: 14) {
            ProgressView()
                .scaleEffect(1.3)
                .tint(Color.wellnessTeal)
            Text(Lang.s("ai_analyzing_food"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(Lang.s("detecting_ingredients"))
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 28)
        .background(Color.wellnessTeal.opacity(0.05))
        .clipShape(.rect(cornerRadius: 16))
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(baseResult?.foodName ?? "")
                        .font(.title3.weight(.bold))
                    Text(baseResult?.servingSize ?? "")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                let conf = baseResult?.confidence ?? "Medium"
                let confColor: Color = conf == "High" ? .green : conf == "Medium" ? .orange : .red
                Text(conf)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(confColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(confColor.opacity(0.12))
                    .clipShape(.capsule)
            }

            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(totalCalories)")
                    .font(.system(size: 46, weight: .heavy, design: .rounded))
                    .foregroundStyle(Color.wellnessTeal)
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.35), value: totalCalories)
                Text("kcal")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Color.wellnessTeal)
                Spacer()
                Text(Lang.s("total_auto_updated"))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: 90)
            }

            HStack(spacing: 10) {
                macroPill(Lang.s("protein"), value: totalProtein, color: .red)
                macroPill(Lang.s("carbs"), value: totalCarbs, color: .blue)
                macroPill(Lang.s("fat"), value: totalFat, color: .orange)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.wellnessTeal.opacity(0.07))
        .clipShape(.rect(cornerRadius: 16))
    }

    private var ingredientsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(Lang.s("ingredients"), systemImage: "list.bullet")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                Spacer()
                Button {
                    showAddIngredient = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                        Text(Lang.s("add"))
                    }
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.wellnessTeal)
                }
                .buttonStyle(.plain)
            }

            if editableIngredients.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "fork.knife")
                        .font(.title2)
                        .foregroundStyle(.tertiary)
                    Text(Lang.s("no_ingredients_detected"))
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
            } else {
                VStack(spacing: 0) {
                    ForEach(editableIngredients) { ingredient in
                        ScanIngredientRow(ingredient: ingredient) {
                            editingIngredient = ingredient
                        } onDelete: {
                            withAnimation(.spring(response: 0.35)) {
                                editableIngredients.removeAll { $0.id == ingredient.id }
                            }
                        }
                        if ingredient.id != editableIngredients.last?.id {
                            Divider()
                                .padding(.leading, 14)
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

    private var actionButtons: some View {
        VStack(spacing: 10) {
            Button {
                guard let result = baseResult else { return }
                let finalResult = CalorieAnalysisResult(
                    foodName: result.foodName,
                    calories: totalCalories,
                    protein: totalProtein,
                    carbs: totalCarbs,
                    fat: totalFat,
                    servingSize: result.servingSize,
                    confidence: result.confidence,
                    notes: result.notes,
                    ingredients: editableIngredients
                )
                onAdd(finalResult, selectedImage)
                dismiss()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                    Text("\(Lang.s("confirm_mark_eaten")) · \(totalCalories) kcal")
                        .font(.headline)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color.wellnessTeal)
                .foregroundStyle(.white)
                .clipShape(.rect(cornerRadius: 16))
                .shadow(color: Color.wellnessTeal.opacity(0.3), radius: 8, y: 3)
            }

            Button {
                showCameraPicker = true
            } label: {
                Label(Lang.s("take_another_photo"), systemImage: "camera.fill")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(.rect(cornerRadius: 14))
            }
            .buttonStyle(.plain)
        }
    }

    private func macroPill(_ label: String, value: Double, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(String(format: "%.0fg", value))
                .font(.system(.subheadline, weight: .bold))
                .foregroundStyle(color)
                .contentTransition(.numericText())
                .animation(.spring(response: 0.35), value: value)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 10)
        .background(color.opacity(0.08))
        .clipShape(.rect(cornerRadius: 10))
    }

    private func analyzeImage(_ image: UIImage) async {
        isAnalyzing = true
        errorMessage = nil
        defer { isAnalyzing = false }
        guard let base64 = AIService.compressImageForAI(image) else {
            errorMessage = Lang.s("image_error")
            return
        }
        do {
            let result = try await AIService.analyzeCalories(imageBase64: base64)
            baseResult = result
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
        } catch {
            errorMessage = Lang.s("analysis_failed")
        }
    }
}

private struct ScanIngredientRow: View {
    let ingredient: ScannedIngredient
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(ingredient.name)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(1)
                Text(ingredient.quantity)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text("\(ingredient.calories)")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color.wellnessTeal)
                Text("kcal")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            Button(action: onEdit) {
                Image(systemName: "pencil")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.wellnessTeal)
                    .frame(width: 28, height: 28)
                    .background(Color.wellnessTeal.opacity(0.10))
                    .clipShape(.rect(cornerRadius: 7))
            }
            .buttonStyle(.plain)

            Button(action: onDelete) {
                Image(systemName: "minus.circle.fill")
                    .font(.title3)
                    .foregroundStyle(.red.opacity(0.75))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }
}

private struct IngredientEditSheet: View {
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
        let parsed = IngredientEditSheet.parseGramsStatic(from: ingredient.quantity) ?? 100
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
                    TextField(Lang.s("name_label"), text: $name)
                    TextField(Lang.s("quantity_label"), text: $quantity)
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
            .navigationTitle(Lang.s("edit_ingredient_title"))
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

private struct AddIngredientSheet: View {
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
                        TextField(Lang.s("ingredient_name_ph"), text: $name)
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
                        Label(Lang.s("ai_values_filled"), systemImage: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundStyle(.green)
                    } else if let err = lookupError {
                        Text(err)
                            .font(.caption)
                            .foregroundStyle(.red)
                    } else {
                        Text(Lang.s("type_name_tap_ai_hint"))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Section(Lang.s("details_section")) {
                    TextField(Lang.s("quantity_label"), text: $quantity)
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
            .navigationTitle(Lang.s("add_ingredient_title"))
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
            lookupError = Lang.s("unable_retrieve")
        }
    }
}
