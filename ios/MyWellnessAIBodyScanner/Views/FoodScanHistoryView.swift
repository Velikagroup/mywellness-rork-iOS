import SwiftUI
import Charts

struct FoodScanHistoryView: View {
    @Environment(AppViewModel.self) private var appVM
    @Environment(\.dismiss) private var dismiss
    @State private var selectedRecord: FoodScanRecord?
    @State private var recordToEdit: FoodScanRecord?

    private var sortedRecords: [FoodScanRecord] {
        appVM.foodScanHistory.sorted { $0.date > $1.date }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()

                if appVM.foodScanHistory.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            trendChart
                            recordsList
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle(Lang.s("food_scan_history"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .sheet(item: $recordToEdit) { record in
            FoodScanRecordEditView(record: record)
                .environment(appVM)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationContentInteraction(.scrolls)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "fork.knife.circle")
                .font(.system(size: 48))
                .foregroundStyle(.tertiary)
            Text(Lang.s("no_scans_yet"))
                .font(.title3.weight(.semibold))
            Text(Lang.s("scan_food_track"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var trendChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(Lang.s("calorie_trend"), systemImage: "chart.line.uptrend.xyaxis")
                .font(.headline)

            let chronological = appVM.foodScanHistory.sorted { $0.date < $1.date }

            if chronological.count >= 2 {
                Chart {
                    ForEach(chronological) { record in
                        LineMark(
                            x: .value("Date", record.date),
                            y: .value("Calories", record.totalCalories)
                        )
                        .foregroundStyle(Color.wellnessTeal)
                        .interpolationMethod(.catmullRom)

                        PointMark(
                            x: .value("Date", record.date),
                            y: .value("Calories", record.totalCalories)
                        )
                        .foregroundStyle(Color.wellnessTeal)
                        .symbolSize(40)

                        AreaMark(
                            x: .value("Date", record.date),
                            y: .value("Calories", record.totalCalories)
                        )
                        .foregroundStyle(
                            .linearGradient(
                                colors: [Color.wellnessTeal.opacity(0.2), Color.wellnessTeal.opacity(0.0)],
                                startPoint: .top, endPoint: .bottom
                            )
                        )
                        .interpolationMethod(.catmullRom)
                    }
                }
                .frame(height: 160)
                .chartXAxis {
                    AxisMarks(values: .automatic) { value in
                        AxisValueLabel {
                            if let date = value.as(Date.self) {
                                Text(date, format: .dateTime.month(.abbreviated).day())
                                    .font(.caption2)
                            }
                        }
                        AxisGridLine()
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisValueLabel {
                            if let v = value.as(Int.self) {
                                Text("\(v)")
                                    .font(.caption2)
                            }
                        }
                        AxisGridLine(stroke: StrokeStyle(lineWidth: 0.5, dash: [4]))
                    }
                }
            } else {
                HStack(spacing: 16) {
                    summaryPill(label: Lang.s("total_scans"), value: "\(chronological.count)", icon: "camera.fill", color: Color.wellnessTeal)
                    if let last = chronological.last {
                        summaryPill(label: Lang.s("last_scan"), value: "\(last.totalCalories) kcal", icon: "flame.fill", color: .orange)
                    }
                }
                Text(Lang.s("scan_more_foods_trend"))
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .padding(.top, 4)
            }
        }
        .padding(16)
        .background(.white.opacity(0.8))
        .clipShape(.rect(cornerRadius: 16))
    }

    private func summaryPill(label: String, value: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundStyle(color)
            Text(value)
                .font(.title3.weight(.bold))
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(color.opacity(0.08))
        .clipShape(.rect(cornerRadius: 12))
    }

    private var recordsList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(Lang.s("records"), systemImage: "clock.arrow.circlepath")
                .font(.headline)

            ForEach(sortedRecords) { record in
                recordCard(record)
            }
        }
    }

    private func recordCard(_ record: FoodScanRecord) -> some View {
        Button {
            recordToEdit = record
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    if let data = record.imageData, let img = UIImage(data: data) {
                        Color(.secondarySystemGroupedBackground)
                            .frame(width: 50, height: 50)
                            .overlay {
                                Image(uiImage: img)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .allowsHitTesting(false)
                            }
                            .clipShape(.rect(cornerRadius: 10))
                    } else {
                        ZStack {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color.wellnessTeal.opacity(0.1))
                                .frame(width: 50, height: 50)
                            Image(systemName: "fork.knife")
                                .font(.title3)
                                .foregroundStyle(Color.wellnessTeal)
                        }
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text(record.foodName)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                        Text(record.formattedDate)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        HStack(alignment: .firstTextBaseline, spacing: 2) {
                            Text("\(record.totalCalories)")
                                .font(.headline.weight(.bold))
                                .foregroundStyle(Color.wellnessTeal)
                            Text("kcal")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        Text("\(record.ingredients.count) \(Lang.s("items"))")
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }

                HStack(spacing: 10) {
                    macroTag(value: record.totalProtein, label: "P", color: .red)
                    macroTag(value: record.totalCarbs, label: "C", color: .blue)
                    macroTag(value: record.totalFat, label: "F", color: .orange)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
            }
            .padding(14)
            .background(.white.opacity(0.8))
            .clipShape(.rect(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button(role: .destructive) {
                withAnimation { appVM.deleteFoodScanRecord(id: record.id) }
            } label: {
                Label(Lang.s("delete"), systemImage: "trash")
            }
        }
    }

    private func macroTag(value: Double, label: String, color: Color) -> some View {
        Text(String(format: "%.0f%@", value, label))
            .font(.caption2.weight(.semibold))
            .foregroundStyle(color)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.1))
            .clipShape(.capsule)
    }
}

struct FoodScanRecordEditView: View {
    @Environment(AppViewModel.self) private var appVM
    @Environment(\.dismiss) private var dismiss
    @State private var record: FoodScanRecord
    @State private var editingIngredient: ScannedIngredient?
    @State private var showAddIngredient: Bool = false

    init(record: FoodScanRecord) {
        _record = State(initialValue: record)
    }

    private var totalCalories: Int {
        record.ingredients.isEmpty ? record.totalCalories : record.ingredients.reduce(0) { $0 + $1.calories }
    }
    private var totalProtein: Double {
        record.ingredients.isEmpty ? record.totalProtein : record.ingredients.reduce(0.0) { $0 + $1.protein }
    }
    private var totalCarbs: Double {
        record.ingredients.isEmpty ? record.totalCarbs : record.ingredients.reduce(0.0) { $0 + $1.carbs }
    }
    private var totalFat: Double {
        record.ingredients.isEmpty ? record.totalFat : record.ingredients.reduce(0.0) { $0 + $1.fat }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    headerCard
                    summaryCard
                    ingredientsCard
                }
                .padding(20)
                .padding(.bottom, 40)
            }
            .navigationTitle(record.foodName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(Lang.s("close")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(Lang.s("save")) {
                        var updated = record
                        updated.totalCalories = totalCalories
                        updated.totalProtein = totalProtein
                        updated.totalCarbs = totalCarbs
                        updated.totalFat = totalFat
                        appVM.updateFoodScanRecord(updated)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .sheet(item: $editingIngredient) { ingredient in
            FoodIngredientEditSheet(ingredient: ingredient) { updated in
                if let idx = record.ingredients.firstIndex(where: { $0.id == updated.id }) {
                    record.ingredients[idx] = updated
                }
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showAddIngredient) {
            FoodIngredientAddSheet { newIngredient in
                withAnimation(.spring(response: 0.35)) {
                    record.ingredients.append(newIngredient)
                }
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
    }

    private var headerCard: some View {
        HStack(spacing: 14) {
            if let data = record.imageData, let img = UIImage(data: data) {
                Color(.secondarySystemBackground)
                    .frame(width: 80, height: 80)
                    .overlay {
                        Image(uiImage: img)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .allowsHitTesting(false)
                    }
                    .clipShape(.rect(cornerRadius: 14))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(record.foodName)
                    .font(.title3.weight(.bold))
                Text(record.formattedDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                let confColor: Color = record.confidence == "High" ? .green : record.confidence == "Medium" ? .orange : .red
                Text(record.confidence)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(confColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(confColor.opacity(0.12))
                    .clipShape(.capsule)
            }
            Spacer()
        }
    }

    private var summaryCard: some View {
        VStack(spacing: 12) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(totalCalories)")
                    .font(.system(size: 42, weight: .heavy, design: .rounded))
                    .foregroundStyle(Color.wellnessTeal)
                    .contentTransition(.numericText())
                    .animation(.spring(response: 0.35), value: totalCalories)
                Text("kcal")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(Color.wellnessTeal)
                Spacer()
            }

            HStack(spacing: 10) {
                macroPill("Proteine", value: totalProtein, color: .red)
                macroPill("Carbo", value: totalCarbs, color: .blue)
                macroPill("Grassi", value: totalFat, color: .orange)
            }
        }
        .padding(16)
        .background(Color.wellnessTeal.opacity(0.07))
        .clipShape(.rect(cornerRadius: 16))
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

    private var ingredientsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label(Lang.s("ingredients"), systemImage: "list.bullet")
                    .font(.subheadline.weight(.semibold))
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

            if record.ingredients.isEmpty {
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
                    ForEach(record.ingredients) { ingredient in
                        ingredientRow(ingredient)
                        if ingredient.id != record.ingredients.last?.id {
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

    private func ingredientRow(_ ingredient: ScannedIngredient) -> some View {
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
                    record.ingredients.removeAll { $0.id == ingredient.id }
                }
            } label: {
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

private struct FoodIngredientEditSheet: View {
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
        let parsed = FoodIngredientEditSheet.parseGramsStatic(from: ingredient.quantity) ?? 100
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
                    TextField(Lang.s("ingredient"), text: $name)
                    TextField(Lang.s("quantity_placeholder"), text: $quantity)
                        .keyboardType(.decimalPad)
                        .onChange(of: quantity) { _, _ in
                            recalculateMacros()
                        }
                }
                Section(Lang.s("nutritional_values")) {
                    HStack { Text(Lang.s("calories")); Spacer(); TextField("kcal", text: $caloriesText).keyboardType(.numberPad).multilineTextAlignment(.trailing).frame(width: 80) }
                    HStack { Text(Lang.s("protein")); Spacer(); TextField("g", text: $proteinText).keyboardType(.decimalPad).multilineTextAlignment(.trailing).frame(width: 80) }
                    HStack { Text(Lang.s("carbs")); Spacer(); TextField("g", text: $carbsText).keyboardType(.decimalPad).multilineTextAlignment(.trailing).frame(width: 80) }
                    HStack { Text(Lang.s("fat")); Spacer(); TextField("g", text: $fatText).keyboardType(.decimalPad).multilineTextAlignment(.trailing).frame(width: 80) }
                }
            }
            .navigationTitle(Lang.s("edit_ingredient"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button(Lang.s("cancel")) { dismiss() } }
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

private struct FoodIngredientAddSheet: View {
    let onAdd: (ScannedIngredient) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    @State private var quantity: String = ""
    @State private var caloriesText: String = ""
    @State private var proteinText: String = "0"
    @State private var carbsText: String = "0"
    @State private var fatText: String = "0"
    @State private var isLookingUp: Bool = false
    @State private var lookupError: String?
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

                Section(Lang.s("details")) {
                    TextField(Lang.s("quantity_placeholder"), text: $quantity)
                        .keyboardType(.decimalPad)
                        .onChange(of: quantity) { _, _ in
                            if aiFilledFields {
                                recalculateMacros()
                            }
                        }
                }

                Section(Lang.s("nutritional_values")) {
                    HStack { Text(Lang.s("calories")); Spacer(); TextField("kcal", text: $caloriesText).keyboardType(.numberPad).multilineTextAlignment(.trailing).frame(width: 80).foregroundStyle(aiFilledFields ? Color.wellnessTeal : .primary) }
                    HStack { Text(Lang.s("protein")); Spacer(); TextField("g", text: $proteinText).keyboardType(.decimalPad).multilineTextAlignment(.trailing).frame(width: 80).foregroundStyle(aiFilledFields ? Color.wellnessTeal : .primary) }
                    HStack { Text(Lang.s("carbs")); Spacer(); TextField("g", text: $carbsText).keyboardType(.decimalPad).multilineTextAlignment(.trailing).frame(width: 80).foregroundStyle(aiFilledFields ? Color.wellnessTeal : .primary) }
                    HStack { Text(Lang.s("fat")); Spacer(); TextField("g", text: $fatText).keyboardType(.decimalPad).multilineTextAlignment(.trailing).frame(width: 80).foregroundStyle(aiFilledFields ? Color.wellnessTeal : .primary) }
                }
            }
            .navigationTitle(Lang.s("add_ingredient"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button(Lang.s("cancel")) { dismiss() } }
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
