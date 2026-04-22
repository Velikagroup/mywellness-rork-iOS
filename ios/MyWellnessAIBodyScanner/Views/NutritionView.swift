import SwiftUI

struct NutritionView: View {
    @Environment(AppViewModel.self) private var appVM
    @State private var selectedDay: String = Date().weekdayName
    @State private var selectedMeal: Meal?
    @State private var mealToReplace: Meal?
    @State private var showUploadPlan: Bool = false
    @State private var showPantry: Bool = false
    @State private var showShoppingList: Bool = false
    @State private var showAddToShoppingListConfirm: Bool = false
    @State private var showMealPlanQuiz: Bool = false
    @State private var showPlanAcceptedAnimation: Bool = false

    private let days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    private let shortDayKeys = ["mon", "tue", "wed", "thu", "fri", "sat", "sun"]

    private var hasPendingPlan: Bool {
        appVM.pendingScanPlan != nil && !appVM.pendingScanPlan!.days.isEmpty
    }

    private var hasActivePlan: Bool {
        !appVM.nutritionPlan.days.isEmpty
    }

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(spacing: 20) {
                    Color.clear.frame(height: 104)
                    header
                    if !appVM.hasCompletedBodyScan && !hasActivePlan {
                        bodyScanRequiredView
                    } else if hasPendingPlan && !hasActivePlan {
                        pendingPlanView
                    } else if hasActivePlan {
                        actionButtons
                        weeklyScheduleSection
                    } else if hasPendingPlan {
                        pendingPlanView
                    } else {
                        bodyScanRequiredView
                    }
                }
                .padding(.bottom, 100)
            }
            .ignoresSafeArea(edges: .top)
            .scrollIndicators(.hidden)

            WellnessNavBarOverlay()

            if showPlanAcceptedAnimation {
                planAcceptedOverlay
            }
        }
        .sheet(item: $selectedMeal) { meal in
            MealDetailView(meal: meal)
        }
        .sheet(item: $mealToReplace) { meal in
            ReplaceMealSheet(meal: meal) { _ in }
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)
        }
        .sheet(isPresented: $showUploadPlan) {
            UploadPlanSheet()
        }
        .sheet(isPresented: $showPantry) {
            PantrySheet()
        }
        .sheet(isPresented: $showShoppingList) {
            ShoppingListSheet()
        }
        .fullScreenCover(isPresented: $showMealPlanQuiz) {
            MealPlanQuizView()
        }
        .onChange(of: showMealPlanQuiz) { _, newValue in
            if !newValue {
                appVM.generationError = nil
                appVM.isGeneratingPlan = false
            }
        }
        .sheet(isPresented: $showAddToShoppingListConfirm) {
            AddToShoppingListSheet(selectedDay: selectedDay) { scope in
                switch scope {
                case .day:
                    if let plan = appVM.nutritionPlan.days.first(where: { $0.dayName == selectedDay }) {
                        appVM.addDayToShoppingList(dayPlan: plan)
                    }
                case .week:
                    appVM.addWeekToShoppingList()
                }
                showAddToShoppingListConfirm = false
            }
            .presentationDetents([.height(300)])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(28)
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(Lang.s("nutrition_protocol"))
                .font(.system(.largeTitle, weight: .bold))
            Text(Lang.s("nutrition_plan_subtitle"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
    }

    private var bodyScanRequiredView: some View {
        VStack(spacing: 24) {
            Image(systemName: "figure.stand.line.dotted.figure.stand")
                .font(.system(size: 56))
                .foregroundStyle(Color.wellnessTeal.opacity(0.6))

            VStack(spacing: 8) {
                Text(Lang.s("complete_body_scan_first"))
                    .font(.title3.bold())
                    .multilineTextAlignment(.center)
                Text(Lang.s("body_scan_required_desc"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Button {
                appVM.shouldOpenCameraHub = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "viewfinder.circle.fill")
                        .font(.body.weight(.semibold))
                    Text(Lang.s("go_to_body_scan"))
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color.wellnessTeal)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: Color.wellnessTeal.opacity(0.3), radius: 10, y: 4)
            }
            .buttonStyle(.plain)
        }
        .padding(28)
        .background(Color.white.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 16, y: 4)
        .padding(.horizontal, 16)
    }

    private var pendingPlanView: some View {
        VStack(spacing: 20) {
            pendingPlanBanner
            pendingPlanPreview
        }
    }

    private var pendingPlanBanner: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.wellnessTeal.opacity(0.15))
                        .frame(width: 48, height: 48)
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(Color.wellnessTeal)
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text(Lang.s("pending_plan_title"))
                        .font(.headline)
                    Text(Lang.s("pending_plan_desc"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    appVM.acceptPendingPlan()
                    showPlanAcceptedAnimation = true
                }
                HapticHelper.notification(.success)
                Task {
                    try? await Task.sleep(for: .seconds(1.5))
                    withAnimation { showPlanAcceptedAnimation = false }
                }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.body.weight(.semibold))
                    Text(Lang.s("accept_plan"))
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(
                    LinearGradient(
                        colors: [Color.wellnessTeal, Color(red: 0.2, green: 0.78, blue: 0.45)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: Color.wellnessTeal.opacity(0.3), radius: 10, y: 4)
            }
            .buttonStyle(.plain)
        }
        .padding(20)
        .background(Color.white.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 16, y: 4)
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    private var pendingPlanPreview: some View {
        if let plan = appVM.pendingScanPlan {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 16) {
                    Text(Lang.s("weekly_schedule"))
                        .font(.title2.bold())
                        .padding(.horizontal, 20)
                        .padding(.top, 20)

                    pendingDaySelector(plan: plan)
                }

                if let dayPlan = plan.days.first(where: { $0.dayName == selectedDay }) {
                    dayContent(dayPlan: dayPlan)
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "fork.knife")
                            .font(.largeTitle)
                            .foregroundStyle(.tertiary)
                        Text(Lang.s("no_plan_this_day"))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(height: 160)
                    .frame(maxWidth: .infinity)
                }
            }
            .background(Color.white.opacity(0.8))
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 16, y: 4)
            .padding(.horizontal, 16)
        }
    }

    private func pendingDaySelector(plan: NutritionPlan) -> some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 0) {
                    ForEach(0..<5, id: \.self) { i in
                        let hasPlan = plan.days.contains(where: { $0.dayName == days[i] })
                        pendingDayTabButton(day: days[i], short: Lang.s(shortDayKeys[i]), hasPlan: hasPlan)
                    }
                }
                HStack(spacing: 0) {
                    ForEach(5..<7, id: \.self) { i in
                        let hasPlan = plan.days.contains(where: { $0.dayName == days[i] })
                        pendingDayTabButton(day: days[i], short: Lang.s(shortDayKeys[i]), hasPlan: hasPlan)
                    }
                    Spacer()
                }
            }
            .padding(.horizontal, 12)

            Divider()
                .padding(.top, 4)
        }
    }

    private func pendingDayTabButton(day: String, short: String, hasPlan: Bool) -> some View {
        let isSelected = selectedDay == day
        return Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                selectedDay = day
            }
        } label: {
            VStack(spacing: 5) {
                HStack(spacing: 3) {
                    Text(short)
                        .font(.subheadline.weight(isSelected ? .bold : .regular))
                        .foregroundStyle(isSelected ? Color.wellnessTeal : Color.secondary)
                    if isSelected && hasPlan {
                        Image(systemName: "checkmark")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(Color.wellnessTeal)
                    }
                }
                Rectangle()
                    .fill(isSelected ? Color.wellnessTeal : Color.clear)
                    .frame(height: 2)
                    .clipShape(RoundedRectangle(cornerRadius: 1))
            }
            .frame(width: 54)
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }

    private var planAcceptedOverlay: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(Color(red: 0.2, green: 0.78, blue: 0.45))
            Text(Lang.s("plan_accepted"))
                .font(.title2.bold())
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black.opacity(0.5))
        .transition(.opacity)
        .allowsHitTesting(false)
    }

    private var actionButtons: some View {
        VStack(spacing: 10) {
            Button {
                showMealPlanQuiz = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.body.weight(.semibold))
                    Text(Lang.s("regenerate_plan"))
                        .font(.headline)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color.wellnessTeal)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: Color.wellnessTeal.opacity(0.3), radius: 10, y: 4)
            }
            .buttonStyle(.plain)

            Button {
                showUploadPlan = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Color(red: 0.48, green: 0.27, blue: 0.92))
                    Text(Lang.s("upload_your_plan"))
                        .font(.headline)
                        .foregroundStyle(Color(red: 0.48, green: 0.27, blue: 0.92))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.white.opacity(0.8))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color(red: 0.48, green: 0.27, blue: 0.92).opacity(0.25), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
            }
            .buttonStyle(.plain)

            HStack(spacing: 10) {
                Button {
                    showPantry = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "cabinet.fill")
                            .font(.subheadline)
                            .foregroundStyle(Color(red: 0.55, green: 0.27, blue: 0.88))
                        Text(Lang.s("pantry"))
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color(red: 0.55, green: 0.27, blue: 0.88))
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color(red: 0.55, green: 0.27, blue: 0.88).opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color(red: 0.55, green: 0.27, blue: 0.88).opacity(0.2), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)

                Button {
                    showShoppingList = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "cart.fill")
                            .font(.subheadline)
                            .foregroundStyle(Color.wellnessTeal)
                        Text(Lang.s("shopping_list"))
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.wellnessTeal)
                        if !appVM.shoppingListItems.isEmpty {
                            let unchecked = appVM.shoppingListItems.filter { !$0.isChecked }.count
                            if unchecked > 0 {
                                Text("\(unchecked)")
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.red)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.wellnessTeal.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.wellnessTeal.opacity(0.2), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
    }



    private var weeklyScheduleSection: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 16) {
                Text(Lang.s("weekly_schedule"))
                    .font(.title2.bold())
                    .padding(.horizontal, 20)
                    .padding(.top, 20)

                daySelector
            }

            if let dayPlan = appVM.nutritionPlan.days.first(where: { $0.dayName == selectedDay }) {
                dayContent(dayPlan: dayPlan)
            } else {
                VStack(spacing: 12) {
                    Image(systemName: "fork.knife")
                        .font(.largeTitle)
                        .foregroundStyle(.tertiary)
                    Text(Lang.s("no_plan_this_day"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(height: 160)
                .frame(maxWidth: .infinity)
            }
        }
        .background(Color.white.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 16, y: 4)
        .padding(.horizontal, 16)
    }

    private var daySelector: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 0) {
                    ForEach(0..<5, id: \.self) { i in
                        dayTabButton(day: days[i], short: Lang.s(shortDayKeys[i]))
                    }
                }
                HStack(spacing: 0) {
                    ForEach(5..<7, id: \.self) { i in
                        dayTabButton(day: days[i], short: Lang.s(shortDayKeys[i]))
                    }
                    Spacer()
                }
            }
            .padding(.horizontal, 12)

            Divider()
                .padding(.top, 4)
        }
    }

    private func dayTabButton(day: String, short: String) -> some View {
        let isSelected = selectedDay == day
        let hasPlan = appVM.nutritionPlan.days.contains(where: { $0.dayName == day })
        return Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                selectedDay = day
            }
        } label: {
            VStack(spacing: 5) {
                HStack(spacing: 3) {
                    Text(short)
                        .font(.subheadline.weight(isSelected ? .bold : .regular))
                        .foregroundStyle(isSelected ? Color.wellnessTeal : Color.secondary)
                    if isSelected && hasPlan {
                        Image(systemName: "checkmark")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundStyle(Color.wellnessTeal)
                    }
                }
                Rectangle()
                    .fill(isSelected ? Color.wellnessTeal : Color.clear)
                    .frame(height: 2)
                    .clipShape(RoundedRectangle(cornerRadius: 1))
            }
            .frame(width: 54)
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }

    private func dayContent(dayPlan: DayPlan) -> some View {
        VStack(spacing: 16) {
            HStack {
                Text("\(Lang.localizedDayName(selectedDay)) \(Lang.s("protocol_suffix"))")
                    .font(.headline)
                Spacer()
                Button {
                    showAddToShoppingListConfirm = true
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                            .font(.caption.weight(.bold))
                        Text(Lang.s("add_to_shopping_list"))
                            .font(.caption.weight(.semibold))
                    }
                    .foregroundStyle(Color.wellnessTeal)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .stroke(Color.wellnessTeal, lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)

            macroSummaryCard(dayPlan: dayPlan)
                .padding(.horizontal, 20)

            VStack(spacing: 10) {
                ForEach(dayPlan.meals) { meal in
                    NutritionMealRow(meal: meal) {
                        selectedMeal = meal
                    } onReplace: {
                        mealToReplace = meal
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
    }

    private func macroSummaryCard(dayPlan: DayPlan) -> some View {
        VStack(spacing: 12) {
            HStack(spacing: 0) {
                macroCell(title: Lang.s("total_calories"), value: "\(dayPlan.totalCalories)", unit: "kcal", color: Color.wellnessTeal)
                Divider().frame(height: 48)
                macroCell(title: Lang.s("protein"), value: String(format: "%.1f", dayPlan.totalProtein), unit: "g", color: .red)
            }
            Divider()
            HStack(spacing: 0) {
                macroCell(title: Lang.s("carbs"), value: String(format: "%.1f", dayPlan.totalCarbs), unit: "g", color: .blue)
                Divider().frame(height: 48)
                macroCell(title: Lang.s("fat"), value: String(format: "%.1f", dayPlan.totalFat), unit: "g", color: .orange)
            }
            Divider()
            HStack {
                Text("\(Lang.s("daily_target_colon"))\(Int(appVM.userProfile.dailyCalorieTarget)) kcal")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                let diff = dayPlan.totalCalories - Int(appVM.userProfile.dailyCalorieTarget)
                Text(diff == 0 ? Lang.s("on_target") : "\(diff > 0 ? "+" : "")\(diff) kcal")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(abs(diff) < 50 ? Color.wellnessTeal : abs(diff) < 150 ? .orange : .red)
            }
        }
        .padding(16)
        .background(Color.wellnessTeal.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }

    private func macroCell(title: String, value: String, unit: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack(alignment: .lastTextBaseline, spacing: 2) {
                Text(value)
                    .font(.system(.title2, weight: .bold))
                    .foregroundStyle(color)
                Text(unit)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct NutritionMealRow: View {
    let meal: Meal
    let onTap: () -> Void
    let onReplace: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                if !meal.isCheatMeal {
                    Button(action: onReplace) {
                        Image(systemName: "arrow.clockwise")
                            .font(.subheadline.weight(.medium))
                            .foregroundStyle(.secondary)
                            .frame(width: 36, height: 36)
                            .background(Color(.systemGray6))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }

                if meal.isCheatMeal {
                    ZStack {
                        LinearGradient(colors: [.orange.opacity(0.15), .pink.opacity(0.15)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        Text("🎉")
                            .font(.title)
                    }
                    .frame(width: 62, height: 62)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                } else {
                    Color.clear
                        .frame(width: 62, height: 62)
                        .overlay {
                            AsyncImage(url: URL(string: meal.imageURL ?? "")) { phase in
                                if let image = phase.image {
                                    image.resizable().aspectRatio(contentMode: .fill).allowsHitTesting(false)
                                } else {
                                    Image(systemName: "fork.knife")
                                        .font(.title3)
                                        .foregroundStyle(.tertiary)
                                }
                            }
                        }
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Text(meal.type.rawValue)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(Color.wellnessTeal)
                        if meal.isCheatMeal {
                            Text(Lang.s("cheat_meal"))
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(LinearGradient(colors: [.orange, .pink], startPoint: .leading, endPoint: .trailing))
                                .clipShape(Capsule())
                        }
                    }
                    if meal.isCheatMeal {
                        Text(Lang.s("free_meal_subtitle"))
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.secondary)
                    } else {
                        Text(meal.name)
                            .font(.subheadline.weight(.semibold))
                            .lineLimit(1)
                            .foregroundStyle(.primary)
                        HStack(spacing: 6) {
                            macroTag(value: Int(meal.protein), label: "P", color: .red)
                            Text("·").foregroundStyle(.tertiary).font(.caption2)
                            macroTag(value: Int(meal.carbs), label: "C", color: .blue)
                            Text("·").foregroundStyle(.tertiary).font(.caption2)
                            macroTag(value: Int(meal.fat), label: "G", color: .orange)
                        }
                    }
                }

                Spacer()

                if !meal.isCheatMeal {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(meal.calories)")
                            .font(.headline.weight(.bold))
                            .foregroundStyle(.primary)
                        Text("kcal")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(12)
            .background(meal.isCheatMeal ? LinearGradient(colors: [.orange.opacity(0.05), .pink.opacity(0.05)], startPoint: .leading, endPoint: .trailing).opacity(1) : LinearGradient(colors: [.white.opacity(0.8), .white.opacity(0.8)], startPoint: .leading, endPoint: .trailing).opacity(1))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(meal.isCheatMeal ? LinearGradient(colors: [.orange.opacity(0.3), .pink.opacity(0.3)], startPoint: .leading, endPoint: .trailing) : LinearGradient(colors: [.clear, .clear], startPoint: .leading, endPoint: .trailing), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.04), radius: 6, y: 2)
        }
        .buttonStyle(.plain)
    }

    private func macroTag(value: Int, label: String, color: Color) -> some View {
        Text("\(value)\(label)")
            .font(.caption2.weight(.semibold))
            .foregroundStyle(color)
    }
}

enum ShoppingListScope {
    case day, week
}

struct AddToShoppingListSheet: View {
    let selectedDay: String
    let onConfirm: (ShoppingListScope) -> Void

    var body: some View {
        VStack(spacing: 20) {
            VStack(spacing: 6) {
                Text(Lang.s("add_to_shopping_confirm"))
                    .font(.title3.bold())
                Text(Lang.s("add_day_or_week"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 8)

            VStack(spacing: 10) {
                Button {
                    onConfirm(.day)
                } label: {
                    HStack(spacing: 8) {
                        Text("📅")
                        Text("\(Lang.s("only_day")) \(selectedDay)")
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color.wellnessTeal)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .buttonStyle(.plain)

                Button {
                    onConfirm(.week)
                } label: {
                    HStack(spacing: 8) {
                        Text("📅")
                        Text(Lang.s("whole_week"))
                            .font(.headline)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color.wellnessTeal.opacity(0.1))
                    .foregroundStyle(Color.wellnessTeal)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .buttonStyle(.plain)
            }

            Button {
                onConfirm(.day)
            } label: {
                Text(Lang.s("cancel"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 16)
    }
}
