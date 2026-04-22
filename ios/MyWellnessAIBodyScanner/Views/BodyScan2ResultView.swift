import SwiftUI

struct BodyScan2ResultView: View {
    @Environment(AppViewModel.self) private var appVM
    let result: BodyScan2Result
    let photos: [FullScanPhase: UIImage]
    let onDismiss: () -> Void

    private let scanTeal = Color(red: 0.0, green: 0.75, blue: 0.7)
    private let accentGreen = Color(red: 0.2, green: 0.78, blue: 0.45)

    @State private var selectedTab: Int = 0
    @State private var isGeneratingWorkout: Bool = false
    @State private var workoutApplied: Bool = false
    @State private var showDayAssignment: Bool = false
    @State private var pendingWorkoutPlan: WorkoutPlan?
    @State private var selectedTrainingDays: Int = 0
    @State private var showDayPicker: Bool = false
    @State private var selectedWeekdays: [String] = []

    private var hasExistingWorkoutPlan: Bool {
        !appVM.workoutPlan.days.isEmpty
    }

    var body: some View {
        GeometryReader { geo in
            ZStack {
                AnimatedMeshBackground().ignoresSafeArea()

                VStack(spacing: 0) {
                    sheetHeaderBar
                    tabSelector
                        .padding(.top, 8)

                    ScrollView(.vertical, showsIndicators: true) {
                        VStack(spacing: 20) {
                            switch selectedTab {
                            case 0: overviewSection
                            case 1: nutritionPlanSection
                            case 2: trainingPlanSection
                            default: EmptyView()
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 40)
                        .frame(width: geo.size.width)
                    }
                    .scrollBounceBehavior(.basedOnSize)
                    .presentationContentInteraction(.scrolls)
                }
                .ignoresSafeArea(.container, edges: .bottom)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .clipped()
        .preferredColorScheme(.light)
        .onAppear {
            selectedTrainingDays = result.trainingDaysPerWeek
        }
        .sheet(isPresented: $showDayAssignment) {
            if let plan = pendingWorkoutPlan {
                WorkoutDayAssignmentView(
                    workoutPlan: plan,
                    onApply: { reassignedPlan in
                        withAnimation(.spring(response: 0.4)) {
                            appVM.applyScanWorkoutPlan(reassignedPlan)
                            workoutApplied = true
                        }
                        HapticHelper.notification(.success)
                        showDayAssignment = false
                    },
                    onCancel: {
                        showDayAssignment = false
                    }
                )
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationCornerRadius(28)
            }
        }
        .sheet(isPresented: $showDayPicker) {
            WorkoutDayPickerView(
                numberOfDays: selectedTrainingDays,
                onConfirm: { selectedDays in
                    showDayPicker = false
                    selectedWeekdays = selectedDays
                    generateAndApplyWorkoutPlan(forDays: selectedDays)
                },
                onCancel: {
                    showDayPicker = false
                }
            )
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .presentationCornerRadius(28)
        }
    }



    private func generateAndApplyWorkoutPlan(forDays days: [String]) {
        isGeneratingWorkout = true
        let plan: WorkoutPlan
        let generated = WorkoutPlanGenerator.generateFromScanSafe(
            scanResult: result,
            profile: appVM.userProfile,
            selectedDays: days,
            existingPreferences: appVM.workoutQuizPreferences
        )
        plan = generated
        if !plan.days.isEmpty {
            withAnimation(.spring(response: 0.4)) {
                appVM.applyScanWorkoutPlan(plan)
                workoutApplied = true
            }
            HapticHelper.notification(.success)
        }
        isGeneratingWorkout = false
    }

    private func reassignPlanToDays(_ plan: WorkoutPlan, selectedDays: [String]) -> WorkoutPlan {
        let weekdays = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
        var trainingDays = plan.days.filter { !$0.isRestDay }

        while trainingDays.count < selectedDays.count, let template = trainingDays.last {
            var newDay = template
            newDay.id = UUID()
            trainingDays.append(newDay)
        }

        var newDays: [WorkoutDay] = []
        var trainingIdx = 0

        for dayName in weekdays {
            if selectedDays.contains(dayName), trainingIdx < trainingDays.count {
                var day = trainingDays[trainingIdx]
                day.dayName = dayName
                newDays.append(day)
                trainingIdx += 1
            } else {
                newDays.append(WorkoutDay(
                    dayName: dayName,
                    focus: Lang.s("rest_recovery"),
                    durationMinutes: 0,
                    exercises: [],
                    isRestDay: true,
                    caloriesBurned: 0
                ))
            }
        }
        return WorkoutPlan(days: newDays, createdAt: Date())
    }

    private var sheetHeaderBar: some View {
        ZStack {
            Image("MyWellnessAIBodyScannerLogo")
                .resizable()
                .scaledToFit()
                .frame(height: 28)

            HStack {
                Spacer()
                Button { onDismiss() } label: {
                    ZStack {
                        Circle()
                            .fill(Color(.secondarySystemBackground).opacity(0.8))
                            .frame(width: 32, height: 32)
                        Image(systemName: "xmark")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 28)
        .padding(.bottom, 12)
    }

    private var tabSelector: some View {
        HStack(spacing: 6) {
            tabButton(Lang.s("overview"), icon: "person.text.rectangle", tag: 0)
            tabButton(Lang.s("nutrition_label"), icon: "fork.knife", tag: 1)
            tabButton(Lang.s("training_label"), icon: "figure.strengthtraining.traditional", tag: 2)
        }
        .padding(.horizontal, 16)
    }

    private func tabButton(_ label: String, icon: String, tag: Int) -> some View {
        Button {
            withAnimation(.spring(response: 0.3)) { selectedTab = tag }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12, weight: .semibold))
                Text(label)
                    .font(.system(size: 13, weight: .semibold))
            }
            .foregroundStyle(selectedTab == tag ? .white : .primary)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .frame(maxWidth: .infinity)
            .background(selectedTab == tag ? scanTeal : Color(.secondarySystemBackground).opacity(0.8))
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    // MARK: - Overview

    @ViewBuilder
    private var overviewSection: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Text(Lang.s("full_body"))
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.black)
                Text(Lang.s("scan_label"))
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(scanTeal)
            }
            Text(Lang.s("complete_360_analysis"))
                .font(.system(size: 14))
                .foregroundStyle(.black.opacity(0.5))
        }

        photoStrip

        HStack(spacing: 10) {
            overviewCard(icon: "person.crop.circle", label: Lang.s("somatotype_label"), value: result.somatotype, color: Color(red: 0.5, green: 0.2, blue: 0.7))
            overviewCard(icon: "percent", label: Lang.s("body_fat_pct_label"), value: result.estimatedBodyFat, color: .orange)
        }

        HStack(spacing: 10) {
            overviewCard(icon: "building.columns", label: Lang.s("biological_age_label"), value: "\(result.biologicalAge) \(Lang.s("sq_years"))", color: accentGreen)
            overviewCard(icon: "square.stack.3d.up", label: Lang.s("definition_label"), value: result.muscleDefinition, color: Color(red: 0.3, green: 0.4, blue: 0.8))
        }

        HStack(spacing: 10) {
            overviewCard(icon: "drop.fill", label: Lang.s("bloating_label"), value: result.bloatingPercentage, color: Color(red: 0.2, green: 0.6, blue: 0.85))
            overviewCard(icon: "hand.raised.fingers.spread.fill", label: Lang.s("skin_texture_label"), value: result.skinTexture, color: Color(red: 0.75, green: 0.45, blue: 0.3))
        }

        if !result.strongPoints.isEmpty {
            pointsSection(
                title: Lang.s("strengths"),
                icon: "checkmark.seal.fill",
                items: result.strongPoints,
                color: accentGreen
            )
        }

        if !result.weakPoints.isEmpty {
            pointsSection(
                title: Lang.s("weaknesses"),
                icon: "exclamationmark.triangle.fill",
                items: result.weakPoints,
                color: .orange
            )
        }

        if !result.overallAssessment.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "text.quote")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(scanTeal)
                    Text(Lang.s("overall_assessment"))
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(scanTeal)
                }
                Text(result.overallAssessment)
                    .font(.system(size: 14))
                    .foregroundStyle(.black.opacity(0.6))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.8))
            .clipShape(.rect(cornerRadius: 16))
        }

        if !result.posturalNotes.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "figure.stand")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(accentGreen)
                    Text(Lang.s("postural_notes"))
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(accentGreen)
                }
                Text(result.posturalNotes)
                    .font(.system(size: 14))
                    .foregroundStyle(.black.opacity(0.6))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.8))
            .clipShape(.rect(cornerRadius: 16))
        }

        if !result.bodyRegions.isEmpty {
            bodyRegionDetailSection
        }

        if !result.fatDistributionSummary.isEmpty && result.fatDistributionSummary != "--" {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Image(systemName: "figure.arms.open")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.orange)
                    Text(Lang.s("fat_distribution"))
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.orange)
                }
                Text(result.fatDistributionSummary)
                    .font(.system(size: 14))
                    .foregroundStyle(.black.opacity(0.6))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.8))
            .clipShape(.rect(cornerRadius: 16))
        }

        if !result.bloatingAreas.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 6) {
                    Image(systemName: "drop.triangle.fill")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color(red: 0.2, green: 0.6, blue: 0.85))
                    Text(Lang.s("bloating_areas"))
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color(red: 0.2, green: 0.6, blue: 0.85))
                }
                FlowLayout(spacing: 8) {
                    ForEach(result.bloatingAreas, id: \.self) { area in
                        Text(area)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color(red: 0.2, green: 0.6, blue: 0.85))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(red: 0.2, green: 0.6, blue: 0.85).opacity(0.08))
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.8))
            .clipShape(.rect(cornerRadius: 16))
        }

        if !result.focusAreas.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 6) {
                    Image(systemName: "target")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.red)
                    Text(Lang.s("focus_areas"))
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.red)
                }
                FlowLayout(spacing: 8) {
                    ForEach(result.focusAreas, id: \.self) { area in
                        Text(area)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(.red)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.red.opacity(0.08))
                            .clipShape(Capsule())
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.8))
            .clipShape(.rect(cornerRadius: 16))
        }
    }

    private func pointsSection(title: String, icon: String, items: [String], color: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(color)
                Text(title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(color)
            }
            ForEach(Array(items.enumerated()), id: \.offset) { idx, item in
                HStack(alignment: .top, spacing: 10) {
                    ZStack {
                        Circle()
                            .fill(color.opacity(0.15))
                            .frame(width: 24, height: 24)
                        Text("\(idx + 1)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundStyle(color)
                    }
                    Text(item)
                        .font(.system(size: 14))
                        .foregroundStyle(.black)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.8))
        .clipShape(.rect(cornerRadius: 16))
    }

    private var bodyRegionDetailSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "figure.stand")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(scanTeal)
                Text(Lang.s("body_region_analysis"))
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(scanTeal)
            }

            ForEach(result.bodyRegions) { region in
                bodyRegionCard(region)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.8))
        .clipShape(.rect(cornerRadius: 16))
    }

    private func bodyRegionCard(_ region: BodyRegionDetail) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: regionIcon(region.region))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(regionColor(region.score))
                Text(region.region)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.black)
                Spacer()
                HStack(spacing: 4) {
                    Text("\(region.score)")
                        .font(.system(size: 20, weight: .heavy))
                        .foregroundStyle(regionColor(region.score))
                    Text("/10")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.black.opacity(0.3))
                }
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray5))
                        .frame(height: 6)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(regionColor(region.score))
                        .frame(width: geo.size.width * CGFloat(region.score) / 10.0, height: 6)
                }
            }
            .frame(height: 6)

            VStack(alignment: .leading, spacing: 6) {
                regionInfoRow(icon: "figure.strengthtraining.traditional", label: Lang.s("definition_label"), value: region.muscleDefinition)
                regionInfoRow(icon: "scalemass", label: Lang.s("fat_distribution"), value: region.fatDistribution)
                regionInfoRow(icon: "drop.fill", label: Lang.s("bloating_label"), value: region.bloating)
            }

            if !region.notes.isEmpty {
                Text(region.notes)
                    .font(.system(size: 13))
                    .foregroundStyle(.black.opacity(0.55))
                    .fixedSize(horizontal: false, vertical: true)
            }

            if !region.improvementTips.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(Array(region.improvementTips.enumerated()), id: \.offset) { _, tip in
                        HStack(alignment: .top, spacing: 6) {
                            Image(systemName: "arrow.up.right")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(scanTeal)
                                .padding(.top, 2)
                            Text(tip)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(.black.opacity(0.7))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
            }
        }
        .padding(14)
        .background(Color.white.opacity(0.6))
        .clipShape(.rect(cornerRadius: 14))
    }

    private func regionInfoRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(.black.opacity(0.35))
                .frame(width: 14)
            Text(label + ":")
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(.black.opacity(0.4))
            Text(value)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.black.opacity(0.7))
                .fixedSize(horizontal: false, vertical: true)
        }
    }

    private func regionIcon(_ region: String) -> String {
        let lower = region.lowercased()
        if lower.contains("shoulder") || lower.contains("arm") || lower.contains("spall") || lower.contains("bracc") { return "figure.arms.open" }
        if lower.contains("chest") || lower.contains("pett") { return "figure.stand" }
        if lower.contains("abdom") || lower.contains("addom") { return "figure.core.training" }
        if lower.contains("back") || lower.contains("schien") || lower.contains("dorsal") { return "figure.rowing" }
        if lower.contains("glut") { return "figure.run" }
        if lower.contains("upper") || lower.contains("quad") || lower.contains("cosci") || lower.contains("gamb") { return "figure.walk" }
        if lower.contains("lower") || lower.contains("calf") || lower.contains("calv") || lower.contains("polpacc") { return "figure.stand" }
        return "figure.stand"
    }

    private func regionColor(_ score: Int) -> Color {
        switch score {
        case 0...3: return .red
        case 4...5: return .orange
        case 6...7: return Color(red: 0.3, green: 0.5, blue: 0.9)
        case 8...10: return accentGreen
        default: return .gray
        }
    }

    private var photoStrip: some View {
        HStack(spacing: 6) {
            ForEach(FullScanPhase.allCases) { phase in
                let img = photos[phase]
                Color.black
                    .frame(maxWidth: .infinity)
                    .frame(height: 120)
                    .overlay {
                        if let img {
                            Image(uiImage: fixImageOrientation(img))
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .allowsHitTesting(false)
                        } else {
                            Image(systemName: "person.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(.white.opacity(0.3))
                        }
                    }
                    .overlay(alignment: .bottom) {
                        Text(phase.label)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundStyle(.white)
                            .padding(.bottom, 6)
                    }
                    .clipShape(.rect(cornerRadius: 12))
            }
        }
    }

    private func overviewCard(icon: String, label: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(color)
                Text(label)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(color)
            }
            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(color)
                .minimumScaleFactor(0.5)
                .lineLimit(2)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.8))
        .clipShape(.rect(cornerRadius: 14))
    }

    // MARK: - Nutrition Plan

    @ViewBuilder
    private var nutritionPlanSection: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Text(Lang.s("nutrition_plan"))
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.black)
                Text(Lang.s("plan_label"))
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(scanTeal)
            }
            Text(Lang.s("based_on_scan"))
                .font(.system(size: 14))
                .foregroundStyle(.black.opacity(0.5))
        }

        macroSummaryCard

        if !result.nutritionRecommendations.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 6) {
                    Image(systemName: "lightbulb.fill")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.orange)
                    Text(Lang.s("recommendations"))
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(.orange)
                }
                ForEach(Array(result.nutritionRecommendations.enumerated()), id: \.offset) { idx, rec in
                    HStack(alignment: .top, spacing: 10) {
                        Text("\(idx + 1)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 22, height: 22)
                            .background(.orange)
                            .clipShape(Circle())
                        Text(rec)
                            .font(.system(size: 14))
                            .foregroundStyle(.black)
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.8))
            .clipShape(.rect(cornerRadius: 16))
        }

        if !result.sampleMeals.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 6) {
                    Image(systemName: "fork.knife")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(scanTeal)
                    Text(Lang.s("suggested_meals"))
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(scanTeal)
                }
                ForEach(result.sampleMeals) { meal in
                    mealCard(meal)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.8))
            .clipShape(.rect(cornerRadius: 16))
        }

        scanNutritionPlanReadyCard
    }

    @ViewBuilder
    private var scanNutritionPlanReadyCard: some View {
        VStack(spacing: 14) {
            Divider()
                .padding(.vertical, 4)

            HStack(spacing: 10) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(accentGreen)
                VStack(alignment: .leading, spacing: 2) {
                    Text(Lang.s("plan_generated_from_scan"))
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(accentGreen)
                    Text(Lang.s("plan_generated_scan_desc"))
                        .font(.system(size: 12))
                        .foregroundStyle(.black.opacity(0.5))
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
            }
            .padding(16)
            .background(Color.white.opacity(0.8))
            .clipShape(.rect(cornerRadius: 16))
        }
    }

    private var profileCalorieTarget: Int {
        Int(appVM.userProfile.dailyCalorieTarget)
    }

    private var macroSummaryCard: some View {
        VStack(spacing: 16) {
            HStack(spacing: 6) {
                Image(systemName: "chart.pie.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(scanTeal)
                Text(Lang.s("daily_macros"))
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(scanTeal)
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "target")
                        .font(.system(size: 10))
                    Text(Lang.s("your_calorie_target"))
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundStyle(scanTeal.opacity(0.7))
            }

            HStack {
                VStack(spacing: 4) {
                    Text("\(profileCalorieTarget)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(.black)
                    Text(Lang.s("kcal_per_day"))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.black.opacity(0.5))
                }
                .frame(maxWidth: .infinity)

                VStack(spacing: 12) {
                    macroRow(label: "Proteine", value: "\(Int(appVM.userProfile.proteinTarget))g", color: Color(red: 0.3, green: 0.5, blue: 0.9))
                    macroRow(label: "Carboidrati", value: "\(Int(appVM.userProfile.carbsTarget))g", color: .orange)
                    macroRow(label: "Grassi", value: "\(Int(appVM.userProfile.fatTarget))g", color: Color(red: 0.8, green: 0.3, blue: 0.4))
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.8))
        .clipShape(.rect(cornerRadius: 16))
    }

    private func macroRow(label: String, value: String, color: Color) -> some View {
        HStack {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(.black.opacity(0.5))
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(color)
        }
    }

    private func mealCard(_ meal: BodyScan2Meal) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(mealTypeColor(meal.type).opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: mealTypeIcon(meal.type))
                    .font(.system(size: 18))
                    .foregroundStyle(mealTypeColor(meal.type))
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(meal.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(.black)
                    Spacer()
                    Text("\(meal.calories) kcal")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(scanTeal)
                }
                Text(meal.description)
                    .font(.system(size: 12))
                    .foregroundStyle(.black.opacity(0.5))
                    .lineLimit(2)
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.8))
        .clipShape(.rect(cornerRadius: 12))
    }

    private func mealTypeIcon(_ type: String) -> String {
        switch type.lowercased() {
        case "breakfast": return "sunrise.fill"
        case "lunch": return "sun.max.fill"
        case "dinner": return "moon.fill"
        default: return "leaf.fill"
        }
    }

    private func mealTypeColor(_ type: String) -> Color {
        switch type.lowercased() {
        case "breakfast": return .orange
        case "lunch": return Color(red: 0.3, green: 0.5, blue: 0.9)
        case "dinner": return Color(red: 0.5, green: 0.2, blue: 0.7)
        default: return accentGreen
        }
    }

    // MARK: - Training Plan

    @ViewBuilder
    private var trainingPlanSection: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Text(Lang.s("training_plan"))
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(.black)
                Text(Lang.s("plan_label"))
                    .font(.system(size: 32, weight: .bold))
                    .foregroundStyle(scanTeal)
            }
            Text(hasExistingWorkoutPlan ? Lang.s("suggested_changes_scan") : Lang.s("personalized_body"))
                .font(.system(size: 14))
                .foregroundStyle(.black.opacity(0.5))
        }

        HStack(spacing: 10) {
            trainingSummaryCard(icon: "arrow.triangle.branch", label: Lang.s("split_label"), value: result.trainingSplit, color: Color(red: 0.5, green: 0.2, blue: 0.7))
        }

        editableTrainingDaysCard

        if !result.trainingRecommendations.isEmpty {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color(red: 0.3, green: 0.5, blue: 0.9))
                    Text(Lang.s("tips_label"))
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color(red: 0.3, green: 0.5, blue: 0.9))
                }
                ForEach(Array(result.trainingRecommendations.enumerated()), id: \.offset) { idx, rec in
                    HStack(alignment: .top, spacing: 10) {
                        Text("\(idx + 1)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 22, height: 22)
                            .background(Color(red: 0.3, green: 0.5, blue: 0.9))
                            .clipShape(Circle())
                        Text(rec)
                            .font(.system(size: 14))
                            .foregroundStyle(.black)
                    }
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.8))
            .clipShape(.rect(cornerRadius: 16))
        }

        workoutPlanGenerationSection
    }

    private var editableTrainingDaysCard: some View {
        VStack(spacing: 16) {
            HStack(spacing: 6) {
                Image(systemName: "calendar")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(scanTeal)
                Text(Lang.s("days_week"))
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(scanTeal)
                Spacer()
            }

            HStack(spacing: 20) {
                Button {
                    if selectedTrainingDays > 1 {
                        withAnimation(.spring(response: 0.3)) { selectedTrainingDays -= 1 }
                    }
                } label: {
                    Image(systemName: "minus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(selectedTrainingDays > 1 ? scanTeal : .gray.opacity(0.3))
                }
                .disabled(selectedTrainingDays <= 1)

                Text("\(selectedTrainingDays)")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundStyle(scanTeal)
                    .contentTransition(.numericText())
                    .frame(minWidth: 60)

                Button {
                    if selectedTrainingDays < 7 {
                        withAnimation(.spring(response: 0.3)) { selectedTrainingDays += 1 }
                    }
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(selectedTrainingDays < 7 ? scanTeal : .gray.opacity(0.3))
                }
                .disabled(selectedTrainingDays >= 7)
            }

            Text("\(7 - selectedTrainingDays) " + Lang.s("rest_days_label"))
                .font(.system(size: 13))
                .foregroundStyle(.black.opacity(0.4))
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.8))
        .clipShape(.rect(cornerRadius: 16))
    }

    @ViewBuilder
    private var workoutPlanGenerationSection: some View {
        VStack(spacing: 16) {
            Divider()
                .padding(.vertical, 4)

            if workoutApplied {
                HStack(spacing: 10) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(accentGreen)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(hasExistingWorkoutPlan ? Lang.s("changes_applied") : Lang.s("workout_applied"))
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(accentGreen)
                        Text(Lang.s("go_training_section"))
                            .font(.system(size: 12))
                            .foregroundStyle(.black.opacity(0.5))
                    }
                    Spacer()
                }
                .padding(16)
                .background(Color.white.opacity(0.8))
                .clipShape(.rect(cornerRadius: 16))
            } else if isGeneratingWorkout {
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        ProgressView()
                            .tint(scanTeal)
                        Text("Generando piano di allenamento completo...")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(.black.opacity(0.5))
                    }
                    Text("Stiamo creando un piano settimanale personalizzato basato sulla tua analisi corporea e i giorni selezionati")
                        .font(.system(size: 12))
                        .foregroundStyle(.black.opacity(0.35))
                        .multilineTextAlignment(.center)
                }
                .padding(20)
                .frame(maxWidth: .infinity)
                .background(Color.white.opacity(0.8))
                .clipShape(.rect(cornerRadius: 16))
            } else {
                Button {
                    showDayPicker = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 16, weight: .semibold))
                        Text(Lang.s("choose_days_and_apply"))
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(
                        LinearGradient(
                            colors: [scanTeal, Color(red: 0.3, green: 0.5, blue: 0.9)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(.rect(cornerRadius: 14))
                }
            }
        }
    }

    private func changeRow(change: PlanChange, color: Color) -> some View {
        HStack(alignment: .top, spacing: 10) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.12))
                    .frame(width: 32, height: 32)
                Image(systemName: changeTypeIcon(change.changeType))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(color)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    Text(change.dayName)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(color)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(color.opacity(0.1))
                        .clipShape(Capsule())
                    Text(change.changeType.capitalized)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundStyle(.black.opacity(0.4))
                }
                Text(change.description)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.black)
                    .fixedSize(horizontal: false, vertical: true)
                if !change.reason.isEmpty {
                    Text(change.reason)
                        .font(.system(size: 12))
                        .foregroundStyle(.black.opacity(0.5))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding(12)
        .background(Color.white.opacity(0.8))
        .clipShape(.rect(cornerRadius: 12))
    }

    private func changeTypeIcon(_ type: String) -> String {
        switch type.lowercased() {
        case "replace", "sostituire": return "arrow.left.arrow.right"
        case "add", "aggiungere": return "plus.circle"
        case "remove", "rimuovere": return "minus.circle"
        case "modify": return "pencil"
        default: return "arrow.triangle.2.circlepath"
        }
    }

    private func trainingSummaryCard(icon: String, label: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundStyle(color)
                Text(label)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(color)
            }
            Text(value)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(color)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.8))
        .clipShape(.rect(cornerRadius: 14))
    }

    private func fixImageOrientation(_ image: UIImage) -> UIImage {
        guard image.imageOrientation != .up else { return image }
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        image.draw(in: CGRect(origin: .zero, size: image.size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return normalizedImage ?? image
    }

    private func exerciseCard(_ exercise: BodyScan2Exercise) -> some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(scanTeal.opacity(0.1))
                    .frame(width: 44, height: 44)
                Image(systemName: "figure.strengthtraining.traditional")
                    .font(.system(size: 18))
                    .foregroundStyle(scanTeal)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.black)
                HStack(spacing: 12) {
                    Label("\(exercise.sets) serie", systemImage: "repeat")
                        .font(.system(size: 12))
                        .foregroundStyle(.black.opacity(0.5))
                    Label(exercise.reps + " reps.", systemImage: "number")
                        .font(.system(size: 12))
                        .foregroundStyle(.black.opacity(0.5))
                }
            }

            Spacer()

            Text(exercise.muscleGroup)
                .font(.system(size: 11, weight: .semibold))
                .foregroundStyle(scanTeal)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(scanTeal.opacity(0.1))
                .clipShape(Capsule())
        }
        .padding(12)
        .background(Color.white.opacity(0.8))
        .clipShape(.rect(cornerRadius: 12))
    }
}
