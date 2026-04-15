import SwiftUI

struct PantrySheet: View {
    @Environment(AppViewModel.self) private var appVM
    @Environment(\.dismiss) private var dismiss
    @State private var showAddManually: Bool = false
    @State private var showScanAI: Bool = false
    @State private var editingItem: PantryItem? = nil

    private let purpleColor = Color(red: 0.55, green: 0.27, blue: 0.88)

    var groupedItems: [(category: String, items: [PantryItem])] {
        let all = ShoppingListItem.allCategories
        return all.compactMap { cat in
            let items = appVM.pantryItems.filter { $0.category == cat }
            guard !items.isEmpty else { return nil }
            return (category: cat, items: items)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    headerSection
                    actionButtons
                    if appVM.pantryItems.isEmpty {
                        emptyState
                    } else {
                        pantryContent
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
            .scrollIndicators(.hidden)
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
        .sheet(isPresented: $showAddManually) {
            AddPantryItemSheet()
        }
        .sheet(isPresented: $showScanAI) {
            PantryScanAIView()
                .environment(appVM)
        }
        .sheet(item: $editingItem) { item in
            EditPantryItemSheet(item: item)
                .environment(appVM)
        }
    }

    private var headerSection: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.wellnessTeal)
                    .frame(width: 48, height: 48)
                Image(systemName: "cabinet.fill")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white)
            }
            VStack(alignment: .leading, spacing: 3) {
                Text(Lang.s("pantry_custom"))
                    .font(.title3.bold())
                Text(Lang.s("pantry_manage_desc"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.top, 4)
    }

    private var actionButtons: some View {
        VStack(spacing: 10) {
            Button {
                showScanAI = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "sparkles")
                        .font(.body.weight(.semibold))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(Lang.s("pantry_scan_ai"))
                            .font(.headline)
                        Text(Lang.s("pantry_scan_desc"))
                            .font(.caption)
                            .opacity(0.85)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(
                    LinearGradient(
                        colors: [Color(red: 0.55, green: 0.27, blue: 0.88), Color(red: 0.92, green: 0.27, blue: 0.55)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)

            Button {
                showAddManually = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "plus")
                        .font(.body.weight(.semibold))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(Lang.s("pantry_add_manual"))
                            .font(.headline)
                        Text(Lang.s("pantry_add_manual_desc"))
                            .font(.caption)
                            .opacity(0.85)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(Color.wellnessTeal)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .buttonStyle(.plain)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "cabinet")
                .font(.system(size: 40))
                .foregroundStyle(.tertiary)
            Text(Lang.s("pantry_empty"))
                .font(.headline)
                .foregroundStyle(.secondary)
            Text(Lang.s("pantry_empty_desc"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 40)
        .frame(maxWidth: .infinity)
    }

    private var pantryContent: some View {
        VStack(spacing: 12) {
            ForEach(groupedItems, id: \.category) { group in
                pantryCategory(category: group.category, items: group.items)
            }
        }
    }

    private func pantryCategory(category: String, items: [PantryItem]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Text(ShoppingListItem.categoryEmoji(category))
                    .font(.title3)
                Text(category)
                    .font(.subheadline.weight(.semibold))
            }
            .padding(.horizontal, 14)
            .padding(.top, 14)

            ForEach(items) { item in
                pantryItemRow(item: item)
                    .padding(.horizontal, 14)
                if item.id != items.last?.id {
                    Divider().padding(.horizontal, 14)
                }
            }
            Spacer().frame(height: 6)
        }
        .background(categoryBackground(category))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func categoryBackground(_ category: String) -> Color {
        switch category {
        case "Meat and Fish": return Color(red: 1.0, green: 0.95, blue: 0.95)
        case "Fruits and Vegetables": return Color(red: 0.95, green: 1.0, blue: 0.95)
        case "Dairy and Eggs": return Color(red: 0.95, green: 0.97, blue: 1.0)
        case "Grains and Pasta": return Color(red: 1.0, green: 0.99, blue: 0.90)
        case "Legumes and Nuts": return Color(red: 1.0, green: 0.97, blue: 0.90)
        case "Oils and Fats": return Color(red: 0.98, green: 0.99, blue: 0.93)
        case "Beverages": return Color(red: 0.94, green: 0.97, blue: 1.0)
        case "Condiments and Spices": return Color(red: 1.0, green: 1.0, blue: 0.96)
        case "Other": return Color(red: 0.97, green: 0.97, blue: 0.97)
        default: return Color(red: 0.97, green: 0.97, blue: 0.97)
        }
    }

    private func pantryItemRow(item: PantryItem) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.name)
                        .font(.subheadline.weight(.semibold))
                    Text("\(item.calories) kcal • P: \(String(format: "%.1f", item.protein))g • C: \(String(format: "%.1f", item.carbs))g • G: \(String(format: "%.1f", item.fat))g (\(item.unit))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    if let brand = item.brand, let type = item.type {
                        Text("\(Lang.s("pantry_brand")): \(brand). \(Lang.s("pantry_type")): \(type)")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                            .italic()
                    }
                }
                Spacer()
                HStack(spacing: 14) {
                    Button {
                        editingItem = item
                    } label: {
                        Image(systemName: "pencil")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)

                    Button {
                        appVM.deletePantryItem(id: item.id)
                    } label: {
                        Image(systemName: "trash")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(.vertical, 10)
    }
}

struct EditPantryItemSheet: View {
    @Environment(AppViewModel.self) private var appVM
    @Environment(\.dismiss) private var dismiss
    let item: PantryItem
    @State private var name: String = ""
    @State private var brand: String = ""
    @State private var calories: String = ""
    @State private var protein: String = ""
    @State private var carbs: String = ""
    @State private var fat: String = ""
    @State private var selectedCategory: String = "Condiments and Spices"

    var body: some View {
        NavigationStack {
            Form {
                Section(Lang.s("pantry_product_info")) {
                    TextField(Lang.s("pantry_name"), text: $name)
                    TextField(Lang.s("pantry_brand_optional"), text: $brand)
                    Picker(Lang.s("pantry_category"), selection: $selectedCategory) {
                        ForEach(ShoppingListItem.allCategories, id: \.self) { cat in
                            Text(cat).tag(cat)
                        }
                    }
                }
                Section(Lang.s("pantry_nutri_values")) {
                    TextField(Lang.s("pantry_calories_kcal"), text: $calories)
                        .keyboardType(.numberPad)
                    TextField(Lang.s("pantry_protein_g"), text: $protein)
                        .keyboardType(.decimalPad)
                    TextField(Lang.s("pantry_carbs_g"), text: $carbs)
                        .keyboardType(.decimalPad)
                    TextField(Lang.s("pantry_fat_g"), text: $fat)
                        .keyboardType(.decimalPad)
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
                        var updated = item
                        updated.name = name
                        updated.brand = brand.isEmpty ? nil : brand
                        updated.calories = Int(calories) ?? 0
                        updated.protein = Double(protein) ?? 0
                        updated.carbs = Double(carbs) ?? 0
                        updated.fat = Double(fat) ?? 0
                        updated.category = selectedCategory
                        appVM.updatePantryItem(updated)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
            .onAppear {
                name = item.name
                brand = item.brand ?? ""
                calories = "\(item.calories)"
                protein = String(format: "%.1f", item.protein)
                carbs = String(format: "%.1f", item.carbs)
                fat = String(format: "%.1f", item.fat)
                selectedCategory = item.category
            }
        }
    }
}

struct AddPantryItemSheet: View {
    @Environment(AppViewModel.self) private var appVM
    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    @State private var brand: String = ""
    @State private var calories: String = ""
    @State private var protein: String = ""
    @State private var carbs: String = ""
    @State private var fat: String = ""
    @State private var selectedCategory: String = "Condiments and Spices"

    var body: some View {
        NavigationStack {
            Form {
                Section(Lang.s("pantry_product_info")) {
                    TextField(Lang.s("pantry_name"), text: $name)
                    TextField(Lang.s("pantry_brand_optional"), text: $brand)
                    Picker(Lang.s("pantry_category"), selection: $selectedCategory) {
                        ForEach(ShoppingListItem.allCategories, id: \.self) { cat in
                            Text(cat).tag(cat)
                        }
                    }
                }
                Section(Lang.s("pantry_nutri_values")) {
                    TextField(Lang.s("pantry_calories_kcal"), text: $calories)
                        .keyboardType(.numberPad)
                    TextField(Lang.s("pantry_protein_g"), text: $protein)
                        .keyboardType(.decimalPad)
                    TextField(Lang.s("pantry_carbs_g"), text: $carbs)
                        .keyboardType(.decimalPad)
                    TextField(Lang.s("pantry_fat_g"), text: $fat)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle(Lang.s("pantry_add_ingredient"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(Lang.s("cancel")) { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(Lang.s("save")) {
                        let item = PantryItem(
                            name: name,
                            brand: brand.isEmpty ? nil : brand,
                            calories: Int(calories) ?? 0,
                            protein: Double(protein) ?? 0,
                            carbs: Double(carbs) ?? 0,
                            fat: Double(fat) ?? 0,
                            category: selectedCategory
                        )
                        appVM.addPantryItem(item)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}
