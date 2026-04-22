import SwiftUI

struct WorkoutView: View {
    @Environment(AppViewModel.self) private var appVM
    @State private var selectedDay: String = Date().weekdayName
    @State private var showModifySession: Bool = false
    @State private var showImportWorkout: Bool = false
    @State private var showMealPlanQuiz: Bool = false
    @State private var showWorkoutQuiz: Bool = false
    @State private var exerciseForDetail: Exercise?

    @State private var exerciseForDelete: Exercise?
    @State private var addExerciseDay: WorkoutDay?
    @State private var hapticTrigger: Int = 0

    private let days = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    private let shortDayKeys = ["mon", "tue", "wed", "thu", "fri", "sat", "sun"]

    private var selectedDayIndex: Int? {
        appVM.workoutPlan.days.firstIndex(where: { $0.dayName == selectedDay })
    }

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(spacing: 20) {
                    Color.clear.frame(height: 104)
                    header
                    actionButtons
                    if appVM.isGeneratingPlan {
                        generatingView
                    } else {
                        weeklyScheduleSection
                    }
                }
                .padding(.bottom, 100)
            }
            .ignoresSafeArea(edges: .top)
            .scrollIndicators(.hidden)

            WellnessNavBarOverlay()
        }
        .sheet(item: $exerciseForDetail) { exercise in
            ExerciseDetailSheet(exercise: exercise)
        }

        .sheet(item: $exerciseForDelete) { exercise in
            DeleteExerciseSheet(exercise: exercise) {
                if let di = selectedDayIndex {
                    withAnimation(.spring(response: 0.3)) {
                        appVM.deleteExercise(dayIndex: di, exerciseId: exercise.id)
                    }
                }
            }
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(28)
        }
        .sheet(isPresented: $showModifySession) {
            ModifySessionSheet()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)
        }
        .sheet(isPresented: $showImportWorkout) {
            ImportWorkoutSheet()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)
        }
        .sheet(item: $addExerciseDay) { day in
            AddExerciseSheet(currentDay: day) { newExercise in
                if let di = selectedDayIndex {
                    withAnimation(.spring(response: 0.3)) {
                        appVM.addExercise(dayIndex: di, exercise: newExercise)
                    }
                }
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(32)
            .presentationContentInteraction(.scrolls)
        }
        .fullScreenCover(isPresented: $showMealPlanQuiz) {
            MealPlanQuizView()
        }
        .fullScreenCover(isPresented: $showWorkoutQuiz) {
            WorkoutQuizView()
        }
        .onChange(of: showWorkoutQuiz) { _, newValue in
            if !newValue {
                appVM.isGeneratingPlan = false
                if appVM.workoutPlan.days.isEmpty {
                    appVM.workoutPlan = WorkoutLocalization.localizePlan(DefaultData.workoutPlan(for: appVM.userProfile))
                }
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(Lang.s("workout_protocol"))
                .font(.system(.largeTitle, weight: .bold))
            Text("\(appVM.workoutPlan.totalExercises) \(Lang.s("exercises_in_plan")) \u{2022} \(Lang.s("goal_colon"))\(Lang.localizedGoal(appVM.userProfile.goal.rawValue))")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
    }

    private var actionButtons: some View {
        VStack(spacing: 10) {
            Button {
                hapticTrigger += 1
                showWorkoutQuiz = true
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "brain.filled.head.profile")
                        .font(.body.weight(.semibold))
                    Text(Lang.s("regenerate_plan_ai"))
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
            .conditionalSensoryFeedback(.impact(weight: .medium), trigger: hapticTrigger)

            Button {
                showImportWorkout = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "square.and.arrow.up")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(Color.wellnessTeal)
                    Text(Lang.s("import_plan"))
                        .font(.headline)
                        .foregroundStyle(Color.wellnessTeal)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.white.opacity(0.8))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.wellnessTeal.opacity(0.3), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
    }

    private var generatingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.4)
                .tint(Color.wellnessTeal)
            Text(Lang.s("ai_crafting_workout"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
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

            if let workoutDay = appVM.effectiveWorkoutDay(for: selectedDay) {
                dayContent(day: workoutDay)
            } else {
                ContentUnavailableView(Lang.s("no_plan"), systemImage: "dumbbell.fill")
                    .frame(height: 200)
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
        return Button {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                selectedDay = day
            }
        } label: {
            VStack(spacing: 5) {
                Text(short)
                    .font(.subheadline.weight(isSelected ? .bold : .regular))
                    .foregroundStyle(isSelected ? Color.wellnessTeal : Color.secondary)
                Rectangle()
                    .fill(isSelected ? Color.wellnessTeal : Color.clear)
                    .frame(height: 2)
                    .clipShape(RoundedRectangle(cornerRadius: 1))
            }
            .frame(width: 54)
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
        .conditionalSensoryFeedback(.selection, trigger: isSelected)
    }

    @ViewBuilder
    private func dayContent(day: WorkoutDay) -> some View {
        VStack(spacing: 16) {
            if day.isRestDay {
                restDayCard()
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 20)
            } else {
                workoutDayHeader(day: day)
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                modifySessionButton
                    .padding(.horizontal, 20)

                if selectedDay == Date().weekdayName && appVM.hasActiveSessionOverride {
                    tempOverrideIndicator
                        .padding(.horizontal, 20)
                }

                Divider()
                    .padding(.horizontal, 20)

                if !day.warmupExercises.isEmpty {
                    warmupSection(exercises: day.warmupExercises)
                        .padding(.horizontal, 20)
                }

                if !day.mainExercises.isEmpty {
                    mainExercisesSection(day: day)
                }

                if !day.cooldownExercises.isEmpty {
                    cooldownSection(exercises: day.cooldownExercises)
                        .padding(.horizontal, 20)
                }

                if day.completionPercent > 0 && day.completionPercent < 1.0 {
                    progressBar(day: day)
                        .padding(.horizontal, 20)
                }

                Divider()
                    .padding(.horizontal, 20)

                completeWorkoutButton(day: day)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
            }
        }
    }

    private func workoutDayHeader(day: WorkoutDay) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(day.focus)
                .font(.title2.bold())
            Text("\(Lang.localizedDayName(day.dayName)) \u{2022} \(day.durationMinutes) min \u{2022} \(day.caloriesBurned) kcal")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var tempOverrideIndicator: some View {
        HStack(spacing: 8) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.caption.weight(.bold))
                .foregroundStyle(Color(red: 0.6, green: 0.45, blue: 0.0))
            Text(Lang.s("session_temp_active"))
                .font(.caption.weight(.semibold))
                .foregroundStyle(Color(red: 0.6, green: 0.45, blue: 0.0))
            Spacer()
            Button {
                withAnimation(.spring(response: 0.3)) {
                    appVM.clearSessionOverride()
                }
            } label: {
                Text(Lang.s("reset_session"))
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.red)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.red.opacity(0.1))
                    .clipShape(Capsule())
            }
            .buttonStyle(.plain)
        }
        .padding(10)
        .background(Color(red: 1.0, green: 0.96, blue: 0.88))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private var modifySessionButton: some View {
        Button {
            showModifySession = true
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "wand.and.stars")
                    .font(.subheadline.weight(.semibold))
                Text(Lang.s("modify_session"))
                    .font(.subheadline.weight(.semibold))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .foregroundStyle(Color(red: 0.6, green: 0.45, blue: 0.0))
            .background(Color(red: 1.0, green: 0.92, blue: 0.7))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
        .conditionalSensoryFeedback(.selection, trigger: showModifySession)
    }

    private func warmupSection(exercises: [Exercise]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Text("\u{1F525}")
                Text(Lang.s("warmup"))
                    .font(.headline)
            }

            ForEach(exercises) { exercise in
                HStack {
                    Text("\(exercise.name)")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.wellnessTeal) +
                    Text(" (\(exercise.durationMinutes > 0 ? "\(exercise.durationMinutes) \(Lang.s("minutes"))" : exercise.reps))")
                        .font(.subheadline)
                        .foregroundStyle(Color.wellnessTeal)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(Color.wellnessTeal.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
        }
    }

    private func mainExercisesSection(day: WorkoutDay) -> some View {
        VStack(spacing: 12) {
            HStack {
                Text(Lang.s("main_exercises"))
                    .font(.headline)
                Spacer()
                Button {
                    if let di = selectedDayIndex, di < appVM.workoutPlan.days.count {
                        addExerciseDay = appVM.workoutPlan.days[di]
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                            .font(.caption.weight(.bold))
                        Text(Lang.s("add"))
                            .font(.subheadline.weight(.semibold))
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

            ForEach(day.mainExercises) { exercise in
                WorkoutExerciseCard(
                    exercise: exercise,
                    dayIndex: selectedDayIndex ?? 0,
                    onToggleSet: { setNum in
                        if let di = selectedDayIndex {
                            withAnimation(.spring(response: 0.3)) {
                                appVM.toggleSetCompletion(dayIndex: di, exerciseId: exercise.id, setNumber: setNum)
                            }
                        }
                    },

                    onDelete: { exerciseForDelete = exercise },
                    onDetail: { exerciseForDetail = exercise }
                )
                .padding(.horizontal, 20)
            }
        }
    }

    private func cooldownSection(exercises: [Exercise]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Text("\u{2744}\u{FE0F}")
                Text(Lang.s("cooldown"))
                    .font(.headline)
            }

            ForEach(exercises) { exercise in
                HStack {
                    Text("\(exercise.name)")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(Color.wellnessTeal) +
                    Text(" (\(exercise.durationMinutes > 0 ? "\(exercise.durationMinutes) \(Lang.s("minutes"))" : exercise.reps))")
                        .font(.subheadline)
                        .foregroundStyle(Color.wellnessTeal)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(Color.blue.opacity(0.06))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
        }
    }

    private func progressBar(day: WorkoutDay) -> some View {
        VStack(spacing: 8) {
            HStack {
                Text(Lang.s("progress"))
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text("\(day.completedExercises)/\(day.totalExercises)")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color.wellnessTeal)
            }
            NutrientBar(
                current: Double(day.completedExercises),
                target: Double(day.totalExercises),
                color: Color.wellnessTeal
            )
        }
    }

    private func completeWorkoutButton(day: WorkoutDay) -> some View {
        Button {
            if let di = selectedDayIndex {
                withAnimation(.spring(response: 0.4)) {
                    appVM.completeWorkout(dayIndex: di)
                }
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.body.weight(.semibold))
                Text(Lang.s("complete_workout"))
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 54)
            .background(day.completionPercent >= 1.0 ? Color.gray : Color.wellnessTeal)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: Color.wellnessTeal.opacity(0.3), radius: 10, y: 4)
        }
        .buttonStyle(.plain)
        .disabled(day.completionPercent >= 1.0)
        .conditionalSensoryFeedback(.success, trigger: day.completionPercent >= 1.0)
    }

    private func restDayCard() -> some View {
        VStack(spacing: 20) {
            Image(systemName: "moon.zzz.fill")
                .font(.system(size: 48))
                .foregroundStyle(.orange)

            VStack(spacing: 8) {
                Text(Lang.s("rest_recovery"))
                    .font(.title2.bold())
                Text(Lang.s("rest_day_message"))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            HStack(spacing: 16) {
                recoveryTip(icon: "drop.fill", title: Lang.s("hydrate"), color: .blue)
                recoveryTip(icon: "bed.double.fill", title: Lang.s("sleep_8h"), color: .indigo)
                recoveryTip(icon: "figure.walk", title: Lang.s("light_walk"), color: .green)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
    }

    private func recoveryTip(icon: String, title: String, color: Color) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
                .frame(width: 48, height: 48)
                .background(color.opacity(0.1))
                .clipShape(Circle())
            Text(title)
                .font(.caption.weight(.semibold))
        }
        .frame(maxWidth: .infinity)
    }
}

struct WorkoutExerciseCard: View {
    let exercise: Exercise
    let dayIndex: Int
    let onToggleSet: (Int) -> Void
    let onDelete: () -> Void
    let onDetail: () -> Void

    @State private var setTrigger: Int = 0

    private var isDone: Bool {
        exercise.allSetsCompleted || exercise.isCompleted
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(exercise.name)
                    .font(.title3.bold())
                Spacer()
                if isDone {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark")
                            .font(.caption.weight(.bold))
                        Text(Lang.s("done"))
                            .font(.caption.weight(.bold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color(red: 0.15, green: 0.55, blue: 0.3))
                    .clipShape(Capsule())
                }
            }

            HStack(spacing: 8) {
                Text(exercise.setDisplay)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.wellnessTeal)
                    .clipShape(Capsule())

                if !exercise.rpeDisplay.isEmpty {
                    Text(exercise.rpeDisplay)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.orange)
                        .clipShape(Capsule())
                }

                if exercise.restSeconds > 0 {
                    Text("\u{2022} \(exercise.restSeconds) \(Lang.s("seconds"))")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            if exercise.sets > 0 {
                HStack(spacing: 8) {
                    ForEach(1...exercise.sets, id: \.self) { setNum in
                        let isSetDone = exercise.completedSets.contains(setNum)
                        Button {
                            setTrigger += 1
                            onToggleSet(setNum)
                        } label: {
                            HStack(spacing: 4) {
                                Text("\(Lang.s("set")) \(setNum)")
                                    .font(.subheadline.weight(.medium))
                                if isSetDone {
                                    Image(systemName: "checkmark")
                                        .font(.caption2.weight(.bold))
                                }
                            }
                            .foregroundStyle(isSetDone ? .white : .primary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(isSetDone ? Color(red: 0.15, green: 0.55, blue: 0.3) : Color(.systemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .stroke(isSetDone ? Color.clear : Color(.systemGray4), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .conditionalSensoryFeedback(.impact(weight: .light), trigger: setTrigger)
            }

            if !exercise.muscleGroups.isEmpty {
                HStack(spacing: 6) {
                    ForEach(exercise.muscleGroups.prefix(4), id: \.self) { group in
                        Text(group)
                            .font(.caption2.weight(.medium))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .foregroundStyle(Color.wellnessTeal)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .stroke(Color.wellnessTeal.opacity(0.3), lineWidth: 1)
                            )
                    }
                }
            }

            if !exercise.loadTips.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Text("\u{1F3AF}")
                        Text(Lang.s("suggested_load"))
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color(red: 0.6, green: 0.4, blue: 0.0))
                    }
                    ForEach(exercise.loadTips, id: \.self) { tip in
                        Text("\u{2022} \(tip)")
                            .font(.caption)
                            .foregroundStyle(Color(red: 0.6, green: 0.4, blue: 0.0))
                    }
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(red: 1.0, green: 0.96, blue: 0.88))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(Color.orange.opacity(0.2), lineWidth: 1)
                )
            }

            HStack(spacing: 12) {
                if !exercise.difficulty.isEmpty {
                    Text(exercise.difficulty)
                        .font(.caption.weight(.bold))
                        .foregroundStyle(difficultyColor(exercise.difficulty))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(difficultyColor(exercise.difficulty).opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(difficultyColor(exercise.difficulty).opacity(0.3), lineWidth: 1)
                        )
                }

                Spacer()

                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)

                Button(action: onDetail) {
                    HStack(spacing: 4) {
                        Image(systemName: "eye")
                            .font(.caption)
                        Text(Lang.s("details"))
                            .font(.caption.weight(.semibold))
                    }
                    .foregroundStyle(Color.wellnessTeal)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
        .overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(isDone ? Color(red: 0.15, green: 0.55, blue: 0.3).opacity(0.3) : Color(.systemGray5), lineWidth: 1)
        )
    }

    private func difficultyColor(_ difficulty: String) -> Color {
        switch difficulty.lowercased() {
        case "beginner": return .green
        case "intermediate": return .orange
        case "advanced": return .red
        default: return .gray
        }
    }
}
