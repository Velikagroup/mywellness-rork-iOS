import SwiftUI

struct DayDetailView: View {
    @Environment(AppViewModel.self) private var appVM
    @Environment(\.dismiss) private var dismiss
    @AppStorage("useMetricUnits") private var useMetric: Bool = true
    let date: Date

    private let calendar = Calendar.current

    private var isToday: Bool { calendar.isDateInToday(date) }
    private var isFuture: Bool { date > Date() && !isToday }
    private var snapshot: DaySnapshot? { isToday ? nil : appVM.snapshot(for: date) }
    private var hasData: Bool { isToday || snapshot != nil }

    private var mood: WellnessMood {
        if isToday { return appVM.wellnessMood }
        guard let s = snapshot else { return .fair }
        return WellnessMood.from(score: s.wellnessScore)
    }

    private var wellnessScore: Double {
        if isToday { return appVM.wellnessScore }
        return snapshot?.wellnessScore ?? 0.5
    }

    private var caloriesConsumed: Int {
        if isToday { return appVM.todayCaloriesConsumed }
        return snapshot?.caloriesConsumed ?? 0
    }

    private var caloriesBurned: Int {
        if isToday { return Int(appVM.totalCaloriesBurned) }
        return snapshot?.caloriesBurned ?? 0
    }

    private var calorieBalance: Int { caloriesConsumed - caloriesBurned }

    private var proteinConsumed: Double {
        if isToday {
            return appVM.todayDayPlan.map { plan in
                plan.meals.filter { appVM.todayLog.completedMealIds.contains($0.id) }
                    .reduce(0.0) { $0 + $1.protein }
            } ?? 0
        }
        return snapshot?.proteinConsumed ?? 0
    }

    private var carbsConsumed: Double {
        if isToday {
            return appVM.todayDayPlan.map { plan in
                plan.meals.filter { appVM.todayLog.completedMealIds.contains($0.id) }
                    .reduce(0.0) { $0 + $1.carbs }
            } ?? 0
        }
        return snapshot?.carbsConsumed ?? 0
    }

    private var fatConsumed: Double {
        if isToday {
            return appVM.todayDayPlan.map { plan in
                plan.meals.filter { appVM.todayLog.completedMealIds.contains($0.id) }
                    .reduce(0.0) { $0 + $1.fat }
            } ?? 0
        }
        return snapshot?.fatConsumed ?? 0
    }

    private var completedMealCount: Int {
        if isToday { return appVM.todayLog.completedMealIds.count }
        return snapshot?.completedMealCount ?? 0
    }

    private var totalMealCount: Int {
        if isToday { return appVM.todayDayPlan?.meals.count ?? 0 }
        return snapshot?.totalMealCount ?? 0
    }

    private var weightKg: Double? {
        if isToday { return appVM.weightHistory.last?.weightKg }
        return snapshot?.weightKg
    }

    private var balanceColor: Color {
        if calorieBalance < -300 { return Color(red: 0.17, green: 0.60, blue: 0.52) }
        if calorieBalance < 100 { return .blue }
        return .orange
    }

    private var balanceLabel: String {
        if calorieBalance < -700 { return Lang.s("strong_deficit") }
        if calorieBalance < -300 { return Lang.s("moderate_deficit") }
        if calorieBalance < 100 { return Lang.s("on_target") }
        if calorieBalance < 400 { return Lang.s("moderate_surplus") }
        return Lang.s("strong_surplus")
    }

    private var dateTitle: String {
        if isToday { return Lang.s("today") }
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE d MMMM"
        let langCode = Lang.current
        formatter.locale = Locale(identifier: langCode)
        return formatter.string(from: date).capitalized
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if isFuture {
                        futureView
                    } else if !hasData {
                        noDataView
                    } else {
                        dataContent
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 40)
            }
            .navigationTitle(dateTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(Lang.s("close")) { dismiss() }
                }
            }
        }
    }

    private var dataContent: some View {
        VStack(spacing: 20) {
            memojiHeroSection
            calorieSection
            macroSection
            mealsSection
            if let w = weightKg {
                weightSection(w)
            }
        }
    }

    private var memojiHeroSection: some View {
        VStack(spacing: 10) {
            ZStack {
                WellnessAuraView(mood: mood)
                    .frame(width: 180, height: 180)

                ZStack {
                    Circle()
                        .fill(mood.color.opacity(0.13))
                        .frame(width: 100, height: 100)

                    if let uiImage = appVM.memojiUIImage(for: mood) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 114, height: 114)
                            .clipShape(.circle)
                    } else {
                        Text(mood.emoji)
                            .font(.system(size: 68))
                    }

                    Circle()
                        .fill(mood.color)
                        .frame(width: 28, height: 28)
                        .overlay(
                            Image(systemName: "heart.fill")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(.white)
                        )
                        .shadow(color: .black.opacity(0.15), radius: 4, y: 2)
                        .offset(x: 34, y: 34)
                }
            }

            Text(mood.moodLabel)
                .font(.title2.bold())

            HStack(spacing: 6) {
                Circle()
                    .fill(mood.color)
                    .frame(width: 8, height: 8)
                Text(mood.shortLabel)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(mood.color)
                Text("·")
                    .foregroundStyle(.secondary)
                Text(String(format: "%@ %.0f%%", Lang.s("score"), wellnessScore * 100))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.top, 8)
    }

    private var calorieSection: some View {
        VStack(spacing: 14) {
            HStack {
                Text(Lang.s("calories_label"))
                    .font(.headline.bold())
                Spacer()
                Text(balanceLabel)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(balanceColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(balanceColor.opacity(0.12))
                    .clipShape(.capsule)
            }

            HStack(spacing: 12) {
                calorieStatBox(
                    value: caloriesConsumed,
                    label: Lang.s("consumed"),
                    icon: "fork.knife",
                    color: .red
                )
                calorieStatBox(
                    value: caloriesBurned,
                    label: Lang.s("burned"),
                    icon: "flame.fill",
                    color: Color.wellnessTeal
                )
                calorieStatBox(
                    value: abs(calorieBalance),
                    label: calorieBalance < 0 ? Lang.s("deficit") : Lang.s("surplus"),
                    icon: calorieBalance < 0 ? "arrow.down.circle.fill" : "arrow.up.circle.fill",
                    color: balanceColor
                )
            }
        }
        .padding(18)
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: 20, style: .continuous))
    }

    private func calorieStatBox(value: Int, label: String, icon: String, color: Color) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            Text("\(value)")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundStyle(color)
                .contentTransition(.numericText())
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(color.opacity(0.08))
        .clipShape(.rect(cornerRadius: 14, style: .continuous))
    }

    private var macroSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(Lang.s("macronutrients"))
                .font(.headline.bold())

            HStack(spacing: 10) {
                macroBox(value: proteinConsumed, label: Lang.s("protein"), color: .red, icon: "p.circle.fill")
                macroBox(value: carbsConsumed, label: Lang.s("carbs"), color: .blue, icon: "c.circle.fill")
                macroBox(value: fatConsumed, label: Lang.s("fat"), color: .orange, icon: "f.circle.fill")
            }
        }
        .padding(18)
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: 20, style: .continuous))
    }

    private func macroBox(value: Double, label: String, color: Color, icon: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            Text(String(format: "%.0fg", value))
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(.primary)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(color.opacity(0.08))
        .clipShape(.rect(cornerRadius: 14, style: .continuous))
    }

    private var mealsSection: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(Lang.s("meals_completed"))
                    .font(.headline.bold())
                Text("\(completedMealCount) \(Lang.s("of_meals")) \(totalMealCount) \(Lang.s("meals"))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            ZStack {
                Circle()
                    .stroke(Color(.tertiarySystemFill), lineWidth: 5)
                    .frame(width: 52, height: 52)
                Circle()
                    .trim(from: 0, to: totalMealCount > 0 ? CGFloat(completedMealCount) / CGFloat(totalMealCount) : 0)
                    .stroke(Color.wellnessTeal, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .frame(width: 52, height: 52)
                    .rotationEffect(.degrees(-90))
                Text("\(totalMealCount > 0 ? Int(Double(completedMealCount) / Double(totalMealCount) * 100) : 0)%")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.wellnessTeal)
            }
        }
        .padding(18)
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: 20, style: .continuous))
    }

    private func weightSection(_ kg: Double) -> some View {
        HStack(spacing: 16) {
            Image(systemName: "scalemass.fill")
                .font(.title2)
                .foregroundStyle(Color.wellnessTeal)
            VStack(alignment: .leading, spacing: 4) {
                Text(Lang.s("recorded_weight"))
                    .font(.subheadline.weight(.semibold))
                Text(WeightFormatter.formatWithUnit(kg, metric: useMetric))
                    .font(.title3.bold())
                    .foregroundStyle(Color.wellnessTeal)
            }
            Spacer()
        }
        .padding(18)
        .background(Color(.secondarySystemBackground))
        .clipShape(.rect(cornerRadius: 20, style: .continuous))
    }

    private var futureView: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 52))
                .foregroundStyle(Color.secondary.opacity(0.4))
            Text(Lang.s("future_day"))
                .font(.title3.bold())
            Text(Lang.s("future_day_msg"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }

    private var noDataView: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar.xaxis")
                .font(.system(size: 52))
                .foregroundStyle(Color.secondary.opacity(0.4))
            Text(Lang.s("no_data"))
                .font(.title3.bold())
            Text(Lang.s("no_data_msg"))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}
