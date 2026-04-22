import SwiftUI

struct ShoppingListSheet: View {
    @Environment(AppViewModel.self) private var appVM
    @Environment(\.dismiss) private var dismiss
    @State private var expandedCategories: Set<String> = []
    @State private var showComparisonScanner: Bool = false
    @State private var comparisonItemName: String = ""

    private var grouped: [(category: String, items: [ShoppingListItem])] {
        ShoppingListItem.allCategories.compactMap { cat in
            let items = appVM.shoppingListItems.filter { $0.category == cat }
            guard !items.isEmpty else { return nil }
            return (category: cat, items: items)
        }
    }

    private var checkedCount: Int {
        appVM.shoppingListItems.filter { $0.isChecked }.count
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    if appVM.shoppingListItems.isEmpty {
                        emptyState
                    } else {
                        summaryRow
                        ForEach(grouped, id: \.category) { group in
                            categorySection(group: group)
                        }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
            .scrollIndicators(.hidden)
            .sheet(isPresented: $showComparisonScanner) {
                ProductComparisonScannerView(itemName: comparisonItemName)
                    .environment(appVM)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
                    .presentationContentInteraction(.scrolls)
            }
            .navigationTitle("")
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
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 8) {
                        Image(systemName: "cart.fill")
                            .font(.subheadline.weight(.semibold))
                        Text(Lang.s("weekly_shopping_list"))
                            .font(.headline)
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "cart")
                .font(.system(size: 40))
                .foregroundStyle(.tertiary)
            Text(Lang.s("empty_shopping"))
                .font(.headline)
                .foregroundStyle(.secondary)
            Text(Lang.s("empty_shopping_desc"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 60)
        .frame(maxWidth: .infinity)
    }

    private var summaryRow: some View {
        HStack {
            Text("\(checkedCount) \(Lang.s("of_meals")) \(appVM.shoppingListItems.count) \(Lang.s("items_completed"))")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Button {
                appVM.clearShoppingList()
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "trash.fill")
                        .font(.caption.weight(.semibold))
                    Text(Lang.s("delete"))
                        .font(.subheadline.weight(.semibold))
                }
                .foregroundStyle(.red)
            }
            .buttonStyle(.plain)
        }
        .padding(.top, 4)
    }

    private func categorySection(group: (category: String, items: [ShoppingListItem])) -> some View {
        let isExpanded = expandedCategories.contains(group.category)
        let checkedInGroup = group.items.filter { $0.isChecked }.count

        return VStack(spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.3)) {
                    if isExpanded {
                        expandedCategories.remove(group.category)
                    } else {
                        expandedCategories.insert(group.category)
                    }
                }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                        .frame(width: 16)

                    Text(ShoppingListItem.categoryEmoji(group.category))
                        .font(.title3)

                    Text(group.category)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)

                    Spacer()

                    Text("\(checkedInGroup)/\(group.items.count)")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                .padding(14)
            }
            .buttonStyle(.plain)

            if isExpanded {
                Divider()
                    .padding(.horizontal, 14)

                VStack(spacing: 0) {
                    ForEach(group.items) { item in
                        shoppingItemRow(item: item)
                        if item.id != group.items.last?.id {
                            Divider()
                                .padding(.horizontal, 14)
                        }
                    }
                }
            }
        }
        .background(categoryBackground(group.category))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func shoppingItemRow(item: ShoppingListItem) -> some View {
        HStack(spacing: 12) {
            Button {
                appVM.toggleShoppingItem(id: item.id)
            } label: {
                Image(systemName: item.isChecked ? "checkmark.square.fill" : "square")
                    .font(.title3)
                    .foregroundStyle(item.isChecked ? Color.wellnessTeal : Color(.systemGray3))
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.name)
                    .font(.subheadline.weight(.medium))
                    .strikethrough(item.isChecked)
                    .foregroundStyle(item.isChecked ? .secondary : .primary)
                Text(item.amount)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button {
                comparisonItemName = item.name
                showComparisonScanner = true
            } label: {
                HStack(spacing: 5) {
                    Image(systemName: "barcode.viewfinder")
                        .font(.caption.weight(.semibold))
                    Text(Lang.s("scan_product"))
                        .font(.caption.weight(.semibold))
                }
                .foregroundStyle(.secondary)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
    }

    private func categoryBackground(_ category: String) -> Color {
        switch category {
        case "Meat and Fish": return Color(red: 1.0, green: 0.96, blue: 0.96)
        case "Fruits and Vegetables": return Color(red: 0.95, green: 0.99, blue: 0.96)
        case "Dairy and Eggs": return Color(red: 0.95, green: 0.97, blue: 1.0)
        case "Grains and Pasta": return Color(red: 1.0, green: 0.99, blue: 0.91)
        case "Legumes and Nuts": return Color(red: 1.0, green: 0.97, blue: 0.91)
        case "Oils and Fats": return Color(red: 0.98, green: 0.99, blue: 0.93)
        case "Beverages": return Color(red: 0.94, green: 0.97, blue: 1.0)
        case "Condiments and Spices": return Color(red: 1.0, green: 1.0, blue: 0.97)
        case "Other": return Color(red: 0.97, green: 0.97, blue: 0.97)
        default: return Color(red: 0.97, green: 0.97, blue: 0.97)
        }
    }
}
