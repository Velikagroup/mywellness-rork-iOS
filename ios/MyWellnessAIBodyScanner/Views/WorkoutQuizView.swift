import SwiftUI

struct WorkoutQuizView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppViewModel.self) private var appVM
    @State private var quizVM = WorkoutQuizViewModel()

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
        Group {
            switch quizVM.currentStep {
            case 0: fitnessGoalStep
            case 1: goalTypeStep
            case 2: workoutStyleStep
            case 3: sportQuestionsStep
            case 4: trainingFrequencyStep
            case 5: strengthLevelStep
            case 6: daysPerWeekStep
            case 7: sessionDurationStep
            case 8: trainingLocationStep
            case 9: equipmentStep
            case 10: jointPainStep
            default: fitnessGoalStep
            }
        }
        .transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        ))
        .animation(.spring(response: 0.35, dampingFraction: 0.85), value: quizVM.currentStep)

    }

    // MARK: - Step 1: Fitness Goal

    private var fitnessGoalStep: some View {
        ScrollView {
            VStack(spacing: 20) {
                Color.clear.frame(height: 70)
                quizCard {
                    VStack(spacing: 16) {
                        Image(systemName: "target")
                            .font(.system(size: 40))
                            .foregroundStyle(.white)
                            .frame(width: 72, height: 72)
                            .background(Color.wellnessTeal)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                        Text(Lang.s("main_fitness_goal"))
                            .font(.title2.bold())
                            .multilineTextAlignment(.center)
                        Text(Lang.s("choose_achieve"))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(WorkoutQuizStaticData.fitnessGoals, id: \.id) { goal in
                                fitnessGoalCard(id: goal.id, name: goal.name, icon: goal.icon)
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

    private func fitnessGoalCard(id: String, name: String, icon: String) -> some View {
        let isSelected = quizVM.preferences.fitnessGoal == id
        return Button {
            withAnimation(.spring(response: 0.25)) {
                quizVM.preferences.fitnessGoal = id
            }
        } label: {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 52, height: 52)
                    .background(isSelected ? Color.wellnessTeal : Color(.systemGray3))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                Text(name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
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

    // MARK: - Step 2: Goal Type

    private var goalTypeStep: some View {
        ScrollView {
            VStack(spacing: 20) {
                Color.clear.frame(height: 70)
                quizCard {
                    VStack(spacing: 20) {
                        Text("🎯 \(Lang.s("goal_type"))")
                            .font(.title2.bold())
                        Text(Lang.s("is_performance"))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        VStack(spacing: 14) {
                            goalTypeCard(
                                icon: "chart.line.uptrend.xyaxis",
                                title: Lang.s("yes_performance"),
                                description: Lang.s("yes_performance_desc"),
                                isSelected: quizVM.preferences.isPerformance == true,
                                action: { quizVM.preferences.isPerformance = true }
                            )

                            goalTypeCard(
                                icon: "scope",
                                title: Lang.s("no_general_wellness"),
                                description: Lang.s("no_general_desc"),
                                isSelected: quizVM.preferences.isPerformance == false,
                                action: { quizVM.preferences.isPerformance = false }
                            )
                        }

                        HStack(alignment: .top, spacing: 8) {
                            Text("💡")
                            Text(Lang.s("choice_determines_training"))
                                .font(.subheadline)
                                .foregroundStyle(Color.wellnessTeal)
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.wellnessTeal.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.wellnessTeal.opacity(0.15), lineWidth: 1)
                        )
                    }
                    .padding(20)
                }

                continueButton {
                    quizVM.nextStep()
                }
                .disabled(quizVM.preferences.isPerformance == nil)
                .opacity(quizVM.preferences.isPerformance != nil ? 1 : 0.5)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 100)
        }
        .scrollIndicators(.hidden)
    }

    private func goalTypeCard(icon: String, title: String, description: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.25)) { action() }
        }) {
            HStack(alignment: .top, spacing: 14) {
                Image(systemName: icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 48, height: 48)
                    .background(isSelected ? Color.wellnessTeal : Color(.systemGray3))
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isSelected ? Color.wellnessTeal.opacity(0.08) : Color.white.opacity(0.8))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(isSelected ? Color.wellnessTeal : Color(.systemGray4), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
        .conditionalSensoryFeedback(.selection, trigger: isSelected)
    }

    // MARK: - Step 3: Workout Style

    private var workoutStyleStep: some View {
        ScrollView {
            VStack(spacing: 20) {
                Color.clear.frame(height: 70)
                quizCard {
                    VStack(spacing: 16) {
                        Text("💪 \(Lang.s("workout_style"))")
                            .font(.title2.bold())
                        Text(Lang.s("choose_preferred_style"))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        VStack(spacing: 10) {
                            ForEach(WorkoutQuizStaticData.categories) { category in
                                categorySection(category)
                            }
                        }

                        HStack(alignment: .top, spacing: 8) {
                            Text("💡")
                            Text(Lang.s("ai_adapt_style"))
                                .font(.subheadline)
                                .foregroundStyle(Color.wellnessTeal)
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.wellnessTeal.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color.wellnessTeal.opacity(0.15), lineWidth: 1)
                        )
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

    private func categorySection(_ category: WorkoutStyleCategory) -> some View {
        let isExpanded = quizVM.expandedCategoryId == category.id
        return VStack(spacing: 0) {
            Button {
                quizVM.toggleCategory(category.id)
            } label: {
                HStack {
                    Text("\(category.emoji) \(category.name)")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(spacing: 0) {
                    ForEach(category.sports, id: \.self) { sport in
                        sportRow(sport, displayName: Lang.localizedSport(sport))
                        if sport != category.sports.last {
                            Divider()
                                .padding(.leading, 16)
                        }
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color.white.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(
                    category.sports.contains(quizVM.preferences.selectedSport) ? Color.wellnessTeal : Color(.systemGray4),
                    lineWidth: category.sports.contains(quizVM.preferences.selectedSport) ? 2 : 1
                )
        )
    }

    private func sportRow(_ sport: String, displayName: String) -> some View {
        let isSelected = quizVM.preferences.selectedSport == sport
        return Button {
            quizVM.selectSport(sport)
        } label: {
            HStack {
                Text(displayName)
                    .font(.subheadline)
                    .foregroundStyle(isSelected ? Color.wellnessTeal : .primary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.wellnessTeal)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(isSelected ? Color.wellnessTeal.opacity(0.06) : Color.clear)
        }
        .buttonStyle(.plain)
        .conditionalSensoryFeedback(.selection, trigger: isSelected)
    }

    // MARK: - Step 4: Sport-Specific Questions

    private var sportQuestionsStep: some View {
        ScrollView {
            VStack(spacing: 20) {
                Color.clear.frame(height: 70)
                quizCard {
                    VStack(spacing: 16) {
                        Text(Lang.localizedSport(quizVM.preferences.selectedSport))
                            .font(.title2.bold())
                        Text(Lang.s("specific_data"))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        VStack(alignment: .leading, spacing: 16) {
                            if quizVM.preferences.selectedSport == "BodyPump" {
                                Text(Lang.s("sq_weights_by_track"))
                                    .font(.subheadline.weight(.semibold))
                            }

                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                ForEach(quizVM.sportQuestions) { question in
                                    sportQuestionField(question)
                                }
                            }
                        }
                        .padding(16)
                        .background(Color.white.opacity(0.6))
                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .stroke(Color(.systemGray4), lineWidth: 1)
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

    private func sportQuestionField(_ question: SportQuestion) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(question.label)
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)

            HStack(spacing: 4) {
                TextField(question.placeholder, text: Binding(
                    get: { quizVM.sportAnswer(for: question.id) },
                    set: { quizVM.setSportAnswer($0, for: question.id) }
                ))
                .font(.subheadline)
                .keyboardType(.decimalPad)
                .padding(12)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                if !question.unit.isEmpty {
                    Text(question.unit)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(width: 36, alignment: .leading)
                }
            }
        }
    }

    // MARK: - Step 5: Training Frequency

    private var trainingFrequencyStep: some View {
        ScrollView {
            VStack(spacing: 20) {
                Color.clear.frame(height: 70)
                quizCard {
                    VStack(spacing: 16) {
                        Text("💪")
                            .font(.system(size: 40))
                            .frame(width: 72, height: 72)
                            .background(Color.wellnessTeal)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                        Text(Lang.s("how_often_train"))
                            .font(.title2.bold())
                            .multilineTextAlignment(.center)
                        Text(Lang.s("right_intensity"))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)

                        VStack(spacing: 12) {
                            ForEach(WorkoutQuizStaticData.trainingFrequencies, id: \.id) { freq in
                                singleSelectRow(
                                    title: freq.title,
                                    subtitle: freq.subtitle,
                                    isSelected: quizVM.preferences.trainingFrequency == freq.id
                                ) {
                                    quizVM.preferences.trainingFrequency = freq.id
                                }
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

    // MARK: - Step 6: Strength Level

    private var strengthLevelStep: some View {
        ScrollView {
            VStack(spacing: 20) {
                Color.clear.frame(height: 70)
                quizCard {
                    VStack(spacing: 16) {
                        Image(systemName: "scalemass.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(.white)
                            .frame(width: 72, height: 72)
                            .background(Color.wellnessTeal)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                        Text(Lang.s("strength_level"))
                            .font(.title2.bold())
                            .multilineTextAlignment(.center)
                        Text(Lang.s("suggest_right_weights"))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)

                        VStack(spacing: 12) {
                            ForEach(WorkoutQuizStaticData.strengthLevels, id: \.id) { level in
                                strengthLevelRow(level)
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

    private func strengthLevelRow(_ level: WorkoutQuizStaticData.StrengthLevelOption) -> some View {
        let isSelected = quizVM.preferences.strengthLevel == level.id
        return Button {
            withAnimation(.spring(response: 0.25)) {
                quizVM.preferences.strengthLevel = level.id
            }
        } label: {
            HStack(spacing: 14) {
                Image(systemName: level.icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(isSelected ? Color.wellnessTeal : .secondary)
                    .frame(width: 40, height: 40)
                    .background(isSelected ? Color.wellnessTeal.opacity(0.15) : Color(.systemGray5))
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                VStack(alignment: .leading, spacing: 2) {
                    Text(level.title)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text(level.subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer()
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isSelected ? Color.wellnessTeal.opacity(0.08) : Color.white.opacity(0.8))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isSelected ? Color.wellnessTeal : Color(.systemGray4), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
        .conditionalSensoryFeedback(.selection, trigger: isSelected)
    }

    // MARK: - Step 7: Days Per Week + Preferred Days

    private var daysPerWeekStep: some View {
        ScrollView {
            VStack(spacing: 20) {
                Color.clear.frame(height: 70)
                quizCard {
                    VStack(spacing: 16) {
                        Text("📅")
                            .font(.system(size: 40))
                            .frame(width: 72, height: 72)
                            .background(Color.wellnessTeal)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                        Text(Lang.s("days_per_week"))
                            .font(.title2.bold())
                            .multilineTextAlignment(.center)
                        Text(Lang.s("realistic_sustainable"))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(1...7, id: \.self) { day in
                                dayCountCard(day)
                            }
                        }

                        if quizVM.preferences.daysPerWeek > 0 {
                            Divider()

                            Text(Lang.s("which_days_prefer"))
                                .font(.headline)
                            Text(String(format: Lang.s("select_x_specific_days"), quizVM.preferences.daysPerWeek))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                                ForEach(WorkoutQuizStaticData.weekDayOptions, id: \.id) { option in
                                    dayOfWeekCard(id: option.id, label: option.label)
                                }
                            }

                            let remaining = quizVM.preferences.daysPerWeek - quizVM.preferences.preferredDays.count
                            if remaining > 0 {
                                HStack(spacing: 6) {
                                    Image(systemName: "exclamationmark.circle")
                                    Text(String(format: Lang.s("select_x_more_days"), remaining))
                                }
                                .font(.subheadline)
                                .foregroundStyle(.orange)
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

    private func dayCountCard(_ day: Int) -> some View {
        let isSelected = quizVM.preferences.daysPerWeek == day
        return Button {
            withAnimation(.spring(response: 0.25)) {
                quizVM.preferences.daysPerWeek = day
                quizVM.preferences.preferredDays = []
            }
        } label: {
            VStack(spacing: 4) {
                Text("\(day)")
                    .font(.title.bold())
                    .foregroundStyle(isSelected ? Color.wellnessTeal : .primary)
                Text(day == 1 ? Lang.s("day") : Lang.s("days"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isSelected ? Color.wellnessTeal.opacity(0.08) : Color.white.opacity(0.8))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(isSelected ? Color.wellnessTeal : Color(.systemGray4), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
        .conditionalSensoryFeedback(.selection, trigger: isSelected)
    }

    private func dayOfWeekCard(id: String, label: String) -> some View {
        let isSelected = quizVM.preferences.preferredDays.contains(id)
        let canSelect = isSelected || quizVM.preferences.preferredDays.count < quizVM.preferences.daysPerWeek
        return Button {
            withAnimation(.spring(response: 0.25)) {
                quizVM.togglePreferredDay(id)
            }
        } label: {
            Text(label)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(isSelected ? Color.wellnessTeal : (canSelect ? .primary : .secondary))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(isSelected ? Color.wellnessTeal.opacity(0.08) : Color.white.opacity(0.8))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(isSelected ? Color.wellnessTeal : Color(.systemGray4), lineWidth: isSelected ? 2 : 1)
                )
        }
        .buttonStyle(.plain)
        .disabled(!canSelect)
        .conditionalSensoryFeedback(.selection, trigger: isSelected)
    }

    // MARK: - Step 8: Session Duration

    private var sessionDurationStep: some View {
        ScrollView {
            VStack(spacing: 20) {
                Color.clear.frame(height: 70)
                quizCard {
                    VStack(spacing: 16) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(.white)
                            .frame(width: 72, height: 72)
                            .background(Color.wellnessTeal)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                        Text(Lang.s("session_duration"))
                            .font(.title2.bold())
                            .multilineTextAlignment(.center)
                        Text(Lang.s("preferred_duration"))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            ForEach(WorkoutQuizStaticData.sessionDurations, id: \.id) { dur in
                                durationCard(dur)
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

    private func durationCard(_ dur: WorkoutQuizStaticData.SessionDurationOption) -> some View {
        let isSelected = quizVM.preferences.sessionDuration == dur.id
        return Button {
            withAnimation(.spring(response: 0.25)) {
                quizVM.preferences.sessionDuration = dur.id
            }
        } label: {
            VStack(spacing: 8) {
                Text(dur.title)
                    .font(.title3.bold())
                    .foregroundStyle(isSelected ? Color.wellnessTeal : .primary)
                Text(dur.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 24)
            .background(isSelected ? Color.wellnessTeal.opacity(0.08) : Color.white.opacity(0.8))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isSelected ? Color.wellnessTeal : Color(.systemGray4), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
        .conditionalSensoryFeedback(.selection, trigger: isSelected)
    }

    // MARK: - Step 9: Training Location

    private var trainingLocationStep: some View {
        ScrollView {
            VStack(spacing: 20) {
                Color.clear.frame(height: 70)
                quizCard {
                    VStack(spacing: 16) {
                        Text("📍")
                            .font(.system(size: 40))
                            .frame(width: 72, height: 72)
                            .background(Color.wellnessTeal)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                        Text(Lang.s("where_train"))
                            .font(.title2.bold())
                            .multilineTextAlignment(.center)
                        Text(Lang.s("preferred_environment"))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)

                        VStack(spacing: 12) {
                            ForEach(WorkoutQuizStaticData.trainingLocations, id: \.id) { loc in
                                locationCard(loc)
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

    private func locationCard(_ loc: WorkoutQuizStaticData.TrainingLocationOption) -> some View {
        let isSelected = quizVM.preferences.trainingLocation == loc.id
        return Button {
            withAnimation(.spring(response: 0.25)) {
                quizVM.preferences.trainingLocation = loc.id
            }
        } label: {
            VStack(spacing: 8) {
                Text(loc.emoji)
                    .font(.system(size: 36))
                Text(loc.title)
                    .font(.headline)
                    .foregroundStyle(.primary)
                Text(loc.subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(isSelected ? Color.wellnessTeal.opacity(0.08) : Color.white.opacity(0.8))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isSelected ? Color.wellnessTeal : Color(.systemGray4), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
        .conditionalSensoryFeedback(.selection, trigger: isSelected)
    }

    // MARK: - Step 10: Equipment

    private var equipmentStep: some View {
        ScrollView {
            VStack(spacing: 20) {
                Color.clear.frame(height: 70)
                quizCard {
                    VStack(spacing: 16) {
                        Text(Lang.s("equipment_access"))
                            .font(.title2.bold())
                            .multilineTextAlignment(.center)
                        Text(Lang.s("select_category_customize"))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)

                        VStack(spacing: 12) {
                            ForEach(WorkoutQuizStaticData.equipmentCategories, id: \.id) { eq in
                                equipmentRow(eq)
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

    private func equipmentRow(_ eq: WorkoutQuizStaticData.EquipmentOption) -> some View {
        let isSelected = quizVM.preferences.equipmentCategory == eq.id
        return Button {
            withAnimation(.spring(response: 0.25)) {
                quizVM.preferences.equipmentCategory = eq.id
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? Color.wellnessTeal : Color(.systemGray3))
                    .font(.title3)

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(eq.emoji)
                        Text(eq.title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                    }
                    Text(eq.subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isSelected ? Color.wellnessTeal.opacity(0.08) : Color.white.opacity(0.8))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isSelected ? Color.wellnessTeal : Color(.systemGray4), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
        .conditionalSensoryFeedback(.selection, trigger: isSelected)
    }

    // MARK: - Step 11: Joint Pain

    private var jointPainStep: some View {
        ScrollView {
            VStack(spacing: 20) {
                Color.clear.frame(height: 70)
                quizCard {
                    VStack(spacing: 16) {
                        Image(systemName: "stethoscope")
                            .font(.system(size: 32))
                            .foregroundStyle(.white)
                            .frame(width: 72, height: 72)
                            .background(Color.wellnessTeal)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                        Text(Lang.s("joint_pain"))
                            .font(.title2.bold())
                            .multilineTextAlignment(.center)
                        Text(Lang.s("ai_avoid_exercises"))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)

                        VStack(spacing: 12) {
                            ForEach(WorkoutQuizStaticData.jointPainAreas, id: \.id) { area in
                                jointPainRow(area)
                            }
                        }
                    }
                    .padding(20)
                }

                Button {
                    quizVM.startGeneration(appVM: appVM)
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "sparkles")
                            .font(.body.weight(.semibold))
                        Text(Lang.s("regenerate_plan_ai"))
                            .font(.headline)
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 54)
                    .background(quizVM.canContinue ? Color.wellnessTeal : Color(.systemGray3))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .shadow(color: Color.wellnessTeal.opacity(0.3), radius: 8, y: 3)
                }
                .buttonStyle(.plain)
                .disabled(!quizVM.canContinue)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 100)
        }
        .scrollIndicators(.hidden)
    }

    private func jointPainRow(_ area: WorkoutQuizStaticData.JointPainOption) -> some View {
        let isSelected = quizVM.preferences.jointPain.contains(area.id)
        return Button {
            withAnimation(.spring(response: 0.25)) {
                quizVM.toggleJointPain(area.id)
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? Color.wellnessTeal : Color(.systemGray3))
                    .font(.title3)

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(area.emoji)
                        Text(area.title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                    }
                    Text(area.subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(isSelected ? Color.wellnessTeal.opacity(0.08) : Color.white.opacity(0.8))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isSelected ? Color.wellnessTeal : Color(.systemGray4), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
        .conditionalSensoryFeedback(.selection, trigger: isSelected)
    }

    // MARK: - Shared Components

    private func singleSelectRow(title: String, subtitle: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button {
            withAnimation(.spring(response: 0.25)) { action() }
        } label: {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.primary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(isSelected ? Color.wellnessTeal.opacity(0.08) : Color.white.opacity(0.8))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(isSelected ? Color.wellnessTeal : Color(.systemGray4), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
        .conditionalSensoryFeedback(.selection, trigger: isSelected)
    }

    // MARK: - Generation Screen

    private var generationScreen: some View {
        ScrollView {
            VStack(spacing: 24) {
                Color.clear.frame(height: 70)
                Image(systemName: "figure.run")
                    .font(.system(size: 48))
                    .foregroundStyle(.white)
                    .frame(width: 80, height: 80)
                    .background(Color.wellnessTeal)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

                VStack(spacing: 8) {
                    Text(Lang.s("creating_ai_nutrition").replacingOccurrences(of: "Nutrition", with: "Workout").replacingOccurrences(of: "nutricional", with: "de entrenamiento").replacingOccurrences(of: "nutrizionale", with: "di allenamento").replacingOccurrences(of: "nutritionnel", with: "d'entraînement").replacingOccurrences(of: "nutricional", with: "de treino").replacingOccurrences(of: "Ernährungs", with: "Trainings"))
                        .font(.title2.bold())
                    Text("\(Lang.s("wgen_ai_selecting_desc")) \(quizVM.preferences.fitnessGoal.lowercased())")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }



                ProgressView(value: quizVM.generationProgress)
                    .tint(Color.wellnessTeal)
                    .scaleEffect(y: 2)
                    .padding(.horizontal, 20)

                Text(quizVM.currentGenerationStep < quizVM.generationSteps.count ? quizVM.generationSteps[quizVM.currentGenerationStep] : Lang.s("wgen_completed"))
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(Color.wellnessTeal)

                if let error = quizVM.generationError {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text(Lang.s("wgen_ai_protocol"))
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
                                Image(systemName: "circle")
                                    .foregroundStyle(.tertiary)
                            }

                            Text(quizVM.generationSteps[index])
                                .font(.subheadline)
                                .foregroundStyle(index <= quizVM.currentGenerationStep ? .primary : .secondary)
                        }
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.8))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                Text(Lang.s("wgen_workout_disclaimer"))
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

    private func quizCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .background(Color.white.opacity(0.85))
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 16, y: 4)
    }

    private func continueButton(action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(Lang.s("next"))
                    .font(.headline)
                Image(systemName: "arrow.right")
                    .font(.subheadline.weight(.semibold))
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
}
