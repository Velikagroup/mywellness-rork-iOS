import SwiftUI

struct MealPlanQuizView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppViewModel.self) private var appVM
    @State private var quizVM = MealPlanQuizViewModel()

    var body: some View {
        ZStack(alignment: .top) {
            if #available(iOS 18.0, *) {
                AnimatedMeshBackground()
                    .ignoresSafeArea()
            } else {
                Color(red: 0.72, green: 0.86, blue: 0.95).ignoresSafeArea()
            }

            if quizVM.isGenerating || quizVM.isComplete {
                generationScreen
            } else {
                quizContent
            }

            quizTopBar
        }
        .onChange(of: quizVM.isComplete) { _, newValue in
            if newValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    dismiss()
                }
            }
        }
    }

    private var quizTopBar: some View {
        ZStack {
            HStack {
                Button {
                    if quizVM.currentStep == 0 {
                        dismiss()
                    } else {
                        quizVM.previousStep()
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.subheadline.weight(.semibold))
                        Text(quizVM.currentStep == 0 ? Lang.s("cancel") : Lang.s("back"))
                            .font(.subheadline)
                    }
                    .foregroundStyle(.primary)
                }

                Spacer()

                if !(quizVM.isGenerating || quizVM.isComplete) {
                    Text(quizVM.stepLabel)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 16)

            HStack {
                Spacer()
                WellnessLogo()
                Spacer()
            }
        }
        .padding(.bottom, 16)
        .frame(maxWidth: .infinity)
    }

    @ViewBuilder
    private var quizContent: some View {
        TabView(selection: $quizVM.currentStep) {
            dietTypeStep.tag(0)
            intolerancesStep.tag(1)
            fastingStep.tag(2)
            if quizVM.preferences.wantsFasting {
                eatingWindowStep.tag(3)
                mealsInWindowStep.tag(4)
            } else {
                regularMealsCountStep.tag(5)
            }
            cookingTimeStep.tag(6)
            cheatMealStep.tag(7)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: quizVM.currentStep)
        .ignoresSafeArea(edges: .top)
    }

    // MARK: - Step 1: Diet Type

    private var dietTypeStep: some View {
        ScrollView {
            VStack(spacing: 20) {
                Color.clear.frame(height: 80)
                quizCard {
                    VStack(spacing: 16) {
                        Text("🥗 \(Lang.s("diet_type"))")
                            .font(.title2.bold())
                        Text(Lang.s("which_nutritional_approach"))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(quizVM.dietOptions, id: \.name) { option in
                                dietOptionCard(option: option)
                            }
                        }
                    }
                    .padding(20)
                }

                continueButton {
                    quizVM.nextStep()
                }
                .disabled(!quizVM.canContinue)
                .opacity(quizVM.canContinue ? 1 : 0.5)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 100)
        }
        .scrollIndicators(.hidden)
    }

    private func dietOptionCard(option: (name: String, subtitle: String, emoji: String)) -> some View {
        let isSelected = quizVM.preferences.dietType == option.name
        return Button {
            withAnimation(.spring(response: 0.25)) {
                quizVM.preferences.dietType = option.name
            }
        } label: {
            VStack(spacing: 8) {
                Text(option.emoji)
                    .font(.system(size: 36))
                Text(option.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(option.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .padding(.horizontal, 8)
            .background(isSelected ? Color.wellnessTeal.opacity(0.1) : Color.white.opacity(0.8))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isSelected ? Color.wellnessTeal : Color(.systemGray4), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
        .conditionalSensoryFeedback(.selection, trigger: isSelected)
    }

    // MARK: - Step 2: Intolerances

    private var intolerancesStep: some View {
        ScrollView {
            VStack(spacing: 20) {
                Color.clear.frame(height: 80)
                quizCard {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.circle")
                            .font(.system(size: 40))
                            .foregroundStyle(.secondary)

                        Text(Lang.s("food_intolerances"))
                            .font(.title2.bold())
                        Text(Lang.s("select_intolerances"))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                            ForEach(quizVM.intoleranceOptions, id: \.self) { intolerance in
                                intoleranceChip(intolerance)
                            }
                        }

                        VStack(alignment: .leading, spacing: 8) {
                            TextField(Lang.s("other_foods_avoid"), text: Binding(
                                get: { quizVM.preferences.customIntolerances },
                                set: { quizVM.preferences.customIntolerances = $0 }
                            ))
                            .font(.subheadline)
                            .padding(14)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        }
                        .padding(.top, 4)
                    }
                    .padding(20)
                }

                continueButton {
                    quizVM.nextStep()
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 100)
        }
        .scrollIndicators(.hidden)
    }

    private func intoleranceChip(_ name: String) -> some View {
        let isSelected = quizVM.preferences.intolerances.contains(name)
        return Button {
            quizVM.toggleIntolerance(name)
        } label: {
            Text(name)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(isSelected ? Color.wellnessTeal.opacity(0.1) : Color.white.opacity(0.8))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(isSelected ? Color.wellnessTeal : Color(.systemGray4), lineWidth: isSelected ? 2 : 1)
                )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Step 3: Intermittent Fasting

    private var fastingStep: some View {
        ScrollView {
            VStack(spacing: 20) {
                Color.clear.frame(height: 80)
                quizCard {
                    VStack(spacing: 20) {
                        Text("⏱️ \(Lang.s("intermittent_fasting"))")
                            .font(.title2.bold())
                        Text(Lang.s("want_fasting_protocol"))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)

                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .top, spacing: 8) {
                                Text("💡")
                                Text(Lang.s("what_is_fasting"))
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(Color.wellnessTeal)
                            }
                            Text(Lang.s("fasting_description"))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(16)
                        .background(Color.wellnessTeal.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.wellnessTeal.opacity(0.15), lineWidth: 1)
                        )

                        VStack(spacing: 12) {
                            fastingOptionCard(
                                emoji: "🍽️",
                                title: Lang.s("no_regular_meals"),
                                isSelected: !quizVM.preferences.wantsFasting,
                                action: {
                                    quizVM.preferences.wantsFasting = false
                                }
                            )

                            fastingOptionCard(
                                emoji: "⏰",
                                title: Lang.s("yes_try_fasting"),
                                isSelected: quizVM.preferences.wantsFasting,
                                action: {
                                    quizVM.preferences.wantsFasting = true
                                }
                            )
                        }
                    }
                    .padding(20)
                }

                continueButton {
                    quizVM.nextStep()
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 100)
        }
        .scrollIndicators(.hidden)
    }

    private func fastingOptionCard(emoji: String, title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.25)) { action() }
        }) {
            VStack(spacing: 10) {
                Text(emoji)
                    .font(.system(size: 36))
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .background(isSelected ? Color.wellnessTeal.opacity(0.1) : Color.white.opacity(0.8))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(isSelected ? Color.wellnessTeal : Color(.systemGray4), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
        .conditionalSensoryFeedback(.selection, trigger: isSelected)
    }

    // MARK: - Step 4: Eating Window

    private var eatingWindowStep: some View {
        ScrollView {
            VStack(spacing: 20) {
                Color.clear.frame(height: 80)
                quizCard {
                    VStack(spacing: 20) {
                        Text("⏰ \(Lang.s("eating_window"))")
                            .font(.title2.bold())
                        Text(Lang.s("which_meal_skip"))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)

                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .top, spacing: 8) {
                                Text("💡")
                                Text(Lang.s("choose_lifestyle_eat"))
                                    .font(.subheadline)
                                    .foregroundStyle(Color.wellnessTeal)
                            }
                        }
                        .padding(14)
                        .background(Color.yellow.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color.yellow.opacity(0.2), lineWidth: 1)
                        )

                        VStack(spacing: 14) {
                            eatingWindowOption(
                                emoji: "🌅",
                                title: Lang.s("skip_breakfast"),
                                window: "\(Lang.s("window_label")) 12:00 - 20:00",
                                description: "12:00 - 20:00",
                                isSelected: quizVM.preferences.fastingWindow == .skipBreakfast,
                                action: { quizVM.preferences.fastingWindow = .skipBreakfast }
                            )

                            eatingWindowOption(
                                emoji: "🌙",
                                title: Lang.s("skip_dinner"),
                                window: "\(Lang.s("window_label")) 08:00 - 16:00",
                                description: "08:00 - 16:00",
                                isSelected: quizVM.preferences.fastingWindow == .skipDinner,
                                action: { quizVM.preferences.fastingWindow = .skipDinner }
                            )
                        }
                    }
                    .padding(20)
                }

                continueButton {
                    quizVM.nextStep()
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 100)
        }
        .scrollIndicators(.hidden)
    }

    private func eatingWindowOption(emoji: String, title: String, window: String, description: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.25)) { action() }
        }) {
            VStack(spacing: 10) {
                Text(emoji)
                    .font(.system(size: 40))
                Text(title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(window)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.wellnessTeal)
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(isSelected ? Color.wellnessTeal.opacity(0.08) : Color.white.opacity(0.8))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(isSelected ? Color.wellnessTeal : Color(.systemGray4), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Step 5: Meals in Window (Fasting)

    private var mealsInWindowStep: some View {
        let dailyTarget = appVM.userProfile.dailyCalorieTarget
        let windowLabel = quizVM.preferences.fastingWindow.windowLabel

        return ScrollView {
            VStack(spacing: 20) {
                Color.clear.frame(height: 80)
                quizCard {
                    VStack(spacing: 20) {
                        Text("🍽️ \(Lang.s("meals_in_window"))")
                            .font(.title2.bold())
                        Text("\(Lang.s("how_many_meals_window")) (\(windowLabel))?")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)

                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .top, spacing: 8) {
                                Text("💡")
                                Text(Lang.s("fasting_window_tip"))
                                    .font(.subheadline)
                                    .foregroundStyle(Color.wellnessTeal)
                            }
                        }
                        .padding(14)
                        .background(Color.yellow.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color.yellow.opacity(0.2), lineWidth: 1)
                        )

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(1...4, id: \.self) { count in
                                mealCountCard(count: count, dailyTarget: dailyTarget)
                            }
                        }

                        VStack(spacing: 6) {
                            HStack(spacing: 6) {
                                Text("📊")
                                Text("\(quizVM.preferences.mealsCount) \(Lang.s("meals_count_label"))")
                                    .font(.subheadline.weight(.bold))
                                Text("\(Lang.s("in_window_label")) \(windowLabel)")
                                    .font(.subheadline)
                            }
                            Text("~\(quizVM.kcalPerMeal(dailyTarget: dailyTarget)) \(Lang.s("kcal_per_meal"))")
                                .font(.title3.weight(.bold))
                                .foregroundStyle(Color.wellnessTeal)
                            Text(String(format: Lang.s("daily_target_kcal"), Int(dailyTarget)))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity)
                        .background(Color.wellnessTeal.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.wellnessTeal.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .padding(20)
                }

                continueButton {
                    quizVM.nextStep()
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 100)
        }
        .scrollIndicators(.hidden)
    }

    private func mealCountCard(count: Int, dailyTarget: Double) -> some View {
        let isSelected = quizVM.preferences.mealsCount == count
        let kcalPerMeal = Int(dailyTarget / Double(count))
        return Button {
            withAnimation(.spring(response: 0.25)) {
                quizVM.preferences.mealsCount = count
            }
        } label: {
            VStack(spacing: 6) {
                Text("\(count)")
                    .font(.system(.title, weight: .bold))
                    .foregroundStyle(.primary)
                Text(count == 1 ? Lang.s("meal") : Lang.s("meals"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("~\(kcalPerMeal) kcal")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.wellnessTeal)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(isSelected ? Color.wellnessTeal.opacity(0.12) : Color.white.opacity(0.8))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isSelected ? Color.wellnessTeal : Color(.systemGray4), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Step 5b: Regular Meals Count (No Fasting)

    private var regularMealsCountStep: some View {
        let dailyTarget = appVM.userProfile.dailyCalorieTarget

        return ScrollView {
            VStack(spacing: 20) {
                Color.clear.frame(height: 80)
                quizCard {
                    VStack(spacing: 20) {
                        Text("🍽️ \(Lang.s("daily_meals"))")
                            .font(.title2.bold())
                        Text(Lang.s("how_many_meals_day"))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)

                        VStack(alignment: .leading, spacing: 8) {
                            HStack(alignment: .top, spacing: 8) {
                                Text("💡")
                                Text(Lang.s("choose_routine_preferences"))
                                    .font(.subheadline)
                                    .foregroundStyle(Color.wellnessTeal)
                            }
                        }
                        .padding(14)
                        .background(Color.yellow.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color.yellow.opacity(0.2), lineWidth: 1)
                        )

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(1...7, id: \.self) { count in
                                regularMealCountCard(count: count, dailyTarget: dailyTarget)
                            }
                        }

                        VStack(spacing: 6) {
                            HStack(spacing: 6) {
                                Text("📊")
                                Text("\(quizVM.preferences.mealsCount) \(Lang.s("meals_count_label"))")
                                    .font(.subheadline.weight(.bold))
                                Text(Lang.s("per_day"))
                                    .font(.subheadline)
                            }
                            Text("~\(quizVM.kcalPerMeal(dailyTarget: dailyTarget)) \(Lang.s("kcal_per_meal"))")
                                .font(.title3.weight(.bold))
                                .foregroundStyle(Color.wellnessTeal)
                            Text(String(format: Lang.s("daily_target_kcal"), Int(dailyTarget)))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(16)
                        .frame(maxWidth: .infinity)
                        .background(Color.wellnessTeal.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(Color.wellnessTeal.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .padding(20)
                }

                continueButton {
                    quizVM.nextStep()
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 100)
        }
        .scrollIndicators(.hidden)
    }

    private func regularMealCountCard(count: Int, dailyTarget: Double) -> some View {
        let isSelected = quizVM.preferences.mealsCount == count
        let kcalPerMeal = Int(dailyTarget / Double(count))
        let _: String = {
            switch count {
            case 1: return "1 comida"
            case 2: return "2 comidas"
            case 3: return "3 comidas"
            case 4: return "4 comidas"
            case 5: return "5 comidas"
            case 6: return "6 comidas"
            case 7: return "7 comidas"
            default: return "\(count) comidas"
            }
        }()
        return Button {
            withAnimation(.spring(response: 0.25)) {
                quizVM.preferences.mealsCount = count
            }
        } label: {
            VStack(spacing: 6) {
                Text("\(count)")
                    .font(.system(.title, weight: .bold))
                    .foregroundStyle(.primary)
                Text(count == 1 ? Lang.s("meal") : Lang.s("meals"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text("~\(kcalPerMeal) kcal")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.wellnessTeal)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(isSelected ? Color.wellnessTeal.opacity(0.12) : Color.white.opacity(0.8))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isSelected ? Color.wellnessTeal : Color(.systemGray4), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Step 6: Cooking Time

    private var cookingTimeStep: some View {
        ScrollView {
            VStack(spacing: 20) {
                Color.clear.frame(height: 80)
                quizCard {
                    VStack(spacing: 20) {
                        Text("⏲️ \(Lang.s("cooking_time"))")
                            .font(.title2.bold())
                        Text(Lang.s("how_much_time_cooking"))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)

                        VStack(spacing: 12) {
                            ForEach(MealPlanQuizPreferences.CookingTime.allCases, id: \.rawValue) { time in
                                cookingTimeCard(time: time)
                            }
                        }
                    }
                    .padding(20)
                }

                continueButton {
                    quizVM.nextStep()
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 100)
        }
        .scrollIndicators(.hidden)
    }

    private func cookingTimeCard(time: MealPlanQuizPreferences.CookingTime) -> some View {
        let isSelected = quizVM.preferences.cookingTime == time
        return Button {
            withAnimation(.spring(response: 0.25)) {
                quizVM.preferences.cookingTime = time
            }
        } label: {
            VStack(spacing: 10) {
                Text(time.emoji)
                    .font(.system(size: 36))
                Text(time.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(time.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(Color.wellnessTeal)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 22)
            .background(isSelected ? Color.wellnessTeal.opacity(0.1) : Color.white.opacity(0.8))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(isSelected ? Color.wellnessTeal : Color(.systemGray4), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
        .conditionalSensoryFeedback(.selection, trigger: isSelected)
    }

    // MARK: - Step 7: Cheat Meal

    private var cheatMealStep: some View {
        ScrollView {
            VStack(spacing: 24) {
                Color.clear.frame(height: 80)
                VStack(spacing: 8) {
                    Text("🍕")
                        .font(.system(size: 44))
                    Text(Lang.s("cheat_meal"))
                        .font(.title2.bold())
                    Text(Lang.s("cheat_meal_desc"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(2)
                }
                .padding(.top, 4)

                VStack(spacing: 0) {
                    HStack {
                        Label(Lang.s("choose_when"), systemImage: "calendar")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                        Spacer()
                        Text(quizVM.preferences.cheatMeal != nil ? "1/1" : "0/1")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(quizVM.preferences.cheatMeal != nil ? Color.wellnessTeal : Color(.systemGray3))
                            .clipShape(Capsule())
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)

                    Divider()
                        .padding(.horizontal, 16)

                    VStack(spacing: 0) {
                        ForEach(Array(quizVM.weekDays.enumerated()), id: \.element) { index, day in
                            cheatMealRow(day: day)
                            if index < quizVM.weekDays.count - 1 {
                                Divider()
                                    .padding(.leading, 60)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                .background(Color.white.opacity(0.85))
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .shadow(color: .black.opacity(0.06), radius: 12, y: 4)

                HStack(spacing: 12) {
                    Button {
                        quizVM.preferences.cheatMeal = nil
                        quizVM.startGeneration(appVM: appVM)
                    } label: {
                        Text(Lang.s("skip"))
                            .font(.headline)
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity)
                            .frame(height: 54)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)

                    Button {
                        quizVM.startGeneration(appVM: appVM)
                    } label: {
                        HStack(spacing: 8) {
                            Text(Lang.s("continue"))
                                .font(.headline)
                            if quizVM.preferences.cheatMeal != nil {
                                Image(systemName: "arrow.right")
                                    .font(.subheadline.weight(.semibold))
                            }
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 54)
                        .background(Color.wellnessTeal)
                        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        .shadow(color: Color.wellnessTeal.opacity(0.3), radius: 8, y: 3)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 100)
        }
        .scrollIndicators(.hidden)
    }

    private func cheatMealRow(day: String) -> some View {
        let isRowSelected = quizVM.preferences.cheatMeal?.day == day
        return HStack(spacing: 12) {
            Text(day)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(isRowSelected ? Color.wellnessTeal : .primary)
                .frame(width: 44, alignment: .leading)

            Spacer()

            HStack(spacing: 8) {
                cheatMealButton(day: day, mealType: Lang.s("lunch"), emoji: "🍝")
                cheatMealButton(day: day, mealType: Lang.s("dinner"), emoji: "🍖")
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    private func cheatMealButton(day: String, mealType: String, emoji: String) -> some View {
        let isSelected = quizVM.preferences.cheatMeal?.day == day && quizVM.preferences.cheatMeal?.mealType == mealType
        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                quizVM.toggleCheatMeal(day: day, mealType: mealType)
            }
        } label: {
            HStack(spacing: 6) {
                Text(emoji)
                    .font(.callout)
                Text(mealType)
                    .font(.subheadline.weight(.medium))
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .foregroundStyle(isSelected ? .white : .secondary)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background {
                if isSelected {
                    LinearGradient(colors: [.orange, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
                } else {
                    LinearGradient(colors: [Color(.systemGray6), Color(.systemGray5).opacity(0.5)], startPoint: .top, endPoint: .bottom)
                }
            }
            .clipShape(Capsule())
            .shadow(color: isSelected ? .orange.opacity(0.3) : .clear, radius: 6, y: 2)
        }
        .buttonStyle(.plain)
        .conditionalSensoryFeedback(.selection, trigger: isSelected)
    }

    // MARK: - Generation Screen

    private var generationScreen: some View {
        ScrollView {
            VStack(spacing: 24) {
                Color.clear.frame(height: 80)
                Image(systemName: "waveform.path.ecg")
                    .font(.system(size: 48))
                    .foregroundStyle(.white)
                    .frame(width: 80, height: 80)
                    .background(Color.wellnessTeal)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

                VStack(spacing: 8) {
                    Text(Lang.s("creating_ai_nutrition"))
                        .font(.title2.bold())
                    Text(Lang.s("ai_processing_desc"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }



                ProgressView(value: quizVM.generationProgress)
                    .tint(Color.wellnessTeal)
                    .scaleEffect(y: 2)
                    .padding(.horizontal, 20)

                if let error = quizVM.generationError {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text(Lang.s("analysis_in_progress"))
                        .font(.subheadline.weight(.bold))

                    ForEach(0..<quizVM.generationSteps.count, id: \.self) { index in
                        HStack(spacing: 10) {
                            if index < quizVM.currentGenerationStep {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(Color.wellnessTeal)
                            } else if index == quizVM.currentGenerationStep {
                                ProgressView()
                                    .scaleEffect(0.7)
                            } else {
                                Image(systemName: "checkmark.circle")
                                    .foregroundStyle(.tertiary)
                            }

                            Text(quizVM.generationStepText(
                                index: index,
                                bmr: appVM.effectiveBMR,
                                calories: appVM.userProfile.dailyCalorieTarget
                            ))
                            .font(.subheadline)
                            .foregroundStyle(index <= quizVM.currentGenerationStep ? .primary : .secondary)
                        }
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.8))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                Text(Lang.s("ai_disclaimer"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(16)
                    .background(Color.yellow.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 100)
        }
        .scrollIndicators(.hidden)
    }

    // MARK: - Shared Components

    private func quizCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .background(Color.white.opacity(0.85))
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 16, y: 4)
    }

    private func continueButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(Lang.s("continue"))
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color.wellnessTeal)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: Color.wellnessTeal.opacity(0.3), radius: 8, y: 3)
        }
        .buttonStyle(.plain)
    }

    private var progressDots: some View {
        HStack(spacing: 6) {
            let total = quizVM.totalSteps
            let current = quizVM.currentStep
            ForEach(0..<total, id: \.self) { i in
                if i == current {
                    Capsule()
                        .fill(Color.wellnessTeal)
                        .frame(width: 24, height: 6)
                } else {
                    Circle()
                        .fill(i < current ? Color.wellnessTeal : Color(.systemGray4))
                        .frame(width: 6, height: 6)
                }
            }
        }
    }
}
