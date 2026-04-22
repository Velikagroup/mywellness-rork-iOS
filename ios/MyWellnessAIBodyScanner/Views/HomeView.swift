import SwiftUI
import Charts


struct HomeView: View {
    @Environment(AppViewModel.self) private var appVM
    @State private var showAddWeight = false
    @State private var newWeight = ""
    @State private var scrollOffset: CGFloat = 0
    @State private var showEditCalorieTarget = false
    @State private var newCalorieTarget = ""
    @State private var showEditBMR = false
    @State private var newBMR = ""
    @State private var showEditNEAT = false
    @State private var showBodyFatSheet = false
    @State private var bfNeck = ""
    @State private var bfWaist = ""
    @State private var bfHip = ""
    @State private var showWellnessDetail = false
    @State private var showMemojiPicker = false
    @AppStorage("useMetricUnits") private var useMetric: Bool = true
    @State private var selectedWeightDate: Date? = nil
    @State private var mealForPhotoScan: Meal? = nil
    @State private var selectedHomeMeal: Meal? = nil
    @State private var selectedCalendarDate: Date = Date()
    @State private var showDayDetail: Bool = false

    private let cal = Calendar.current

    private var monthDays: [Date] {
        let now = Date()
        let comps = cal.dateComponents([.year, .month], from: now)
        guard let startOfMonth = cal.date(from: comps),
              let range = cal.range(of: .day, in: .month, for: now) else { return [] }
        return (0..<range.count).compactMap { offset in
            cal.date(byAdding: .day, value: offset, to: startOfMonth)
        }
    }

    var body: some View {
        ZStack(alignment: .top) {
            ScrollView {
                VStack(spacing: 0) {
                    Color.clear.frame(height: 110)

                    monthCalendarStrip
                        .padding(.top, 8)
                        .padding(.bottom, 12)

                    VStack(spacing: 20) {
                        balanceCard
                        macroAndMealsCard
                            .opacity(macroCardOpacity)
                            .animation(.easeOut(duration: 0.15), value: macroCardOpacity)
                    }
                }
                .padding(.bottom, 120)
            }
            .ignoresSafeArea(edges: .top)
            .scrollIndicators(.hidden)
            .onScrollGeometryChange(for: CGFloat.self) { geo in
                geo.contentOffset.y
            } action: { _, newValue in
                scrollOffset = newValue
            }

            homeTopBar
        }
        .sheet(isPresented: $showAddWeight) {
            addWeightSheet
        }
        .sheet(isPresented: $showEditCalorieTarget) {
            editCalorieTargetSheet
        }
        .sheet(isPresented: $showEditBMR) {
            editBMRSheet
        }
        .sheet(isPresented: $showEditNEAT) {
            editNEATSheet
        }
        .sheet(isPresented: $showBodyFatSheet) {
            bodyFatSheet
        }
        .sheet(isPresented: $showWellnessDetail) {
            HealthWellnessView()
                .environment(appVM)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
                .presentationContentInteraction(.scrolls)
        }
        .sheet(isPresented: $showMemojiPicker) {
            MemojiPickerSheet(isPresented: $showMemojiPicker) { images in
                appVM.saveMemojiImages(images)
            }
        }
        .sheet(isPresented: $showDayDetail) {
            DayDetailView(date: selectedCalendarDate)
                .environment(appVM)
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
                .presentationContentInteraction(.scrolls)
        }
        .sheet(item: $selectedHomeMeal) { meal in
            MealDetailView(meal: meal)
        }
        .sheet(item: $mealForPhotoScan) { meal in
            MealPhotoScanView(meal: meal, onAdd: { result, image in
                appVM.addScannedCaloriesForMeal(
                    mealId: meal.id,
                    scannedCalories: result.calories,
                    imageData: image?.jpegData(compressionQuality: 0.6)
                )
            }, openCameraOnAppear: true)
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
            .presentationContentInteraction(.scrolls)
        }
    }

    private var homeTopBar: some View {
        HStack {
            Spacer()
            WellnessLogo()
            Spacer()
        }
        .padding(.bottom, 16)
        .frame(maxWidth: .infinity)
    }

    private var monthCalendarStrip: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    ForEach(monthDays, id: \.self) { day in
                        calendarDayCell(for: day)
                    }
                }
            }
            .contentMargins(.horizontal, 8, for: .scrollContent)
            .onAppear {
                if let today = monthDays.first(where: { cal.isDateInToday($0) }) {
                    proxy.scrollTo(today, anchor: .center)
                }
            }
            .onChange(of: selectedCalendarDate) { _, newDate in
                withAnimation {
                    proxy.scrollTo(newDate, anchor: .center)
                }
            }
        }
    }

    private func calendarDayCell(for day: Date) -> some View {
        let isToday = cal.isDateInToday(day)
        let isSelected = cal.isDate(day, inSameDayAs: selectedCalendarDate)
        let isFuture = day > Date() && !isToday
        let snapshot = appVM.snapshot(for: day)
        let mood: WellnessMood? = {
            if isToday { return appVM.wellnessMood }
            return snapshot.map { WellnessMood.from(score: $0.wellnessScore) }
        }()
        let dayNum = cal.component(.day, from: day)
        let dayAbbrev: String = {
            let weekday = cal.component(.weekday, from: day)
            let keys = ["", "sun", "mon", "tue", "wed", "thu", "fri", "sat"]
            return Lang.s(keys[weekday])
        }()

        return Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                selectedCalendarDate = day
            }
            showDayDetail = true
        } label: {
            VStack(spacing: 3) {
                Text(dayAbbrev)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(
                        isFuture ? Color.secondary.opacity(0.35)
                        : isSelected ? Color.primary
                        : Color.secondary
                    )

                ZStack {
                    if isSelected {
                        Circle()
                            .fill(mood?.color ?? Color.secondary.opacity(0.18))
                            .frame(width: 36, height: 36)
                    } else if let mood = mood {
                        Circle()
                            .strokeBorder(mood.color, lineWidth: 2)
                            .frame(width: 36, height: 36)
                    } else {
                        Circle()
                            .strokeBorder(
                                style: StrokeStyle(lineWidth: 1.5, dash: [3, 3])
                            )
                            .foregroundStyle(
                                isFuture ? Color.secondary.opacity(0.2) : Color.secondary.opacity(0.35)
                            )
                            .frame(width: 36, height: 36)
                    }

                    Text("\(dayNum)")
                        .font(.system(size: 14, weight: isSelected ? .bold : .medium))
                        .foregroundStyle(
                            isSelected ? .white
                            : isFuture ? Color.secondary.opacity(0.4)
                            : .primary
                        )
                }
            }
            .frame(width: 44)
            .padding(.vertical, 6)
            .background(.white.opacity(0.80))
            .clipShape(.rect(cornerRadius: 14, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 6, y: 2)
        }
        .buttonStyle(.plain)
        .id(day)
    }

    private var macroCardOpacity: Double {
        let offset = max(0, scrollOffset)
        let progress = min(1.0, offset / 130.0)
        return 0.2 + progress * 0.8
    }

    private var balanceCard: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    HStack(spacing: 8) {
                        Image(systemName: "flame.fill")
                            .foregroundStyle(.orange)
                            .font(.title3)
                        Text(Lang.s("todays_balance"))
                            .font(.headline)
                    }
                    Spacer()
                    weightBadge
                }

                HStack(alignment: .center, spacing: 0) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(alignment: .center, spacing: 0) {
                            Text(appVM.calorieBalance < 0 ? "-\(String(abs(appVM.calorieBalance)))" : String(appVM.calorieBalance))
                                .font(.system(size: 44, weight: .bold, design: .rounded))
                                .foregroundStyle(appVM.balanceLabelColor)
                                .contentTransition(.numericText())
                                .lineLimit(1)
                                .minimumScaleFactor(0.45)

                            Text(" kcal")
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.secondary)
                        }

                        Text(appVM.balanceLabel)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(appVM.balanceLabelColor)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 5)
                            .background(appVM.balanceLabelColor.opacity(0.12))
                            .clipShape(.capsule)
                    }
                    .layoutPriority(1)

                    Spacer(minLength: 6)

                    wellnessAvatarButton
                }

                weightChart
                    .frame(height: 140)
                    .overlay(alignment: .topTrailing) {
                        bodyFatBox
                    }

                Divider()
                    .padding(.vertical, 4)

                calorieDetails
            }
            .padding(20)
        }
        .background(.white.opacity(0.80))
        .clipShape(.rect(cornerRadius: 28, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 16, y: 4)
        .padding(.horizontal, 16)
    }

    private var wellnessAvatarButton: some View {
        Button {
            showWellnessDetail = true
        } label: {
            VStack(spacing: 4) {
                ZStack {
                    WellnessAuraView(mood: appVM.wellnessMood)
                        .frame(width: 150, height: 150)

                    ZStack {
                        Circle()
                            .fill(appVM.wellnessMood.color.opacity(0.12))
                            .frame(width: 88, height: 88)

                        if let uiImage = appVM.memojiUIImage(for: appVM.wellnessMood) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 100, height: 100)
                                .clipShape(.circle)
                                .animation(.easeInOut(duration: 0.6), value: appVM.wellnessMood)
                                .allowsHitTesting(false)
                        } else {
                            Text(appVM.wellnessMood.emoji)
                                .font(.system(size: 60))
                                .frame(width: 88, height: 88)
                                .multilineTextAlignment(.center)
                        }

                        Circle()
                            .fill(appVM.wellnessMood.color)
                            .frame(width: 26, height: 26)
                            .overlay(
                                Image(systemName: "heart.fill")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundStyle(.white)
                            )
                            .shadow(color: .black.opacity(0.12), radius: 3, y: 1)
                            .offset(x: 30, y: 30)
                    }
                }

                WellnessMoodLabel(mood: appVM.wellnessMood)
            }
        }
        .buttonStyle(.plain)
    }

    private var weightBadge: some View {
        Button {
            newWeight = String(format: "%.1f", WeightFormatter.fromKg(appVM.userProfile.currentWeightKg, metric: useMetric))
            showAddWeight = true
        } label: {
            HStack(spacing: 4) {
                Text(WeightFormatter.format(appVM.userProfile.currentWeightKg, metric: useMetric))
                    .fontWeight(.bold)
                    .foregroundStyle(Color.wellnessTeal)
                Image(systemName: "arrow.right")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.secondary)
                Text(WeightFormatter.format(appVM.userProfile.targetWeightKg, metric: useMetric))
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                Text(useMetric ? "kg" : "lbs")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .font(.subheadline)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(.secondarySystemBackground))
            .clipShape(.capsule)
        }
        .buttonStyle(.plain)
    }

    private var bodyFatBox: some View {
        Button {
            bfNeck = appVM.userProfile.neckCircumferenceCm.map { String(format: "%.1f", $0) } ?? ""
            bfWaist = appVM.userProfile.waistCircumferenceCm.map { String(format: "%.1f", $0) } ?? ""
            bfHip = appVM.userProfile.hipCircumferenceCm.map { String(format: "%.1f", $0) } ?? ""
            showBodyFatSheet = true
        } label: {
            VStack(spacing: 2) {
                if let bf = appVM.userProfile.bodyFatPercentage {
                    Text(String(format: "%.1f%%", bf))
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(red: 0.45, green: 0.2, blue: 0.85))
                    Text(Lang.s("fat").lowercased())
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundStyle(Color(red: 0.45, green: 0.2, blue: 0.85).opacity(0.7))
                } else {
                    Text("?")
                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(red: 0.45, green: 0.2, blue: 0.85))
                }
            }
            .frame(width: 52, height: 52)
            .background(Color(red: 0.45, green: 0.2, blue: 0.85).opacity(0.07))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color(red: 0.45, green: 0.2, blue: 0.85), lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }

    private func nearestWeightEntry(to date: Date) -> WeightEntry? {
        let entries = Array(appVM.weightHistory.suffix(10))
        guard !entries.isEmpty else { return nil }
        return entries.min(by: { abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date)) })
    }

    @ViewBuilder
    private var weightChart: some View {
        let entries = Array(appVM.weightHistory.suffix(10))
        let target = appVM.userProfile.targetWeightKg
        let selectedEntry = selectedWeightDate.flatMap { nearestWeightEntry(to: $0) }

        Chart {
            ForEach(entries) { entry in
                LineMark(
                    x: .value("Date", entry.date),
                    y: .value("Weight", entry.weightKg)
                )
                .foregroundStyle(Color.wellnessTeal)
                .lineStyle(.init(lineWidth: 2))

                PointMark(
                    x: .value("Date", entry.date),
                    y: .value("Weight", entry.weightKg)
                )
                .foregroundStyle(Color.wellnessTeal)
                .symbolSize(selectedEntry?.id == entry.id ? 90 : 36)
            }

            if let sel = selectedEntry {
                RuleMark(x: .value("Selected", sel.date))
                    .foregroundStyle(Color.wellnessTeal.opacity(0.3))
                    .lineStyle(.init(lineWidth: 1, dash: [4, 3]))
                    .annotation(position: .top, alignment: .center, spacing: 4) {
                        VStack(spacing: 2) {
                            Text(WeightFormatter.formatWithUnit(sel.weightKg, metric: useMetric))
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.white)
                            Text(sel.date, format: .dateTime.day().month(.abbreviated))
                                .font(.caption2.weight(.medium))
                                .foregroundStyle(.white.opacity(0.85))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.wellnessTeal)
                        .clipShape(.rect(cornerRadius: 8, style: .continuous))
                        .shadow(color: Color.wellnessTeal.opacity(0.35), radius: 4, y: 2)
                    }
            }

            RuleMark(y: .value("Target", target))
                .foregroundStyle(Color.wellnessTeal.opacity(0.5))
                .lineStyle(.init(lineWidth: 1.5, dash: [5, 4]))
                .annotation(position: .trailing, alignment: .trailing) {
                    Text(Lang.s("target"))
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(Color.wellnessTeal)
                }
        }
        .chartXSelection(value: $selectedWeightDate)
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: 5)) { value in
                AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                    .font(.caption2)
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisValueLabel {
                    if let v = value.as(Double.self) {
                        Text(useMetric ? "\(Int(v))kg" : "\(Int(Double(v) * 2.20462))lbs")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                AxisGridLine(stroke: .init(lineWidth: 0.5, dash: [3]))
                    .foregroundStyle(Color(.separator).opacity(0.5))
            }
        }
        .chartYScale(domain: .automatic(includesZero: false))
    }

    private var calorieDetails: some View {
        VStack(spacing: 14) {
            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.up.right")
                        .foregroundStyle(.red)
                        .font(.subheadline.weight(.semibold))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(Lang.s("calories_consumed"))
                            .font(.subheadline.weight(.medium))
                        Button {
                            newCalorieTarget = "\(Int(appVM.userProfile.dailyCalorieTarget))"
                            showEditCalorieTarget = true
                        } label: {
                            (Text(Lang.s("calorie_target_colon"))
                                .foregroundStyle(.secondary)
                            + Text("\(Int(appVM.userProfile.dailyCalorieTarget)) kcal")
                                .foregroundStyle(.red)
                                .fontWeight(.bold))
                            .font(.caption)
                        }
                        .buttonStyle(.plain)
                    }
                }
                Spacer()
                Text("\(appVM.todayPlannedCalories) kcal")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(.red)
            }
            MealProgressBar(
                meals: appVM.todayDayPlan?.meals ?? [],
                completedMealIds: appVM.todayLog.completedMealIds,
                totalScale: appVM.totalCaloriesBurned
            )

            HStack {
                HStack(spacing: 8) {
                    Image(systemName: "flame.fill")
                        .foregroundStyle(Color.wellnessTeal)
                        .font(.subheadline)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(Lang.s("calories_burned"))
                            .font(.subheadline.weight(.medium))
                        if appVM.healthSurplus > 0 {
                            HStack(spacing: 10) {
                                Button {
                                    newBMR = "\(Int(appVM.effectiveBMR))"
                                    showEditBMR = true
                                } label: {
                                    VStack(alignment: .leading, spacing: 1) {
                                        Text("BMR:")
                                            .foregroundStyle(.secondary)
                                        Text("\(Int(appVM.effectiveBMR)) kcal")
                                            .foregroundStyle(Color(red: 0, green: 131/255, blue: 137/255))
                                            .fontWeight(.bold)
                                    }
                                    .font(.caption)
                                }
                                .buttonStyle(.plain)
                                Button {
                                    showEditNEAT = true
                                } label: {
                                    VStack(alignment: .leading, spacing: 1) {
                                        Text("NEAT:")
                                            .foregroundStyle(.secondary)
                                        Text("\(Int(appVM.effectiveTDEE - appVM.effectiveBMR)) kcal")
                                            .foregroundStyle(.green)
                                            .fontWeight(.bold)
                                    }
                                    .font(.caption)
                                }
                                .buttonStyle(.plain)
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(Lang.s("move_label").trimmingCharacters(in: .whitespaces))
                                        .foregroundStyle(.secondary)
                                    Text("+\(Int(appVM.healthSurplus)) kcal")
                                        .foregroundStyle(Color(red: 0.45, green: 0.92, blue: 0.18))
                                        .fontWeight(.bold)
                                }
                                .font(.caption)
                            }
                        } else {
                            HStack(spacing: 6) {
                                Button {
                                    newBMR = "\(Int(appVM.effectiveBMR))"
                                    showEditBMR = true
                                } label: {
                                    (Text("BMR: ")
                                        .foregroundStyle(.secondary)
                                    + Text("\(Int(appVM.effectiveBMR)) kcal")
                                        .foregroundStyle(Color(red: 0, green: 131/255, blue: 137/255))
                                        .fontWeight(.bold))
                                    .font(.caption)
                                }
                                .buttonStyle(.plain)
                                Button {
                                    showEditNEAT = true
                                } label: {
                                    (Text("NEAT: ")
                                        .foregroundStyle(.secondary)
                                    + Text("\(Int(appVM.effectiveTDEE - appVM.effectiveBMR)) kcal")
                                        .foregroundStyle(.green)
                                        .fontWeight(.bold))
                                    .font(.caption)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                Spacer()
                Text("\(Int(appVM.totalCaloriesBurned)) kcal")
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color.wellnessTeal)
            }
            DualNutrientBar(
                bmr: appVM.effectiveBMR,
                neat: appVM.effectiveTDEE - appVM.effectiveBMR,
                extra: appVM.healthSurplus,
                bmrColor: Color(red: 0, green: 131/255, blue: 137/255),
                neatColor: Color(red: 0.2, green: 0.82, blue: 0.35)
            )
        }
    }

    private var macroAndMealsCard: some View {
        VStack(spacing: 0) {
            VStack(spacing: 20) {
                HStack(spacing: 0) {
                    Spacer()
                    MacroCircle(
                        value: appVM.todayDayPlan.map { plan in
                            plan.meals.filter { appVM.todayLog.completedMealIds.contains($0.id) }.reduce(0.0) { $0 + $1.protein }
                        } ?? 0,
                        unit: "g",
                        label: Lang.s("protein"),
                        color: .red
                    )
                    Spacer()
                    MacroCircle(
                        value: appVM.todayDayPlan.map { plan in
                            plan.meals.filter { appVM.todayLog.completedMealIds.contains($0.id) }.reduce(0.0) { $0 + $1.carbs }
                        } ?? 0,
                        unit: "g",
                        label: Lang.s("carbs"),
                        color: .blue
                    )
                    Spacer()
                    MacroCircle(
                        value: appVM.todayDayPlan.map { plan in
                            plan.meals.filter { appVM.todayLog.completedMealIds.contains($0.id) }.reduce(0.0) { $0 + $1.fat }
                        } ?? 0,
                        unit: "g",
                        label: Lang.s("fat"),
                        color: .orange
                    )
                    Spacer()
                }

                if let dayPlan = appVM.todayDayPlan {
                    VStack(spacing: 10) {
                        ForEach(dayPlan.meals) { meal in
                            HomeMealRow(
                                meal: meal,
                                isCompleted: appVM.todayLog.completedMealIds.contains(meal.id),
                                scannedImageData: appVM.mealScannedImages[meal.id.uuidString],
                                onTap: {
                                    selectedHomeMeal = meal
                                },
                                onToggle: {
                                    withAnimation(.spring(response: 0.3)) {
                                        appVM.toggleMealCompletion(mealId: meal.id)
                                    }
                                },
                                onCamera: {
                                    mealForPhotoScan = meal
                                }
                            )
                        }
                    }
                } else {
                    ContentUnavailableView(
                        Lang.s("no_plan_today"),
                        systemImage: "fork.knife",
                        description: Text(Lang.s("generate_nutrition_plan"))
                    )
                    .frame(height: 120)
                }
            }
            .padding(20)
        }
        .background(.white.opacity(0.80))
        .clipShape(.rect(cornerRadius: 28, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 16, y: 4)
        .padding(.horizontal, 16)
    }

    private var editNEATSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    VStack(spacing: 6) {
                        Text(Lang.s("activity_level"))
                            .font(.title2.bold())
                        Text(Lang.s("select_lifestyle_neat"))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 24)

                    VStack(spacing: 10) {
                        ForEach(UserProfile.ActivityLevel.allCases, id: \.self) { level in
                            let isSelected = appVM.userProfile.activityLevel == level
                            let neat = Int(appVM.effectiveBMR * (level.multiplier - 1.0))
                            let tdee = Int(appVM.effectiveBMR * level.multiplier)
                            Button {
                                appVM.userProfile.activityLevel = level
                                appVM.saveCurrentProfile()
                                showEditNEAT = false
                            } label: {
                                HStack(spacing: 14) {
                                    Image(systemName: level.icon)
                                        .font(.title3)
                                        .foregroundStyle(isSelected ? .white : .green)
                                        .frame(width: 32)
                                    VStack(alignment: .leading, spacing: 3) {
                                        Text(Lang.s("activity_\(level.langKey)"))
                                            .font(.subheadline.weight(.semibold))
                                            .foregroundStyle(isSelected ? .white : .primary)
                                        Text(Lang.s("activity_\(level.langKey)_desc"))
                                            .font(.caption)
                                            .foregroundStyle(isSelected ? .white.opacity(0.75) : .secondary)
                                    }
                                    Spacer()
                                    VStack(alignment: .trailing, spacing: 2) {
                                        Text("+\(neat) kcal")
                                            .font(.caption.weight(.bold))
                                            .foregroundStyle(isSelected ? .white : .green)
                                        Text("TDEE: \(tdee)")
                                            .font(.caption2)
                                            .foregroundStyle(isSelected ? .white.opacity(0.7) : .secondary)
                                    }
                                    if isSelected {
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundStyle(.white)
                                            .font(.title3)
                                            .padding(.leading, 4)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 14)
                                .background(isSelected ? Color.green : Color(.secondarySystemBackground))
                                .clipShape(.rect(cornerRadius: 14))
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(Lang.s("cancel")) { showEditNEAT = false }
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    private var editBMRSheet: some View {
        NavigationStack {
            VStack(spacing: 32) {
                VStack(spacing: 8) {
                    Text("BMR")
                        .font(.title2.bold())
                    Text(Lang.s("bmr_subtitle"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 8)

                HStack(alignment: .lastTextBaseline, spacing: 6) {
                    TextField("0", text: $newBMR)
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .foregroundStyle(Color(red: 0/255, green: 131/255, blue: 137/255))
                        .multilineTextAlignment(.center)
                        .keyboardType(.numberPad)
                        .frame(width: 180)
                    Text("kcal")
                        .font(.title)
                        .foregroundStyle(.secondary)
                }

                Button {
                    if let kcal = Double(newBMR), kcal > 0 {
                        appVM.userProfile.customBMR = kcal
                        appVM.saveCurrentProfile()
                        showEditBMR = false
                    }
                } label: {
                    Text(Lang.s("save"))
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color(red: 0/255, green: 131/255, blue: 137/255))
                        .foregroundStyle(.white)
                        .clipShape(.rect(cornerRadius: 16))
                }
                .padding(.horizontal, 32)
                .disabled(newBMR.isEmpty)
                .opacity(newBMR.isEmpty ? 0.5 : 1)

                Spacer()
            }
            .padding(.top, 24)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(Lang.s("cancel")) { showEditBMR = false }
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }

    private var bodyFatSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    VStack(spacing: 6) {
                        Image(systemName: "figure.arms.open")
                            .font(.system(size: 36))
                            .foregroundStyle(Color.wellnessTeal)
                        Text(Lang.s("update_body_fat"))
                            .font(.title2.bold())
                        Text(Lang.s("body_fat_instruction"))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 8)

                    if let bf = appVM.userProfile.bodyFatPercentage {
                        HStack(spacing: 4) {
                            Text(String(format: "%.1f%%", bf))
                                .font(.system(size: 40, weight: .bold, design: .rounded))
                                .foregroundStyle(Color.wellnessTeal)
                            Text(Lang.s("body_fat"))
                                .font(.title3)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }

                    VStack(spacing: 12) {
                        measurementField(title: Lang.s("neck_circumference"), text: $bfNeck, icon: "circle.dashed")
                        measurementField(title: Lang.s("waist_circumference"), text: $bfWaist, icon: "oval.portrait.tophalf.filled")
                        if appVM.userProfile.gender != .male {
                            measurementField(title: Lang.s("hip_circumference"), text: $bfHip, icon: "oval.portrait")
                        }
                    }
                    .padding(.horizontal, 20)

                    HStack(spacing: 12) {
                        Button {
                            showBodyFatSheet = false
                        } label: {
                            Text(Lang.s("cancel"))
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(Color(.secondarySystemBackground))
                                .foregroundStyle(.primary)
                                .clipShape(.capsule)
                        }
                        .buttonStyle(.plain)

                        Button {
                            let neck = Double(bfNeck.replacingOccurrences(of: ",", with: "."))
                            let waist = Double(bfWaist.replacingOccurrences(of: ",", with: "."))
                            let hip = Double(bfHip.replacingOccurrences(of: ",", with: "."))
                            if let n = neck, let w = waist, n > 0, w > 0 {
                                appVM.userProfile.neckCircumferenceCm = n
                                appVM.userProfile.waistCircumferenceCm = w
                                if appVM.userProfile.gender != .male {
                                    appVM.userProfile.hipCircumferenceCm = hip
                                }
                                appVM.saveCurrentProfile()
                                showBodyFatSheet = false
                            }
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "checkmark")
                                Text(Lang.s("calculate"))
                            }
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .frame(height: 52)
                            .background(Color.wellnessTeal)
                            .foregroundStyle(.white)
                            .clipShape(.capsule)
                        }
                        .buttonStyle(.plain)
                        .disabled(bfNeck.isEmpty || bfWaist.isEmpty)
                        .opacity((bfNeck.isEmpty || bfWaist.isEmpty) ? 0.5 : 1)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(Lang.s("cancel")) { showBodyFatSheet = false }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
        .presentationContentInteraction(.scrolls)
    }

    private func measurementField(title: String, text: Binding<String>, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(Color.wellnessTeal)
                Text(title)
                    .font(.subheadline.weight(.semibold))
            }
            TextField("0.0", text: text)
                .keyboardType(.decimalPad)
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color(.secondarySystemBackground))
                .clipShape(.rect(cornerRadius: 12))
                .font(.body)
        }
        .padding(14)
        .background(Color(.systemBackground))
        .clipShape(.rect(cornerRadius: 14))
        .shadow(color: .black.opacity(0.04), radius: 4, y: 2)
    }

    private var editCalorieTargetSheet: some View {
        NavigationStack {
            VStack(spacing: 32) {
                VStack(spacing: 8) {
                    Text(Lang.s("calorie_target"))
                        .font(.title2.bold())
                    Text(Lang.s("set_daily_calorie_goal"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 8)

                HStack(alignment: .lastTextBaseline, spacing: 6) {
                    TextField("0", text: $newCalorieTarget)
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .keyboardType(.numberPad)
                        .frame(width: 180)
                    Text("kcal")
                        .font(.title)
                        .foregroundStyle(.secondary)
                }

                Button {
                    if let kcal = Double(newCalorieTarget), kcal > 0 {
                        appVM.userProfile.customCalorieTarget = kcal
                        appVM.saveCurrentProfile()
                        showEditCalorieTarget = false
                    }
                } label: {
                    Text(Lang.s("save"))
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color.red)
                        .foregroundStyle(.white)
                        .clipShape(.rect(cornerRadius: 16))
                }
                .padding(.horizontal, 32)
                .disabled(newCalorieTarget.isEmpty)
                .opacity(newCalorieTarget.isEmpty ? 0.5 : 1)

                Spacer()
            }
            .padding(.top, 24)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(Lang.s("cancel")) { showEditCalorieTarget = false }
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }

    private var addWeightSheet: some View {
        NavigationStack {
            VStack(spacing: 32) {
                VStack(spacing: 8) {
                    Text(Lang.s("log_todays_weight"))
                        .font(.title2.bold())
                    Text(Lang.s("keep_track_progress"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 8)

                HStack(alignment: .lastTextBaseline, spacing: 6) {
                    TextField("0.0", text: $newWeight)
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.wellnessTeal)
                        .multilineTextAlignment(.center)
                        .keyboardType(.decimalPad)
                        .frame(width: 160)
                    Text(useMetric ? "kg" : "lbs")
                        .font(.title)
                        .foregroundStyle(.secondary)
                }

                Button {
                    if let value = Double(newWeight.replacingOccurrences(of: ",", with: ".")) {
                        let kg = WeightFormatter.toKg(value, metric: useMetric)
                        appVM.addWeightEntry(kg)
                        showAddWeight = false
                    }
                } label: {
                    Text(Lang.s("save"))
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color.wellnessTeal)
                        .foregroundStyle(.white)
                        .clipShape(.rect(cornerRadius: 16))
                }
                .padding(.horizontal, 32)
                .disabled(newWeight.isEmpty)
                .opacity(newWeight.isEmpty ? 0.5 : 1)

                Spacer()
            }
            .padding(.top, 24)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(Lang.s("cancel")) { showAddWeight = false }
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}

private struct HomeMealRow: View {
    let meal: Meal
    let isCompleted: Bool
    let scannedImageData: Data?
    let onTap: () -> Void
    let onToggle: () -> Void
    let onCamera: () -> Void

    var body: some View {
        Button(action: onTap) {
        HStack(spacing: 12) {
            if meal.isCheatMeal {
                ZStack {
                    LinearGradient(colors: [.orange.opacity(0.15), .pink.opacity(0.15)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    Text("🎉")
                        .font(.title2)
                }
                .frame(width: 58, height: 58)
                .clipShape(.rect(cornerRadius: 12))
            } else {
                Color(.secondarySystemBackground)
                    .frame(width: 58, height: 58)
                    .overlay {
                        if let data = scannedImageData, let uiImage = UIImage(data: data) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .allowsHitTesting(false)
                        } else {
                            AsyncImage(url: URL(string: meal.imageURL ?? "")) { phase in
                                if let image = phase.image {
                                    image.resizable().aspectRatio(contentMode: .fill).allowsHitTesting(false)
                                } else {
                                    Image(systemName: "fork.knife").foregroundStyle(.tertiary)
                                }
                            }
                        }
                    }
                    .clipShape(.rect(cornerRadius: 12))
            }

            VStack(alignment: .leading, spacing: 3) {
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
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                } else {
                    Text(meal.name)
                        .font(.subheadline.weight(.medium))
                        .lineLimit(1)
                }
            }

            Spacer()

            if !meal.isCheatMeal {
                Text("\(meal.calories)")
                    .font(.headline.weight(.bold))
                Text("kcal")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Button(action: onCamera) {
                    Image(systemName: "camera.fill")
                        .font(.subheadline)
                        .foregroundStyle(Color.wellnessTeal)
                        .frame(width: 34, height: 34)
                        .background(Color.wellnessTeal.opacity(0.10))
                        .clipShape(.rect(cornerRadius: 8))
                }
                .buttonStyle(.plain)
            }

            Button(action: onToggle) {
                Image(systemName: isCompleted ? "checkmark.square.fill" : "square")
                    .font(.title3)
                    .foregroundStyle(isCompleted ? Color.wellnessTeal : Color(.tertiaryLabel))
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(
            meal.isCheatMeal
                ? AnyShapeStyle(LinearGradient(colors: [.orange.opacity(0.05), .pink.opacity(0.05)], startPoint: .leading, endPoint: .trailing))
                : AnyShapeStyle(isCompleted ? Color.wellnessTeal.opacity(0.05) : Color(.secondarySystemBackground))
        )
        .clipShape(.rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    meal.isCheatMeal
                        ? AnyShapeStyle(LinearGradient(colors: [.orange.opacity(0.3), .pink.opacity(0.3)], startPoint: .leading, endPoint: .trailing))
                        : AnyShapeStyle(isCompleted ? Color.wellnessTeal.opacity(0.3) : Color.clear),
                    lineWidth: 1
                )
        )
        }
        .buttonStyle(.plain)
    }
}
