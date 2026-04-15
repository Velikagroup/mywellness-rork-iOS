import SwiftUI
import AuthenticationServices
import RevenueCat
import UserNotifications

// MARK: - Color constants
private extension Color {
    static let quizNavy = Color.black
    static let quizTeal = Color(red: 0.20, green: 0.70, blue: 0.65)
    static let quizCard = Color(red: 0.94, green: 0.94, blue: 0.96)
    static let paywallOrange = Color(red: 1.0, green: 0.45, blue: 0.0)
}

// MARK: - Main View
struct OnboardingView: View {
    var onDismiss: () -> Void = {}

    @Environment(AppViewModel.self) private var appVM
    @Environment(StoreViewModel.self) private var storeVM
    @AppStorage("appLanguage") private var appLanguage: String = "en"

    // Navigation
    @State private var step: Int = 0
    private let totalSteps = 23

    // Step 0 - Gender
    @State private var selectedGender: String = ""

    // Step 1 - Date of Birth
    @State private var birthMonth: Int = 1
    @State private var birthDay: Int = 1
    @State private var birthYear: Int = 2016

    // Step 2 - Referral Source
    @State private var referralSource: String = ""

    // Step 3 - Height & Weight
    @State private var isMetric: Bool = true
    @State private var heightCm: Double = 165
    @State private var weightKg: Double = 65

    // Step 3 - Target Weight
    @State private var targetWeightKg: Double = 60

    // Step 5 - Speed
    @State private var speedValue: Double = 0.65
    @State private var customCalorieOverride: Int?
    @State private var isEditingCalories: Bool = false
    @State private var calorieEditText: String = ""

    // Step 6 - Comparison animation
    @State private var comparisonAnimate: Bool = false

    // Step 7 - Current Body Type
    @State private var currentBodyType: Int = -1

    // Step 8 - Areas to improve
    @State private var areasToImprove: Set<String> = []

    // Step 9 - Target Body Type
    @State private var targetBodyType: Int = -1

    // Step 10 - Obstacles
    @State private var obstacles: Set<String> = []

    // Step 11 - Diet
    @State private var selectedDiet: String = ""

    // Step 12 - Achievements
    @State private var achievements: Set<String> = []

    // Step 7 - Activity Level
    @State private var selectedActivityLevel: UserProfile.ActivityLevel = .moderate

    // Step 15 - Referral
    @State private var referralCode: String = ""

    // Step 17 - Loading
    @State private var loadingProgress: Double = 0
    @State private var loadingChecked: [Bool] = [false, false, false, false]

    // Step 18 - Auth
    @State private var isAuthLoading: Bool = false

    // Step 19 - Paywall
    @State private var paywallPage: Int = 0
    @State private var selectedPlan: String = "yearly"
    @State private var trialDotsAnimated: [Bool] = [false, false, false]
    @State private var paywallBellAnimate: Bool = false

    // Restore
    @State private var isRestoring: Bool = false
    @State private var showRestoreNoSubAlert: Bool = false

    // Computed
    private var weightDiff: Double { weightKg - targetWeightKg }
    private var weeklySpeed: Double { speedValue }
    private var weeksToGoal: Int { weightDiff > 0 ? max(1, Int(ceil(abs(weightDiff) / weeklySpeed))) : 0 }
    private var monthsToGoal: Int { max(1, Int(ceil(Double(weeksToGoal) / 4.33))) }
    private var calculatedCalories: Int {
        let age = max(10, ageFromBirth)
        let bmr: Double
        switch selectedGender {
        case "Female":
            bmr = 10 * weightKg + 6.25 * heightCm - 5 * Double(age) - 161
        case "Male":
            bmr = 10 * weightKg + 6.25 * heightCm - 5 * Double(age) + 5
        default:
            bmr = 10 * weightKg + 6.25 * heightCm - 5 * Double(age) - 78
        }
        let tdee = bmr * selectedActivityLevel.multiplier
        let dailyDeficit = weeklySpeed * 7700.0 / 7.0
        let minCalories: Double = selectedGender == "Female" ? 1200 : 1500
        let speedRatio = (speedValue - 0.25) / (1.5 - 0.25)
        let maxDeficitPercent = 0.15 + speedRatio * 0.30
        let maxAllowedDeficit = tdee * maxDeficitPercent
        let effectiveDeficit = min(dailyDeficit, maxAllowedDeficit)
        return Int(max(minCalories, tdee - effectiveDeficit))
    }
    private var dailyCalories: Int {
        customCalorieOverride ?? calculatedCalories
    }
    private var goalDate: String {
        let cal = Calendar.current
        let months = monthsToGoal
        guard months > 0,
              let d = cal.date(byAdding: .month, value: months, to: Date()) else { return "" }
        let fmt = DateFormatter()
        fmt.locale = Locale(identifier: "en_US")
        fmt.dateFormat = "d MMM"
        return fmt.string(from: d)
    }
    private var ageFromBirth: Int {
        let comps = Calendar.current.dateComponents([.year], from: birthDate, to: Date())
        return comps.year ?? 0
    }
    private var birthDate: Date {
        var c = DateComponents()
        c.year = birthYear; c.month = birthMonth; c.day = birthDay
        return Calendar.current.date(from: c) ?? Date()
    }
    private var displayHeight: String {
        if isMetric { return "\(Int(heightCm)) cm" }
        let totalInches = heightCm / 2.54
        let ft = Int(totalInches) / 12
        let inches = Int(totalInches) % 12
        return "\(ft)'\(inches)\""
    }
    private var displayWeight: String {
        if isMetric { return "\(Int(weightKg)) kg" }
        return "\(Int(weightKg * 2.20462)) lbs"
    }
    private var displayTargetWeight: String {
        if isMetric { return String(format: "%.1f kg", targetWeightKg) }
        return String(format: "%.1f lbs", targetWeightKg * 2.20462)
    }

    private var speedAnimalEmoji: String {
        if speedValue < 0.6 { return "🐢" }
        if speedValue < 1.2 { return "🐕" }
        return "🐆"
    }
    private var speedAnimalLabel: String {
        if speedValue < 0.6 { return Lang.s("slow") }
        if speedValue < 1.2 { return Lang.s("recommended") }
        return Lang.s("fast")
    }

    private var canContinue: Bool {
        switch step {
        case 0: return !selectedGender.isEmpty
        case 2: return !referralSource.isEmpty
        case 9: return currentBodyType >= 0
        case 11: return targetBodyType >= 0
        case 13: return !selectedDiet.isEmpty
        case 14: return !achievements.isEmpty
        default: return true
        }
    }

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {
                if step < 19 || step == 20 || step == 21 || step == 22 || step == 23 {
                    headerBar
                }

                if step == 19 {
                    loadingStep
                } else if step == 21 {
                    loginStep
                } else if step == 22 {
                    healthKitStep
                } else if step == 23 {
                    notificationStep
                } else if step == 24 {
                    freeTrialStep
                } else if step == 25 {
                    paywallStep
                } else {
                    ScrollView {
                        stepContent
                            .id(step)
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                            .padding(.bottom, 120)
                    }
                    .scrollIndicators(.hidden)
                }

                if step < 19 || step == 20 {
                    bottomButton
                        .padding(.horizontal, 20)
                        .padding(.bottom, 40)
                }
            }
        }
        .preferredColorScheme(.light)
        .alert(Lang.s("restore"), isPresented: $showRestoreNoSubAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(Lang.s("no_active_subscription"))
        }
    }

    // MARK: - Header
    private var headerBar: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 0) {
                Button {
                    if step == 22 {
                        withAnimation(.easeInOut(duration: 0.25)) { step = 21 }
                    } else if step == 21 {
                        withAnimation(.easeInOut(duration: 0.25)) { step = 20 }
                    } else if step == 20 {
                        withAnimation(.easeInOut(duration: 0.25)) { step = 18 }
                    } else if step == 0 {
                        withAnimation(.easeInOut(duration: 0.4)) { onDismiss() }
                    } else if step > 0 {
                        var prevStep = step - 1
                        if prevStep == 6 && targetWeightKg >= weightKg {
                            prevStep = 5
                        }
                        withAnimation(.easeInOut(duration: 0.25)) { step = prevStep }
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 17, weight: .medium))
                        .foregroundStyle(Color.black)
                        .frame(width: 44, height: 44)
                }

                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color(red: 0.88, green: 0.88, blue: 0.90))
                            .frame(height: 2)
                        Capsule()
                            .fill(Color.black)
                            .frame(width: geo.size.width * min(1, Double(step) / Double(totalSteps - 1)), height: 2)
                            .animation(.easeInOut(duration: 0.3), value: step)
                    }
                }
                .frame(height: 2)

                Button {
                    Task {
                        isRestoring = true
                        await storeVM.restore()
                        isRestoring = false
                        if storeVM.isPremium {
                            appVM.hasCompletedOnboarding = true
                            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                        } else {
                            showRestoreNoSubAlert = true
                        }
                    }
                } label: {
                    if isRestoring {
                        ProgressView()
                            .tint(Color.black.opacity(0.4))
                            .frame(width: 60, alignment: .trailing)
                            .padding(.leading, 8)
                    } else {
                        Text(Lang.s("restore"))
                            .font(.system(size: 15))
                            .foregroundStyle(Color.black.opacity(0.4))
                            .frame(width: 60, alignment: .trailing)
                            .padding(.leading, 8)
                    }
                }
                .disabled(isRestoring)
            }
            .padding(.horizontal, 16)
            .frame(height: 44)
        }
        .padding(.top, 8)
    }

    // MARK: - Bottom Button
    private var bottomButton: some View {
        Button {
            handleContinue()
        } label: {
            Text(step == 17 && referralCode.isEmpty ? Lang.s("skip") : step == 20 ? Lang.s("discover_now") : Lang.s("continue"))
                .font(.system(size: 17, weight: .semibold))
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(canContinue ? Color.black : Color(red: 0.82, green: 0.82, blue: 0.85))
                .foregroundStyle(.white)
                .clipShape(.rect(cornerRadius: 28))
        }
        .disabled(!canContinue)
        .animation(.easeInOut(duration: 0.2), value: canContinue)
    }

    private func handleContinue() {
        if step == 18 {
            withAnimation { step = 19 }
            startLoading()
            return
        }
        var nextStep = step + 1
        if nextStep == 6 && targetWeightKg >= weightKg {
            nextStep = 7
        }
        withAnimation(.easeInOut(duration: 0.25)) { step = nextStep }
    }

    private func startLoading() {
        loadingProgress = 0
        loadingChecked = [false, false, false, false]
        Task {
            for i in 0..<20 {
                try? await Task.sleep(for: .milliseconds(150))
                await MainActor.run { loadingProgress = Double(i + 1) / 20.0 }
                if i == 5 { await MainActor.run { loadingChecked[0] = true } }
                if i == 10 { await MainActor.run { loadingChecked[1] = true } }
                if i == 14 { await MainActor.run { loadingChecked[2] = true } }
                if i == 18 { await MainActor.run { loadingChecked[3] = true } }
            }
            try? await Task.sleep(for: .milliseconds(400))
            await MainActor.run {
                buildAndSaveProfile()
                withAnimation { step = 20 }
            }

        }
    }

    private func buildAndSaveProfile() {
        var profile = UserProfile()
        profile.gender = UserProfile.Gender(rawValue: selectedGender) ?? .male
        profile.dateOfBirth = birthDate
        profile.age = ageFromBirth
        profile.isMetric = isMetric
        profile.heightCm = heightCm
        profile.currentWeightKg = weightKg
        profile.targetWeightKg = targetWeightKg
        profile.weightLossSpeedKgPerWeek = weeklySpeed
        profile.currentBodyTypeIndex = currentBodyType
        profile.targetBodyTypeIndex = targetBodyType
        profile.areasToImprove = Array(areasToImprove)
        profile.obstacles = Array(obstacles)
        profile.achievements = Array(achievements)
        profile.dietType = UserProfile.DietType(rawValue: selectedDiet) ?? .standard
        profile.referralCode = referralCode
        profile.activityLevel = selectedActivityLevel
        profile.goal = weightDiff > 0 ? .loseWeight : (weightDiff < 0 ? .gainMuscle : .maintain)
        if let custom = customCalorieOverride {
            profile.customCalorieTarget = Double(custom)
        }
        appVM.prepareProfile(profile)
    }

    // MARK: - Step Content Router
    @ViewBuilder
    private var stepContent: some View {
        switch step {
        case 0: genderStep
        case 1: dobStep
        case 2: referralSourceStep
        case 3: heightWeightStep
        case 4: targetWeightStep
        case 5: realisticGoalStep
        case 6: speedStep
        case 7: doubleWeightStep
        case 8: activityLevelStep
        case 9: currentBodyTypeStep
        case 10: areasStep
        case 11: targetBodyTypeStep
        case 12: obstaclesStep
        case 13: dietStep
        case 14: achievementsStep
        case 15: weightChartStep
        case 16: thankYouStep
        case 17: referralStep
        case 18: readyStep
        case 20: planReadyStep
        default: genderStep
        }
    }

    // MARK: - Step 0: Gender
    private var genderStep: some View {
        VStack(alignment: .leading, spacing: 32) {
            quizHeader(title: Lang.s("select_gender"), subtitle: Lang.s("calibrate_plan"))

            VStack(spacing: 12) {
                ForEach([Lang.s("male"), Lang.s("female"), Lang.s("other")], id: \.self) { g in
                    genderOption(g)
                }
            }
            .padding(.horizontal, 20)
        }
        .padding(.top, 24)
    }

    private func genderOption(_ g: String) -> some View {
        let isSelected = selectedGender == g
        return Button {
            selectedGender = g
        } label: {
            Text(g)
                .font(.system(size: 17, weight: .medium))
                .foregroundStyle(isSelected ? Color.white : Color.black)
                .frame(maxWidth: .infinity)
                .frame(height: 62)
                .background(isSelected ? Color.black : Color.quizCard)
                .clipShape(.rect(cornerRadius: 16))
        }
        .buttonStyle(.plain)
        .conditionalSensoryFeedback(.selection, trigger: selectedGender)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }

    // MARK: - Step 1: Date of Birth
    private var dobStep: some View {
        VStack(alignment: .leading, spacing: 32) {
            quizHeader(
                title: Lang.s("when_born"),
                subtitle: Lang.s("metabolic_rate_calc")
            )

            HStack(spacing: 0) {
                Picker("Day", selection: $birthDay) {
                    ForEach(1...31, id: \.self) { d in
                        Text("\(d)")
                            .foregroundStyle(Color.black)
                            .tag(d)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)

                Picker("Month", selection: $birthMonth) {
                    ForEach(1...12, id: \.self) { m in
                        Text(monthName(m))
                            .foregroundStyle(Color.black)
                            .tag(m)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)

                Picker("Year", selection: $birthYear) {
                    let maxYear = Calendar.current.component(.year, from: Date()) - 10
                    ForEach(Array(stride(from: maxYear, through: 1930, by: -1)), id: \.self) { y in
                        Text(verbatim: String(y))
                            .foregroundStyle(Color.black)
                            .tag(y)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: .infinity)
            }
            .frame(height: 300)
            .padding(.horizontal, 20)

            Text("\(ageFromBirth) \(Lang.s("years_old"))")
                .font(.system(size: 15))
                .foregroundStyle(Color(red: 0.5, green: 0.5, blue: 0.55))
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.top, 24)
    }

    private func monthName(_ m: Int) -> String {
        return Lang.s("month_\(m)")
    }

    private func daysInMonth(_ m: Int, year: Int) -> Int {
        let cal = Calendar.current
        var c = DateComponents(); c.year = year; c.month = m
        guard let date = cal.date(from: c),
              let range = cal.range(of: .day, in: .month, for: date) else { return 30 }
        return range.count
    }

    // MARK: - Step 2: Height & Weight
    private var heightWeightStep: some View {
        VStack(alignment: .leading, spacing: 28) {
            quizHeader(title: Lang.s("height_weight"), subtitle: Lang.s("calibrate_plan"))

            HStack {
                Spacer()
                Text(Lang.s("imperial"))
                    .font(.system(size: 15))
                    .foregroundStyle(isMetric ? Color(red: 0.55, green: 0.55, blue: 0.6) : Color.black)
                Toggle("", isOn: $isMetric)
                    .toggleStyle(SwitchToggleStyle(tint: Color.black))
                    .labelsHidden()
                    .frame(width: 52)
                Text(Lang.s("metric"))
                    .font(.system(size: 15))
                    .foregroundStyle(isMetric ? Color.black : Color(red: 0.55, green: 0.55, blue: 0.6))
                Spacer()
            }

            ZStack {
                if isMetric {
                    HStack(spacing: 0) {
                        VStack(spacing: 2) {
                            Text(Lang.s("height"))
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(Color(red: 0.5, green: 0.5, blue: 0.55))
                                .kerning(1)
                            Picker("Height", selection: Binding(
                                get: { Int(heightCm) },
                                set: { heightCm = Double($0) }
                            )) {
                                ForEach(140...220, id: \.self) { v in
                                    Text("\(v) cm")
                                        .foregroundStyle(Color.black)
                                        .tag(v)
                                }
                            }
                            .pickerStyle(.wheel)
                        }
                        .frame(maxWidth: .infinity)

                        Rectangle()
                            .fill(Color(red: 0.88, green: 0.88, blue: 0.90))
                            .frame(width: 1)
                            .padding(.vertical, 16)

                        VStack(spacing: 2) {
                            Text(Lang.s("weight"))
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(Color(red: 0.5, green: 0.5, blue: 0.55))
                                .kerning(1)
                            Picker("Weight", selection: Binding(
                                get: { Int(weightKg) },
                                set: { weightKg = Double($0) }
                            )) {
                                ForEach(30...200, id: \.self) { v in
                                    Text("\(v) kg")
                                        .foregroundStyle(Color.black)
                                        .tag(v)
                                }
                            }
                            .pickerStyle(.wheel)
                        }
                        .frame(maxWidth: .infinity)
                    }
                } else {
                    HStack(spacing: 0) {
                        VStack(spacing: 2) {
                            Text(Lang.s("height"))
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(Color(red: 0.5, green: 0.5, blue: 0.55))
                                .kerning(1)
                            HStack(spacing: 0) {
                                Picker("Feet", selection: Binding(
                                    get: { max(4, min(7, Int(heightCm / 2.54) / 12)) },
                                    set: { ft in
                                        let inches = Int(heightCm / 2.54) % 12
                                        heightCm = Double(ft * 12 + inches) * 2.54
                                    }
                                )) {
                                    ForEach(4...7, id: \.self) { ft in
                                        Text("\(ft)'  ")
                                            .foregroundStyle(Color.black)
                                            .tag(ft)
                                    }
                                }
                                .pickerStyle(.wheel)
                                Picker("Inches", selection: Binding(
                                    get: { Int(heightCm / 2.54) % 12 },
                                    set: { inches in
                                        let ft = max(4, min(7, Int(heightCm / 2.54) / 12))
                                        heightCm = Double(ft * 12 + inches) * 2.54
                                    }
                                )) {
                                    ForEach(0...11, id: \.self) { inch in
                                        Text("\(inch)\"  ")
                                            .foregroundStyle(Color.black)
                                            .tag(inch)
                                    }
                                }
                                .pickerStyle(.wheel)
                            }
                        }
                        .frame(maxWidth: .infinity)

                        Rectangle()
                            .fill(Color(red: 0.88, green: 0.88, blue: 0.90))
                            .frame(width: 1)
                            .padding(.vertical, 16)

                        VStack(spacing: 2) {
                            Text(Lang.s("weight"))
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundStyle(Color(red: 0.5, green: 0.5, blue: 0.55))
                                .kerning(1)
                            Picker("Weight lbs", selection: Binding(
                                get: { Int(weightKg * 2.20462) },
                                set: { lbs in weightKg = Double(lbs) / 2.20462 }
                            )) {
                                ForEach(66...440, id: \.self) { v in
                                    Text("\(v) lbs")
                                        .foregroundStyle(Color.black)
                                        .tag(v)
                                }
                            }
                            .pickerStyle(.wheel)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .frame(height: 240)
            .padding(.horizontal, 20)
        }
        .onChange(of: weightKg) { _, newValue in
            targetWeightKg = max(30, newValue - 5)
        }
        .padding(.top, 24)
    }

    // MARK: - Step 3: Target Weight
    private var targetWeightStep: some View {
        VStack(alignment: .leading, spacing: 36) {
            quizHeader(title: Lang.s("target_weight_q"), subtitle: nil)

            VStack(spacing: 28) {
                HStack {
                    Spacer()
                    Text(Lang.s("imperial"))
                        .font(.system(size: 15))
                        .foregroundStyle(isMetric ? Color(red: 0.55, green: 0.55, blue: 0.6) : Color.black)
                    Toggle("", isOn: $isMetric)
                        .toggleStyle(SwitchToggleStyle(tint: Color.black))
                        .labelsHidden()
                        .frame(width: 52)
                    Text(Lang.s("metric"))
                        .font(.system(size: 15))
                        .foregroundStyle(isMetric ? Color.black : Color(red: 0.55, green: 0.55, blue: 0.6))
                    Spacer()
                }

                Text(displayTargetWeight)
                    .font(.system(size: 52, weight: .bold))
                    .foregroundStyle(Color.black)

                VStack(spacing: 8) {
                    Slider(value: $targetWeightKg, in: isMetric ? 30...200 : 30...200, step: 0.5)
                        .tint(Color.black)
                        .padding(.horizontal, 20)

                    HStack(spacing: 0) {
                        ForEach(0..<20) { _ in
                            Rectangle()
                                .frame(width: 1, height: 8)
                                .foregroundStyle(Color(red: 0.75, green: 0.75, blue: 0.78))
                            Spacer()
                        }
                        Rectangle()
                            .frame(width: 1, height: 8)
                            .foregroundStyle(Color(red: 0.75, green: 0.75, blue: 0.78))
                    }
                    .padding(.horizontal, 28)
                }
            }
        }
        .padding(.top, 24)
    }

    // MARK: - Step 4: Realistic Goal Motivational
    private var realisticGoalStep: some View {
        GeometryReader { geo in
            VStack(spacing: 0) {
                Spacer()
                VStack(spacing: 20) {
                    Group {
                        let diff = abs(weightDiff)
                        let unit = isMetric ? "kg" : "lbs"
                        let displayDiff = isMetric ? diff : diff * 2.20462
                        (Text(weightDiff > 0 ? Lang.s("losing") : Lang.s("gaining"))
                        + Text(String(format: "%.0f \(unit)", displayDiff))
                            .foregroundStyle(Color.quizTeal)
                        + Text(" \(Lang.s("realistic_goal"))"))
                    }
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Color.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)

                    Text(Lang.s("users_say_change"))
                        .font(.system(size: 15))
                        .foregroundStyle(Color(red: 0.5, green: 0.5, blue: 0.55))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                Spacer()
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .frame(minHeight: UIScreen.main.bounds.height - 200)
    }

    // MARK: - Step 5: Speed
    private var speedStep: some View {
        VStack(alignment: .leading, spacing: 0) {
            quizHeader(title: Lang.s("how_fast_goal"), subtitle: nil)
                .padding(.top, 24)

            VStack(spacing: 16) {
                Text(Lang.s("weight_loss_speed"))
                    .font(.system(size: 14))
                    .foregroundStyle(Color(red: 0.5, green: 0.5, blue: 0.55))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 20)

                HStack(alignment: .lastTextBaseline, spacing: 6) {
                    Text(String(format: "%.2f", speedValue))
                        .font(.system(size: 64, weight: .bold))
                        .foregroundStyle(Color.black)
                        .contentTransition(.numericText())
                        .animation(.easeInOut(duration: 0.15), value: speedValue)
                    Text(isMetric ? "kg" : "lbs")
                        .font(.system(size: 22, weight: .medium))
                        .foregroundStyle(Color.black)
                }

                VStack(spacing: 6) {
                    Text(speedAnimalEmoji)
                        .font(.system(size: 52))
                        .id(speedAnimalEmoji)
                        .transition(.scale.combined(with: .opacity))
                        .animation(.spring(response: 0.35, dampingFraction: 0.7), value: speedAnimalEmoji)

                    Text(speedAnimalLabel)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.black)
                        .animation(.easeInOut(duration: 0.15), value: speedAnimalLabel)
                }

                VStack(spacing: 6) {
                    Slider(value: $speedValue, in: 0.25...1.5, step: 0.05)
                        .tint(Color.black)
                        .padding(.horizontal, 20)
                        .sensoryFeedback(.selection, trigger: speedValue)
                        .onChange(of: speedValue) { _, _ in
                            customCalorieOverride = nil
                        }

                    HStack {
                        VStack(spacing: 2) {
                            Text("🐢")
                                .font(.system(size: 18))
                            Text(Lang.s("slow"))
                                .font(.system(size: 11))
                                .foregroundStyle(speedValue < 0.6 ? Color.black : Color(red: 0.6, green: 0.6, blue: 0.65))
                                .fontWeight(speedValue < 0.6 ? .bold : .regular)
                        }
                        Spacer()
                        VStack(spacing: 2) {
                            Text("🐕")
                                .font(.system(size: 18))
                            Text(Lang.s("recommended"))
                                .font(.system(size: 11))
                                .foregroundStyle(speedValue >= 0.6 && speedValue < 1.2 ? Color.black : Color(red: 0.6, green: 0.6, blue: 0.65))
                                .fontWeight(speedValue >= 0.6 && speedValue < 1.2 ? .bold : .regular)
                        }
                        Spacer()
                        VStack(spacing: 2) {
                            Text("🐆")
                                .font(.system(size: 18))
                            Text(Lang.s("fast"))
                                .font(.system(size: 11))
                                .foregroundStyle(speedValue >= 1.2 ? Color.black : Color(red: 0.6, green: 0.6, blue: 0.65))
                                .fontWeight(speedValue >= 1.2 ? .bold : .regular)
                        }
                    }
                    .padding(.horizontal, 20)
                }

                VStack(spacing: 12) {
                    (Text(Lang.s("reach_goal_in"))
                    + Text(Lang.s("x_months").replacingOccurrences(of: "%d", with: "\(monthsToGoal)"))
                        .foregroundStyle(Color.quizTeal)
                        .fontWeight(.semibold))
                        .font(.system(size: 15))
                        .foregroundStyle(Color.black)
                        .animation(.easeInOut(duration: 0.2), value: monthsToGoal)

                    Text(speedValue > 1.2 ? Lang.s("fast_pace_warning") : speedValue < 0.6 ? Lang.s("comfortable_pace") : Lang.s("ideal_pace"))
                        .font(.system(size: 13))
                        .foregroundStyle(Color(red: 0.5, green: 0.5, blue: 0.55))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)

                    VStack(spacing: 8) {
                        HStack(spacing: 6) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(Color.quizTeal)
                            Text(Lang.s("daily_calorie_goal"))
                                .font(.system(size: 12, weight: .medium))
                                .foregroundStyle(Color(red: 0.5, green: 0.5, blue: 0.55))
                            Spacer()
                            if customCalorieOverride != nil {
                                Button {
                                    withAnimation(.spring(response: 0.3)) {
                                        customCalorieOverride = nil
                                    }
                                } label: {
                                    Text(Lang.s("reset"))
                                        .font(.system(size: 11, weight: .medium))
                                        .foregroundStyle(Color.quizTeal)
                                }
                            }
                        }

                        if isEditingCalories {
                            HStack(spacing: 8) {
                                TextField("", text: $calorieEditText)
                                    .keyboardType(.numberPad)
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundStyle(Color.black)
                                    .multilineTextAlignment(.center)
                                    .frame(width: 120)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .background(Color.white)
                                    .clipShape(.rect(cornerRadius: 10))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.quizTeal, lineWidth: 2)
                                    )
                                Text("kcal")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundStyle(Color.black)
                            }

                            HStack(spacing: 10) {
                                Button {
                                    withAnimation(.spring(response: 0.3)) {
                                        isEditingCalories = false
                                    }
                                } label: {
                                    Text(Lang.s("cancel"))
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundStyle(Color(red: 0.5, green: 0.5, blue: 0.55))
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 10)
                                        .background(Color.quizCard)
                                        .clipShape(.rect(cornerRadius: 10))
                                }
                                Button {
                                    if let val = Int(calorieEditText), val >= 800, val <= 6000 {
                                        withAnimation(.spring(response: 0.3)) {
                                            customCalorieOverride = val
                                            isEditingCalories = false
                                        }
                                    }
                                } label: {
                                    Text("OK")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 24)
                                        .padding(.vertical, 10)
                                        .background(Color.black)
                                        .clipShape(.rect(cornerRadius: 10))
                                }
                            }
                        } else {
                            Button {
                                calorieEditText = "\(dailyCalories)"
                                withAnimation(.spring(response: 0.3)) {
                                    isEditingCalories = true
                                }
                            } label: {
                                HStack(alignment: .lastTextBaseline, spacing: 4) {
                                    Text("\(dailyCalories)")
                                        .font(.system(size: 28, weight: .bold))
                                        .foregroundStyle(customCalorieOverride != nil ? Color.quizTeal : Color.black)
                                        .contentTransition(.numericText())
                                        .animation(.easeInOut(duration: 0.2), value: dailyCalories)
                                    Text("kcal")
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundStyle(Color.black)
                                    Image(systemName: "pencil.circle.fill")
                                        .font(.system(size: 16))
                                        .foregroundStyle(Color(red: 0.5, green: 0.5, blue: 0.55))
                                }
                            }
                            .buttonStyle(.plain)

                            if customCalorieOverride != nil {
                                Text(Lang.s("custom_target_set"))
                                    .font(.system(size: 11))
                                    .foregroundStyle(Color.quizTeal)
                            }
                        }
                    }
                    .padding(16)
                    .frame(maxWidth: .infinity)
                    .background(Color.quizCard)
                    .clipShape(.rect(cornerRadius: 14))
                    .padding(.horizontal, 20)

                    if speedValue > 1.2 {
                        HStack(spacing: 10) {
                            Rectangle()
                                .fill(Color.red)
                                .frame(width: 3)
                            Text(Lang.s("fast_loss_warning"))
                                .font(.system(size: 13))
                                .foregroundStyle(Color.red)
                        }
                        .padding(12)
                        .background(Color.red.opacity(0.07))
                        .clipShape(.rect(cornerRadius: 8))
                        .padding(.horizontal, 20)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
                .animation(.easeInOut(duration: 0.25), value: speedValue > 1.2)
            }
        }
    }

    // MARK: - Step 6: Double Weight Comparison
    private var doubleWeightStep: some View {
        VStack(spacing: 0) {
            quizHeader(
                title: Lang.s("double_weight_title"),
                subtitle: nil
            )
            .padding(.top, 24)
            .padding(.horizontal, 20)

            VStack(spacing: 20) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.quizCard)
                    .frame(height: 240)
                    .overlay {
                        HStack(alignment: .bottom, spacing: 40) {
                            VStack(spacing: 12) {
                                Text(Lang.s("without_mywellness"))
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(Color.black)
                                    .multilineTextAlignment(.center)

                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color(red: 0.82, green: 0.82, blue: 0.85))
                                    .frame(width: 70, height: 78)
                                    .scaleEffect(y: comparisonAnimate ? 1 : 0.001, anchor: .bottom)
                                    .animation(.spring(response: 0.7, dampingFraction: 0.75).delay(0.15), value: comparisonAnimate)

                                Text("20%")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundStyle(Color(red: 0.6, green: 0.6, blue: 0.65))
                                    .opacity(comparisonAnimate ? 1 : 0)
                                    .animation(.easeIn(duration: 0.3).delay(0.6), value: comparisonAnimate)
                            }

                            VStack(spacing: 12) {
                                Text(Lang.s("with_mywellness"))
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundStyle(Color.black)
                                    .multilineTextAlignment(.center)

                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.black)
                                    .frame(width: 70, height: 110)
                                    .scaleEffect(y: comparisonAnimate ? 1 : 0.001, anchor: .bottom)
                                    .animation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.35), value: comparisonAnimate)

                                Text("2X")
                                    .font(.system(size: 28, weight: .bold))
                                    .foregroundStyle(Color.black)
                                    .opacity(comparisonAnimate ? 1 : 0)
                                    .animation(.easeIn(duration: 0.3).delay(0.8), value: comparisonAnimate)
                            }
                        }
                        .padding(.bottom, 16)
                    }
                    .padding(.horizontal, 20)

                Text(Lang.s("mywellness_easy_support"))
                    .font(.system(size: 14))
                    .foregroundStyle(Color(red: 0.5, green: 0.5, blue: 0.55))
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 24)
            .onAppear {
                comparisonAnimate = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    comparisonAnimate = true
                }
            }
            .onDisappear { comparisonAnimate = false }
        }
    }

    // MARK: - Step 7: Activity Level
    private var activityLevelStep: some View {
        VStack(alignment: .leading, spacing: 32) {
            quizHeader(
                title: Lang.s("daily_activity_level"),
                subtitle: Lang.s("exact_energy_needs")
            )
            .padding(.horizontal, 20)
            .padding(.top, 24)

            VStack(spacing: 10) {
                ForEach(UserProfile.ActivityLevel.allCases, id: \.self) { level in
                    let isSelected = selectedActivityLevel == level
                    Button {
                        selectedActivityLevel = level
                    } label: {
                        HStack(spacing: 14) {
                            Image(systemName: level.icon)
                                .font(.title3)
                                .foregroundStyle(isSelected ? .white : .black)
                                .frame(width: 32)
                            VStack(alignment: .leading, spacing: 3) {
                                Text(localizedActivityName(level))
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(isSelected ? .white : .black)
                                Text(localizedActivityDesc(level))
                                    .font(.system(size: 13))
                                    .foregroundStyle(isSelected ? .white.opacity(0.75) : Color(red: 0.5, green: 0.5, blue: 0.55))
                            }
                            Spacer()
                            if isSelected {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.white)
                                    .font(.title3)
                            }
                        }
                        .padding(.horizontal, 18)
                        .padding(.vertical, 16)
                        .background(isSelected ? Color.black : Color.quizCard)
                        .clipShape(.rect(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(isSelected ? Color.black : Color(red: 0.88, green: 0.88, blue: 0.90), lineWidth: isSelected ? 2 : 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .conditionalSensoryFeedback(.selection, trigger: isSelected)
                    .animation(.easeInOut(duration: 0.15), value: isSelected)
                }
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Step 8: Current Body Type
    private var currentBodyTypeStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            quizHeader(
                title: Lang.s("current_body_type"),
                subtitle: Lang.s("select_range_physique")
            )
            .padding(.horizontal, 20)
            .padding(.top, 24)

            bodyTypeGrid(selected: $currentBodyType)
        }
    }

    // MARK: - Step 9: Target Body Type
    private var targetBodyTypeStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            quizHeader(title: Lang.s("target_body_type"), subtitle: Lang.s("choose_fat_range"))
                .padding(.horizontal, 20)
                .padding(.top, 24)

            bodyTypeGrid(selected: $targetBodyType)
        }
    }

    private let bodyTypes: [(percent: String, range: String, labelKey: String, descKey: String, accent: Color)] = [
        ("8%",  "5–9%",   "bt_extremely_defined", "bt_extremely_defined_desc",   Color(red: 0.20, green: 0.48, blue: 0.95)),
        ("10%", "10–12%", "bt_very_defined",      "bt_very_defined_desc",        Color(red: 0.18, green: 0.62, blue: 0.88)),
        ("15%", "13–17%", "bt_athletic",          "bt_athletic_desc",           Color(red: 0.12, green: 0.72, blue: 0.60)),
        ("20%", "18–22%", "bt_fit",               "bt_fit_desc",        Color(red: 0.22, green: 0.72, blue: 0.35)),
        ("25%", "23–27%", "bt_average",           "bt_average_desc",       Color(red: 0.82, green: 0.68, blue: 0.10)),
        ("30%", "28–32%", "bt_above_average",     "bt_above_average_desc",       Color(red: 0.92, green: 0.52, blue: 0.12)),
        ("35%", "33–37%", "bt_rounded",           "bt_rounded_desc",     Color(red: 0.90, green: 0.32, blue: 0.18)),
        ("40%+","38%+",  "bt_heavy",             "bt_heavy_desc",    Color(red: 0.85, green: 0.18, blue: 0.18)),
    ]

    private func bodyTypeGrid(selected: Binding<Int>) -> some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ForEach(bodyTypes.indices, id: \.self) { i in
                let bt = bodyTypes[i]
                let isSelected = selected.wrappedValue == i
                Button {
                    selected.wrappedValue = i
                } label: {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(alignment: .top, spacing: 0) {
                            Text(bt.percent)
                                .font(.system(size: 30, weight: .heavy, design: .rounded))
                                .foregroundStyle(isSelected ? bt.accent : Color(white: 0.15))
                            Spacer()
                            ZStack {
                                Circle()
                                    .fill(bt.accent.opacity(0.12))
                                    .frame(width: 30, height: 30)
                                Circle()
                                    .fill(isSelected ? bt.accent : bt.accent.opacity(0.45))
                                    .frame(width: 11, height: 11)
                            }
                        }
                        .padding(.bottom, 6)

                        Text(Lang.s(bt.labelKey))
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(Color(white: 0.08))
                            .padding(.bottom, 3)

                        Text("\(Lang.s("range_label")) \(bt.range)")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(bt.accent)
                            .padding(.bottom, 6)

                        Text(Lang.s(bt.descKey))
                            .font(.system(size: 11))
                            .foregroundStyle(Color(white: 0.50))
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .clipShape(.rect(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(
                                isSelected ? bt.accent : Color(white: 0.88),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
                    .shadow(color: isSelected ? bt.accent.opacity(0.18) : .clear, radius: 8, y: 3)
                }
                .buttonStyle(.plain)
                .conditionalSensoryFeedback(.selection, trigger: selected.wrappedValue)
            }
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Step 8: Areas to Improve
    private let areaItems: [(emoji: String, id: String, titleKey: String, subtitleKey: String)] = [
        ("💪", "Arms", "area_arms", "area_arms_desc"),
        ("🦸", "Chest", "area_chest", "area_chest_desc"),
        ("🏋️", "Shoulders", "area_shoulders", "area_shoulders_desc"),
        ("🧍", "Back", "area_back", "area_back_desc"),
        ("🧘", "Abdomen", "area_abdomen", "area_abdomen_desc"),
        ("⏳", "Waist/Hips", "area_waist", "area_waist_desc"),
        ("🍑", "Glutes", "area_glutes", "area_glutes_desc"),
        ("🦵", "Thighs", "area_thighs", "area_thighs_desc"),
        ("🦵", "Calves", "area_calves", "area_calves_desc"),
    ]

    private var areasStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            quizHeader(title: Lang.s("areas_to_improve"), subtitle: Lang.s("select_areas_focus"))
                .padding(.horizontal, 20)
                .padding(.top, 24)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(areaItems, id: \.id) { item in
                    let isSelected = areasToImprove.contains(item.id)
                    Button {
                        if isSelected { areasToImprove.remove(item.id) }
                        else { areasToImprove.insert(item.id) }
                    } label: {
                        VStack(spacing: 8) {
                            Text(item.emoji)
                                .font(.system(size: 28))
                            Text(Lang.s(item.titleKey))
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(isSelected ? .white : Color.black)
                            Text(Lang.s(item.subtitleKey))
                                .font(.system(size: 12))
                                .foregroundStyle(isSelected ? Color.white.opacity(0.7) : Color(red: 0.5, green: 0.5, blue: 0.55))
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(isSelected ? Color.black : Color.white)
                        .clipShape(.rect(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(isSelected ? Color.black : Color(red: 0.88, green: 0.88, blue: 0.90), lineWidth: isSelected ? 2 : 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .conditionalSensoryFeedback(.selection, trigger: isSelected)
                    .animation(.easeInOut(duration: 0.15), value: isSelected)
                }
            }
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Step 10: Obstacles
    private let obstacleItems: [(emoji: String, id: String, key: String)] = [
        ("📊", "Falta de constancia", "obstacle_consistency"),
        ("🍔", "Hábitos alimenticios poco saludables", "obstacle_eating"),
        ("🤝", "Falta de apoyo", "obstacle_support"),
        ("📅", "Agenda ocupada", "obstacle_schedule"),
        ("🍎", "Falta de inspiración para comidas", "obstacle_inspiration"),
        ("💤", "Malos hábitos de sueño", "obstacle_sleep"),
        ("😩", "Poca motivación", "obstacle_motivation"),
    ]

    private var obstaclesStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            quizHeader(
                title: Lang.s("obstacles_title"),
                subtitle: Lang.s("obstacles_subtitle")
            )
            .padding(.horizontal, 20)
            .padding(.top, 24)

            VStack(spacing: 10) {
                ForEach(obstacleItems, id: \.id) { item in
                    let isSelected = obstacles.contains(item.id)
                    Button {
                        if isSelected { obstacles.remove(item.id) }
                        else { obstacles.insert(item.id) }
                    } label: {
                        HStack(spacing: 14) {
                            Text(item.emoji)
                                .font(.system(size: 22))
                            Text(Lang.s(item.key))
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(isSelected ? .white : Color.black)
                            Spacer()
                        }
                        .padding(.horizontal, 18)
                        .frame(height: 62)
                        .background(isSelected ? Color.black : Color.white)
                        .clipShape(.rect(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(isSelected ? Color.black : Color(red: 0.88, green: 0.88, blue: 0.90), lineWidth: isSelected ? 2 : 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .conditionalSensoryFeedback(.selection, trigger: isSelected)
                    .animation(.easeInOut(duration: 0.15), value: isSelected)
                }
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Step 11: Diet
    private let dietItems: [(emoji: String, id: String, key: String)] = [
        ("🥗", "Low Carb", "diet_low_carb"),
        ("🌮", "Soft Low Carb", "diet_soft_low_carb"),
        ("🥑", "Ketogenic", "diet_ketogenic"),
        ("🥩", "Carnívora", "diet_carnivore"),
        ("🥦", "Vegetariana", "diet_vegetarian"),
        ("🌱", "Vegana", "diet_vegan"),
        ("🥜", "Paleo", "diet_paleo"),
        ("🫒", "Mediterránea", "diet_mediterranean"),
        ("🍽️", "Equilibrada", "diet_balanced"),
        ("✨", "Sin dieta específica", "diet_none"),
    ]

    private var dietStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            quizHeader(title: Lang.s("diet_title"), subtitle: nil)
                .padding(.horizontal, 20)
                .padding(.top, 24)

            VStack(spacing: 10) {
                ForEach(dietItems, id: \.id) { item in
                    let isSelected = selectedDiet == item.id
                    Button {
                        selectedDiet = item.id
                    } label: {
                        HStack(spacing: 14) {
                            Text(item.emoji)
                                .font(.system(size: 22))
                            Text(Lang.s(item.key))
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(isSelected ? .white : Color.black)
                            Spacer()
                        }
                        .padding(.horizontal, 18)
                        .frame(height: 62)
                        .background(isSelected ? Color.black : Color.white)
                        .clipShape(.rect(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(isSelected ? Color.black : Color(red: 0.88, green: 0.88, blue: 0.90), lineWidth: isSelected ? 2 : 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .conditionalSensoryFeedback(.selection, trigger: isSelected)
                    .animation(.easeInOut(duration: 0.15), value: isSelected)
                }
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Step 12: Achievements
    private let achievementItems: [(emoji: String, id: String, key: String)] = [
        ("🍎", "Eat and live healthier", "achieve_healthier"),
        ("☀️", "Increase my energy and mood", "achieve_energy"),
        ("💪", "Stay motivated and consistent", "achieve_motivated"),
        ("🧘", "Feel better about my body", "achieve_body"),
    ]

    private var achievementsStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            quizHeader(title: Lang.s("achievements_title"), subtitle: nil)
                .padding(.horizontal, 20)
                .padding(.top, 24)

            VStack(spacing: 10) {
                ForEach(achievementItems, id: \.id) { item in
                    let isSelected = achievements.contains(item.id)
                    Button {
                        if isSelected { achievements.remove(item.id) }
                        else { achievements.insert(item.id) }
                    } label: {
                        HStack(spacing: 14) {
                            Text(item.emoji)
                                .font(.system(size: 22))
                            Text(Lang.s(item.key))
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(isSelected ? .white : Color.black)
                            Spacer()
                        }
                        .padding(.horizontal, 18)
                        .frame(height: 62)
                        .background(isSelected ? Color.black : Color.white)
                        .clipShape(.rect(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(isSelected ? Color.black : Color(red: 0.88, green: 0.88, blue: 0.90), lineWidth: isSelected ? 2 : 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .conditionalSensoryFeedback(.selection, trigger: isSelected)
                    .animation(.easeInOut(duration: 0.15), value: isSelected)
                }
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Step 13: Weight Chart
    private var weightChartStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            quizHeader(title: Lang.s("great_potential"), subtitle: nil)
                .padding(.horizontal, 20)
                .padding(.top, 24)

            VStack(spacing: 16) {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.quizCard)
                    .overlay {
                        VStack(alignment: .leading, spacing: 16) {
                            Text(Lang.s("weight_transition"))
                                .font(.system(size: 15, weight: .semibold))
                                .foregroundStyle(Color.black)
                                .frame(maxWidth: .infinity, alignment: .center)

                            WeightChartView()
                                .frame(height: 140)

                            HStack {
                                Text(Lang.s("three_days"))
                                Spacer()
                                Text(Lang.s("seven_days"))
                                Spacer()
                                Text(Lang.s("thirty_days"))
                            }
                            .font(.system(size: 12))
                            .foregroundStyle(Color(red: 0.5, green: 0.5, blue: 0.55))
                        }
                        .padding(20)
                    }
                    .frame(height: 240)
                    .padding(.horizontal, 20)

                Text(Lang.s("weight_chart_desc"))
                    .font(.system(size: 14))
                    .foregroundStyle(Color(red: 0.5, green: 0.5, blue: 0.55))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
        }
    }

    // MARK: - Step 14: Thank You
    private var thankYouStep: some View {
        VStack(spacing: 40) {
            Spacer()

            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(red: 0.88, green: 0.84, blue: 0.96), Color(red: 0.94, green: 0.90, blue: 0.98).opacity(0)],
                            center: .center,
                            startRadius: 60,
                            endRadius: 120
                        )
                    )
                    .frame(width: 240, height: 240)

                Circle()
                    .fill(Color.white)
                    .frame(width: 160, height: 160)
                    .shadow(color: Color.black.opacity(0.06), radius: 16)

                VStack(spacing: 4) {
                    Text("✋")
                        .font(.system(size: 60))
                    HStack(spacing: 4) {
                        ForEach(0..<5) { i in
                            Circle()
                                .fill(Color.black.opacity(i % 2 == 0 ? 1 : 0.4))
                                .frame(width: 5, height: 5)
                        }
                    }
                }
            }

            VStack(spacing: 12) {
                Text(Lang.s("thank_you_trusting"))
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Color.black)
                    .multilineTextAlignment(.center)

                Text(Lang.s("personalizing_for_you"))
                    .font(.system(size: 15))
                    .foregroundStyle(Color(red: 0.5, green: 0.5, blue: 0.55))
            }
            .padding(.horizontal, 32)

            VStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color.quizCard)
                    .frame(height: 100)
                    .overlay {
                        VStack(spacing: 8) {
                            Image(systemName: "lock")
                                .font(.system(size: 22))
                                .foregroundStyle(Color.black)
                                .padding(10)
                                .background(Color.white)
                                .clipShape(Circle())

                            Text(Lang.s("privacy_matters"))
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundStyle(Color.black)

                            Text(Lang.s("privacy_promise"))
                                .font(.system(size: 12))
                                .foregroundStyle(Color(red: 0.5, green: 0.5, blue: 0.55))
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                    }
                    .padding(.horizontal, 20)
            }

            Spacer()
        }
    }

    // MARK: - Step 15: Referral Code
    private var referralStep: some View {
        VStack(alignment: .leading, spacing: 32) {
            quizHeader(
                title: Lang.s("referral_title"),
                subtitle: Lang.s("referral_subtitle")
            )
            .padding(.horizontal, 20)
            .padding(.top, 24)

            TextField(Lang.s("referral_placeholder"), text: $referralCode)
                .font(.system(size: 16))
                .foregroundStyle(Color.black)
                .padding(18)
                .background(Color.quizCard)
                .clipShape(.rect(cornerRadius: 14))
                .padding(.horizontal, 20)
        }
    }

    // MARK: - Step 16: Ready
    private var readyStep: some View {
        VStack(spacing: 32) {
            Spacer()

            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(red: 0.88, green: 0.84, blue: 0.96), Color(red: 0.94, green: 0.90, blue: 0.98).opacity(0)],
                            center: .center,
                            startRadius: 60,
                            endRadius: 120
                        )
                    )
                    .frame(width: 240, height: 240)

                Circle()
                    .fill(Color.white)
                    .frame(width: 160, height: 160)
                    .shadow(color: Color.black.opacity(0.06), radius: 16)

                VStack(spacing: 4) {
                    Text("🤞")
                        .font(.system(size: 60))
                    HStack(spacing: 4) {
                        ForEach(0..<5) { i in
                            Circle()
                                .fill(Color.black.opacity(i % 2 == 0 ? 1 : 0.4))
                                .frame(width: 5, height: 5)
                        }
                    }
                }
            }

            HStack(spacing: 8) {
                Image(systemName: "checkmark.circle")
                    .foregroundStyle(Color.orange)
                Text(Lang.s("ready_label"))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.orange)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.orange.opacity(0.10))
            .clipShape(.capsule)

            Text(Lang.s("generate_plan"))
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(Color.black)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Step 20: Plan Ready
    private var planReadyStep: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 8) {
                Text(Lang.s("plan_ready_title"))
                    .font(.system(size: 30, weight: .heavy))
                    .foregroundStyle(Color.black)
                Text(Lang.s("plan_ready_subtitle"))
                    .font(.system(size: 30, weight: .heavy))
                    .foregroundStyle(Color.black)

                HStack(spacing: 6) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 13))
                        .foregroundStyle(Color(red: 0.20, green: 0.70, blue: 0.65))
                    Text(Lang.s("based_personal_data"))
                        .font(.system(size: 13))
                        .foregroundStyle(Color(red: 0.20, green: 0.70, blue: 0.65))
                }
                .padding(.top, 4)
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 28)

            VStack(alignment: .center, spacing: 6) {
                Text(Lang.s("you_should_lose"))
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(Color.black)

                let diff = max(0.0, weightKg - targetWeightKg)
                let unit = isMetric ? "kg" : "lbs"
                let displayDiff = isMetric ? diff : diff * 2.20462
                Text("\(Lang.s("lose_by")) \(String(format: "%.0f", displayDiff)) \(unit) \(Lang.s("by_date")) \(goalDate)")
                    .font(.system(size: 15))
                    .foregroundStyle(Color(red: 0.45, green: 0.45, blue: 0.50))
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal, 20)
            .padding(.bottom, 28)

            VStack(spacing: 8) {
                Text(Lang.s("discover_body_fat"))
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.black)
                HStack(spacing: 6) {
                    Image(systemName: "eye.slash")
                        .font(.system(size: 14))
                        .foregroundStyle(Color(red: 0.45, green: 0.42, blue: 0.55))
                    Text(Lang.s("sign_up_find_out"))
                        .font(.system(size: 14))
                        .foregroundStyle(Color(red: 0.45, green: 0.42, blue: 0.55))
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 22)
            .background(Color(red: 0.93, green: 0.91, blue: 0.98))
            .clipShape(.rect(cornerRadius: 16))
            .padding(.horizontal, 20)
            .padding(.bottom, 32)

            VStack(alignment: .center, spacing: 4) {
                Text(Lang.s("your_macros"))
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(Color.black)
                Text(Lang.s("adjust_anytime"))
                    .font(.system(size: 13))
                    .foregroundStyle(Color(red: 0.50, green: 0.50, blue: 0.55))
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal, 20)
            .padding(.bottom, 24)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 24) {
                blurredMacroCircle(emoji: "🔥", label: Lang.s("calorie_label"),      ringColor: Color(white: 0.80))
                blurredMacroCircle(emoji: "🌾", label: Lang.s("carbs"),     ringColor: Color(red: 0.98, green: 0.68, blue: 0.22))
                blurredMacroCircle(emoji: "🥩", label: Lang.s("protein"),    ringColor: Color(red: 0.96, green: 0.58, blue: 0.60))
                blurredMacroCircle(emoji: "🥑", label: Lang.s("fat"),        ringColor: Color(red: 0.58, green: 0.80, blue: 0.96))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 32)

            VStack(alignment: .leading, spacing: 12) {
                Text(Lang.s("plan_sources"))
                    .font(.system(size: 11))
                    .foregroundStyle(Color(red: 0.50, green: 0.50, blue: 0.55))
                    .multilineTextAlignment(.leading)

                VStack(alignment: .leading, spacing: 8) {
                    Link(destination: URL(string: "https://www.healthline.com/health/what-is-basal-metabolic-rate")!) {
                        Text("• What Is Basal Metabolic Rate? — Healthline")
                            .font(.system(size: 11))
                            .foregroundStyle(Color(red: 0.25, green: 0.45, blue: 0.85))
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    Link(destination: URL(string: "https://www.health.harvard.edu/healthy-aging-and-longevity/calorie-counting-made-easy")!) {
                        Text("• Calorie Counting Made Easy — Harvard Health Publishing")
                            .font(.system(size: 11))
                            .foregroundStyle(Color(red: 0.25, green: 0.45, blue: 0.85))
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    Link(destination: URL(string: "https://pubmed.ncbi.nlm.nih.gov/28630601/")!) {
                        Text("• Obesity and Dietary Patterns — PubMed / NCBI")
                            .font(.system(size: 11))
                            .foregroundStyle(Color(red: 0.25, green: 0.45, blue: 0.85))
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    Link(destination: URL(string: "https://www.nhlbi.nih.gov/files/docs/guidelines/ob_gdlns.pdf")!) {
                        Text("• Clinical Guidelines on Identification, Evaluation, and Treatment of Overweight and Obesity in Adults — NHLBI")
                            .font(.system(size: 11))
                            .foregroundStyle(Color(red: 0.25, green: 0.45, blue: 0.85))
                            .multilineTextAlignment(.leading)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 40)
        }
    }

    private func blurredMacroCircle(emoji: String, label: String, ringColor: Color) -> some View {
        VStack(spacing: 10) {
            HStack(spacing: 4) {
                Text(emoji)
                    .font(.system(size: 16))
                Text(label)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color.black)
            }

            ZStack {
                Circle()
                    .stroke(ringColor, lineWidth: 9)
                    .frame(width: 112, height: 112)

                Text("2000")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.black)
                    .blur(radius: 7)

                Image(systemName: "eye.slash")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundStyle(Color(white: 0.55))
            }
        }
    }

    // MARK: - Step 17: Loading
    private var loadingStep: some View {
        VStack(spacing: 32) {
            Spacer()

            Text("\(Int(loadingProgress * 100))%")
                .font(.system(size: 64, weight: .bold))
                .foregroundStyle(Color.black)
                .contentTransition(.numericText())
                .animation(.easeInOut, value: loadingProgress)

            Text(Lang.s("setting_up"))
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.black)
                .multilineTextAlignment(.center)

            VStack(spacing: 4) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.quizCard)
                            .frame(height: 8)
                        Capsule()
                            .fill(Color.black)
                            .frame(width: geo.size.width * loadingProgress, height: 8)
                            .animation(.easeInOut(duration: 0.15), value: loadingProgress)
                    }
                }
                .frame(height: 8)
                .padding(.horizontal, 24)

                Text(Lang.s("personalizing_plan"))
                    .font(.system(size: 13))
                    .foregroundStyle(Color(red: 0.5, green: 0.5, blue: 0.55))
                    .padding(.top, 8)
            }

            VStack(alignment: .leading, spacing: 16) {
                Text(Lang.s("daily_recommendation"))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color.black)

                ForEach(Array(zip([Lang.s("calories"), Lang.s("carbs"), Lang.s("protein"), Lang.s("fats")], loadingChecked.indices)), id: \.1) { item in
                    HStack(spacing: 12) {
                        Text("• \(item.0)")
                            .font(.system(size: 15))
                            .foregroundStyle(Color.black)
                        Spacer()
                        if loadingChecked[item.1] {
                            Image(systemName: "checkmark.circle")
                                .foregroundStyle(Color.quizTeal)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .animation(.spring(duration: 0.3), value: loadingChecked[item.1])
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)

            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Step 18: Login
    private var loginStep: some View {
        VStack(spacing: 0) {
            quizHeader(title: Lang.s("save_progress"), subtitle: nil)
                .padding(.top, 24)

            Spacer()

            VStack(spacing: 14) {
                Button {
                    AuthService.shared.performAppleSignIn { success in
                        if success {
                            withAnimation { step = 22 }
                        }
                    }
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "apple.logo")
                            .font(.system(size: 18, weight: .semibold))
                        if AuthService.shared.isAppleSigningIn {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text(Lang.s("sign_in_apple"))
                                .font(.system(size: 16, weight: .medium))
                        }
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(.black)
                    .clipShape(.rect(cornerRadius: 28))
                }
                .buttonStyle(.plain)
                .disabled(AuthService.shared.isAppleSigningIn)

                Button {
                    Task {
                        await AuthService.shared.handleGoogleSignIn()
                        if AuthService.shared.isSignedIn {
                            withAnimation { step = 22 }
                        }
                    }
                } label: {
                    HStack(spacing: 10) {
                        ZStack {
                            Circle()
                                .fill(Color.white)
                                .frame(width: 26, height: 26)
                            Text("G")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.98, green: 0.27, blue: 0.23),
                                            Color(red: 0.26, green: 0.52, blue: 0.96)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                        if AuthService.shared.isGoogleSigningIn {
                            ProgressView()
                                .tint(.black)
                        } else {
                            Text(Lang.s("continue_google"))
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(Color.black)
                        }
                    }
                    .frame(height: 56)
                    .frame(maxWidth: .infinity)
                    .background(Color.white)
                    .clipShape(.rect(cornerRadius: 28))
                    .overlay(
                        RoundedRectangle(cornerRadius: 28)
                            .stroke(Color(red: 0.82, green: 0.82, blue: 0.85), lineWidth: 1.5)
                    )
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .alert("Error", isPresented: Binding<Bool>(
            get: { AuthService.shared.errorMessage != nil },
            set: { if !$0 { AuthService.shared.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(AuthService.shared.errorMessage ?? "")
        }
    }

    // MARK: - Step 21: Apple Health
    private var healthKitStep: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 0)

            HealthKitIllustration()
                .frame(height: 280)
                .padding(.top, 16)

            VStack(alignment: .leading, spacing: 12) {
                Text(Lang.s("connect_apple_health"))
                    .font(.system(size: 34, weight: .heavy))
                    .foregroundStyle(Color.black)

                Text(Lang.s("sync_activity"))
                    .font(.system(size: 16))
                    .foregroundStyle(Color(red: 0.50, green: 0.50, blue: 0.55))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 24)
            .padding(.top, 32)

            Spacer(minLength: 24)

            VStack(spacing: 12) {
                Button {
                    Task {
                        await HealthKitService.shared.requestAuthorization()
                        await MainActor.run {
                            withAnimation { step = 23 }
                        }
                    }
                } label: {
                    Text(Lang.s("continue"))
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.black)
                        .clipShape(.rect(cornerRadius: 28))
                }

                Button {
                    withAnimation { step = 23 }
                } label: {
                    Text(Lang.s("skip"))
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(Color.black)
                        .frame(height: 44)
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Step 23: Notification Permission
    private var notificationStep: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 32) {
                Text(Lang.s("remember_log_meals"))
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(Color.black)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)

                VStack(spacing: 0) {
                    Text(Lang.s("notif_dialog"))
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color.black)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .padding(.bottom, 18)

                    Divider()

                    HStack(spacing: 0) {
                        Button {
                            withAnimation { step = 24 }
                        } label: {
                            Text(Lang.s("dont_allow"))
                                .font(.system(size: 17))
                                .foregroundStyle(Color(red: 0.45, green: 0.45, blue: 0.50))
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                        }

                        Divider()
                            .frame(height: 52)

                        Button {
                            Task {
                                let center = UNUserNotificationCenter.current()
                                try? await center.requestAuthorization(options: [.alert, .sound, .badge])
                                await MainActor.run {
                                    withAnimation { step = 24 }
                                }
                            }
                        } label: {
                            Text(Lang.s("allow"))
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundStyle(Color.black)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                        }
                    }
                }
                .background(Color(red: 0.92, green: 0.92, blue: 0.94))
                .clipShape(.rect(cornerRadius: 16))
                .padding(.horizontal, 32)

                Text("👆")
                    .font(.system(size: 48))
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 72)
            }

            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Step 24: Free Trial Teaser
    private var freeTrialStep: some View {
        VStack(spacing: 0) {
            Spacer()

            Text(Lang.s("try_free"))
                .font(.system(size: 30, weight: .heavy))
                .foregroundStyle(Color.black)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)
                .padding(.bottom, 36)

            freeTrialMockup
                .padding(.horizontal, 20)
                .padding(.bottom, 32)

            Spacer()

            VStack(spacing: 0) {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 13, weight: .bold))
                    Text(Lang.s("no_payment_now"))
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundStyle(Color.black)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 14)

                Button {
                    withAnimation(.easeInOut(duration: 0.25)) { step = 25 }
                } label: {
                    Text(Lang.s("try_now"))
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(Color.black)
                        .clipShape(.rect(cornerRadius: 28))
                }
                .padding(.horizontal, 20)

                Button {
                    Task { await storeVM.restore() }
                } label: {
                    Text(Lang.s("already_purchased"))
                        .font(.system(size: 14))
                        .foregroundStyle(Color(red: 0.45, green: 0.45, blue: 0.5))
                        .frame(height: 44)
                }
                .padding(.top, 4)

                Text(Lang.s("price_yearly_full"))
                    .font(.system(size: 12))
                    .foregroundStyle(Color(red: 0.55, green: 0.55, blue: 0.6))
                    .padding(.top, 2)
                    .padding(.bottom, 12)

                HStack(spacing: 16) {
                    Link(Lang.s("terms"), destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                    Text("·").foregroundStyle(Color(red: 0.7, green: 0.7, blue: 0.75))
                    Link(Lang.s("privacy"), destination: URL(string: "https://www.apple.com/legal/privacy/")!)
                    Text("·").foregroundStyle(Color(red: 0.7, green: 0.7, blue: 0.75))
                    Button(Lang.s("restore")) { Task { await storeVM.restore() } }
                }
                .font(.system(size: 12))
                .foregroundStyle(Color(red: 0.55, green: 0.55, blue: 0.6))
                .padding(.bottom, 40)
            }
            .background(Color.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }

    private var freeTrialMockup: some View {
        Image("onboarding_free_trial")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .clipShape(.rect(cornerRadius: 24))
            .shadow(color: Color.black.opacity(0.08), radius: 16, x: 0, y: 8)
    }

    // MARK: - Step 24: Paywall
    private var paywallStep: some View {
        Group {
            switch paywallPage {
            case 0: paywallUnifiedPage
            case 1: paywallReminderPage
            default: paywallPaymentPage
            }
        }
        .transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        ))
        .onAppear {
            if let email = AuthService.shared.userEmail {
                EmailAutomationService.shared.scheduleCartAbandonmentEmail(email: email, name: AuthService.shared.userFullName)
            }
        }
        .onChange(of: storeVM.isPremium) { _, isPremium in
            if isPremium {
                EmailAutomationService.shared.cancelCartAbandonment()
                appVM.hasCompletedOnboarding = true
                UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
            }
        }
        .alert("Purchase Error", isPresented: .init(
            get: { storeVM.error != nil },
            set: { if !$0 { storeVM.error = nil } }
        )) {
            Button("OK") { storeVM.error = nil }
        } message: {
            Text(storeVM.error ?? "")
        }
    }

    private var paywallUnifiedPage: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Button {
                        withAnimation { step = 24 }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 15, weight: .medium))
                            Text(Lang.s("back"))
                                .font(.system(size: 15))
                        }
                        .foregroundStyle(Color.black)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 8)

                    Text(selectedPlan == "yearly" ? Lang.s("paywall_trial_title") : Lang.s("paywall_unlock_title"))
                        .font(.system(size: 28, weight: .heavy))
                        .foregroundStyle(Color.black)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        .padding(.bottom, 32)
                        .animation(.easeInOut(duration: 0.2), value: selectedPlan)

                    if selectedPlan == "yearly" {
                        VStack(alignment: .leading, spacing: 0) {
                            trialTimelineItem(
                                icon: "lock.fill",
                                title: Lang.s("paywall_today"),
                                subtitle: Lang.s("paywall_today_desc"),
                                isLast: false,
                                isFilled: trialDotsAnimated[0]
                            )
                            trialTimelineItem(
                                icon: "bell.fill",
                                title: Lang.s("paywall_reminder"),
                                subtitle: Lang.s("paywall_reminder_desc"),
                                isLast: false,
                                isFilled: trialDotsAnimated[1]
                            )
                            trialTimelineItem(
                                icon: "crown.fill",
                                title: Lang.s("paywall_billing"),
                                subtitle: "\(Lang.s("paywall_billing_desc")) \(billingDate) \(Lang.s("paywall_billing_suffix"))",
                                isLast: true,
                                isFilled: trialDotsAnimated[2]
                            )
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)
                        .transition(.opacity.combined(with: .move(edge: .trailing)))
                        .onAppear {
                            trialDotsAnimated = [false, false, false]
                            Task {
                                try? await Task.sleep(for: .seconds(0.15))
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { trialDotsAnimated[0] = true }
                                try? await Task.sleep(for: .seconds(0.45))
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { trialDotsAnimated[1] = true }
                                try? await Task.sleep(for: .seconds(0.45))
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) { trialDotsAnimated[2] = true }
                            }
                        }
                    } else {
                        VStack(spacing: 20) {
                            paywallFeatureRow(emoji: "🧬", title: Lang.s("bio_age_feature"), subtitle: Lang.s("bio_age_desc"))
                            paywallFeatureRow(emoji: "📊", title: Lang.s("body_fat_feature"), subtitle: Lang.s("body_fat_desc"))
                            paywallFeatureRow(emoji: "💪", title: Lang.s("somatotype_feature"), subtitle: Lang.s("somatotype_desc"))
                            paywallFeatureRow(emoji: "📸", title: Lang.s("scan_food_feature"), subtitle: Lang.s("scan_food_desc"))
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 16)
                        .transition(.opacity.combined(with: .move(edge: .leading)))
                    }
                }
            }
            .scrollIndicators(.hidden)

            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    paywallPlanCard(plan: "monthly", title: Lang.s("monthly"), price: "9,99 €", unit: "/mo", badge: nil)
                    paywallPlanCard(plan: "yearly", title: Lang.s("yearly"), price: "4,16 €", unit: "/mo", badge: Lang.s("three_days_free"))
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)

                if selectedPlan == "yearly" {
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 13, weight: .semibold))
                        Text(Lang.s("no_payment_due"))
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundStyle(Color.black)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.bottom, 12)
                    .transition(.opacity)
                }

                Button {
                    if selectedPlan == "yearly" {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                            paywallPage = 1
                        }
                    } else {
                        EmailAutomationService.shared.cancelCartAbandonment()
                        Task {
                            if storeVM.offerings == nil {
                                await storeVM.fetchOfferings()
                            }
                            await storeVM.purchaseMonthly()
                        }
                    }
                } label: {
                    HStack(spacing: 10) {
                        if storeVM.isPurchasing && selectedPlan == "monthly" {
                            ProgressView()
                                .tint(.white)
                                .scaleEffect(0.85)
                        }
                        Text(selectedPlan == "yearly" ? Lang.s("start_trial") : Lang.s("start_journey"))
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.black)
                    .clipShape(.rect(cornerRadius: 28))
                    .animation(nil, value: selectedPlan)
                }
                .disabled(storeVM.isPurchasing)
                .padding(.horizontal, 20)

                Text(selectedPlan == "yearly" ? Lang.s("trial_price_yearly") : Lang.s("price_monthly"))
                    .font(.system(size: 12))
                    .foregroundStyle(Color(red: 0.55, green: 0.55, blue: 0.6))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 8)
                    .padding(.bottom, 40)
            }
            .background(Color(.systemBackground))
        }
    }

    private var paywallReminderPage: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    withAnimation { paywallPage = 0 }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 15, weight: .medium))
                        Text(Lang.s("back"))
                            .font(.system(size: 15))
                    }
                    .foregroundStyle(Color.black)
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)

            Spacer()

            Text(Lang.s("reminder_before_trial"))
                .font(.system(size: 28, weight: .heavy))
                .foregroundStyle(Color.black)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 28)
                .padding(.bottom, 48)

            ZStack(alignment: .topTrailing) {
                Image(systemName: "bell")
                    .font(.system(size: 100, weight: .thin))
                    .foregroundStyle(Color(red: 0.85, green: 0.85, blue: 0.88))
                    .scaleEffect(paywallBellAnimate ? 1.05 : 1.0)
                    .animation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true), value: paywallBellAnimate)

                ZStack {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 32, height: 32)
                    Text("1")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                }
                .offset(x: 8, y: -8)
            }
            .padding(.bottom, 16)

            Image(systemName: "ellipsis")
                .font(.system(size: 18))
                .foregroundStyle(Color(red: 0.85, green: 0.85, blue: 0.88))
                .padding(.bottom, 48)

            Spacer()

            VStack(spacing: 16) {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 13, weight: .semibold))
                    Text(Lang.s("no_payment_due"))
                        .font(.system(size: 14, weight: .semibold))
                }
                .foregroundStyle(Color.black)

                Button {
                    EmailAutomationService.shared.cancelCartAbandonment()
                    Task { await storeVM.purchaseYearly() }
                } label: {
                    HStack(spacing: 10) {
                        if storeVM.isPurchasing {
                            ProgressView()
                                .tint(.white)
                                .scaleEffect(0.85)
                        }
                        Text(Lang.s("continue_free"))
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.black)
                    .clipShape(.rect(cornerRadius: 28))
                }
                .disabled(storeVM.isPurchasing)

                Text(Lang.s("trial_price_yearly"))
                    .font(.system(size: 12))
                    .foregroundStyle(Color(red: 0.55, green: 0.55, blue: 0.6))
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 48)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            paywallBellAnimate = true
        }
    }

    private var paywallPaymentPage: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    withAnimation { paywallPage = 0 }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.left")
                            .font(.system(size: 15, weight: .medium))
                        Text(Lang.s("back"))
                            .font(.system(size: 15))
                    }
                    .foregroundStyle(Color.black)
                }
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)

            Spacer()

            VStack(spacing: 16) {
                Image(systemName: "creditcard.fill")
                    .font(.system(size: 64, weight: .thin))
                    .foregroundStyle(Color(red: 0.82, green: 0.82, blue: 0.85))

                Text(Lang.s("subscribe_mywellness"))
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color.black)
                    .multilineTextAlignment(.center)

                Text("€9,99 / month")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(Color.black)

                Text(Lang.s("cancel_anytime_settings"))
                    .font(.system(size: 13))
                    .foregroundStyle(Color(red: 0.5, green: 0.5, blue: 0.55))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Spacer()

            VStack(spacing: 12) {
                Button {
                    EmailAutomationService.shared.cancelCartAbandonment()
                    Task { await storeVM.purchaseMonthly() }
                } label: {
                    HStack(spacing: 10) {
                        if storeVM.isPurchasing {
                            ProgressView()
                                .tint(.white)
                                .scaleEffect(0.85)
                        }
                        Text(Lang.s("subscribe_now"))
                            .font(.system(size: 17, weight: .bold))
                            .foregroundStyle(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.black)
                    .clipShape(.rect(cornerRadius: 28))
                }
                .disabled(storeVM.isPurchasing)
                .padding(.horizontal, 20)

                Text(Lang.s("monthly_cancel"))
                    .font(.system(size: 12))
                    .foregroundStyle(Color(red: 0.55, green: 0.55, blue: 0.6))
                    .multilineTextAlignment(.center)
            }
            .padding(.bottom, 48)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var billingDate: String {
        let cal = Calendar.current
        guard let d = cal.date(byAdding: .day, value: 3, to: Date()) else { return "" }
        let fmt = DateFormatter()
        fmt.dateFormat = "d/M/yyyy"
        return fmt.string(from: d)
    }

    private func paywallFeatureRow(emoji: String, title: String, subtitle: String) -> some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.black)
                    .frame(width: 36, height: 36)
                Image(systemName: "checkmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
            }

            Text(emoji)
                .font(.system(size: 26))

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color.black)
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundStyle(Color(red: 0.45, green: 0.45, blue: 0.5))
            }

            Spacer()
        }
    }

    private func paywallPlanCard(plan: String, title: String, price: String, unit: String, badge: String?) -> some View {
        let isSelected = selectedPlan == plan
        return Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                selectedPlan = plan
            }
        } label: {
            ZStack(alignment: .topTrailing) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundStyle(Color.black)
                        Spacer()
                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(Color.black)
                        }
                    }

                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                        Text(price)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(Color.black)
                        Text(unit)
                            .font(.system(size: 13))
                            .foregroundStyle(Color(red: 0.45, green: 0.45, blue: 0.5))
                    }
                }
                .padding(16)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(isSelected ? Color(red: 0.94, green: 0.94, blue: 0.96) : Color.white)
                .clipShape(.rect(cornerRadius: 16))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isSelected ? Color.black : Color(red: 0.85, green: 0.85, blue: 0.88), lineWidth: isSelected ? 2 : 1)
                )

                if let badge = badge {
                    Text(badge)
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.black)
                        .clipShape(.rect(cornerRadius: 8))
                        .offset(x: -8, y: -12)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private func trialTimelineItem(icon: String, title: String, subtitle: String, isLast: Bool, isFilled: Bool = true) -> some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(isFilled ? Color.paywallOrange : Color(red: 0.85, green: 0.85, blue: 0.88))
                        .frame(width: 44, height: 44)
                        .scaleEffect(isFilled ? 1.0 : 0.85)
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .medium))
                        .foregroundStyle(isFilled ? Color.white : Color(red: 0.6, green: 0.6, blue: 0.65))
                        .scaleEffect(isFilled ? 1.0 : 0.85)
                }
                if !isLast {
                    Rectangle()
                        .fill(isFilled ? Color.paywallOrange : Color(red: 0.85, green: 0.85, blue: 0.88))
                        .frame(width: 2, height: 40)
                }
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color.black)
                Text(subtitle)
                    .font(.system(size: 13))
                    .foregroundStyle(Color(red: 0.45, green: 0.45, blue: 0.5))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, 10)

            Spacer()
        }
        .padding(.bottom, isLast ? 0 : 0)
    }

    // MARK: - Step 2: Referral Source
    private let referralSourceItems: [(name: String, sf: String, r: Double, g: Double, b: Double)] = [
        ("App Store",            "apps.iphone",          0.00, 0.46, 1.00),
        ("Instagram",            "camera.fill",          0.76, 0.21, 0.52),
        ("YouTube",              "play.rectangle.fill",  0.90, 0.12, 0.12),
        ("TikTok",               "music.note",           0.01, 0.01, 0.01),
        ("Google",               "magnifyingglass",      0.26, 0.52, 0.96),
        ("TV",                   "tv.fill",              0.39, 0.39, 0.40),
        ("X (Twitter)",          "xmark.square.fill",    0.01, 0.01, 0.01),
        ("Facebook",             "hand.thumbsup.fill",   0.09, 0.46, 0.95),
        ("Amico o familiare",    "person.2.fill",        0.19, 0.69, 0.79),
        ("Podcast",              "mic.fill",             0.61, 0.35, 0.71),
        ("Reddit",               "bubble.left.fill",     1.00, 0.27, 0.00),
        ("Influencer / Creator", "star.fill",            0.96, 0.65, 0.14),
        ("Altro",                "ellipsis.circle.fill", 0.56, 0.56, 0.58),
    ]

    private var referralSourceStep: some View {
        VStack(alignment: .leading, spacing: 24) {
            quizHeader(title: Lang.s("where_heard"), subtitle: nil)
                .padding(.horizontal, 20)
                .padding(.top, 24)

            VStack(spacing: 10) {
                ForEach(referralSourceItems, id: \.name) { item in
                    let isSelected = referralSource == item.name
                    let accent = Color(red: item.r, green: item.g, blue: item.b)
                    Button {
                        referralSource = item.name
                    } label: {
                        HStack(spacing: 14) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(isSelected ? Color.white.opacity(0.18) : accent.opacity(0.12))
                                    .frame(width: 40, height: 40)
                                Image(systemName: item.sf)
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundStyle(isSelected ? Color.white : accent)
                            }
                            Text(item.name)
                                .font(.system(size: 16, weight: .medium))
                                .foregroundStyle(isSelected ? .white : Color.black)
                            Spacer()
                            if isSelected {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.white)
                                    .font(.title3)
                            }
                        }
                        .padding(.horizontal, 16)
                        .frame(height: 62)
                        .background(isSelected ? Color.black : Color.white)
                        .clipShape(.rect(cornerRadius: 14))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(isSelected ? Color.black : Color(red: 0.88, green: 0.88, blue: 0.90), lineWidth: isSelected ? 2 : 1)
                        )
                    }
                    .buttonStyle(.plain)
                    .conditionalSensoryFeedback(.selection, trigger: isSelected)
                    .animation(.easeInOut(duration: 0.15), value: isSelected)
                }
            }
            .padding(.horizontal, 20)
        }
    }

    // MARK: - Helper
    private func localizedActivityName(_ level: UserProfile.ActivityLevel) -> String {
        switch level {
        case .sedentary: return Lang.s("activity_sedentary")
        case .light: return Lang.s("activity_light")
        case .moderate: return Lang.s("activity_moderate")
        case .active: return Lang.s("activity_active")
        case .veryActive: return Lang.s("activity_very_active")
        }
    }

    private func localizedActivityDesc(_ level: UserProfile.ActivityLevel) -> String {
        switch level {
        case .sedentary: return Lang.s("activity_sedentary_desc")
        case .light: return Lang.s("activity_light_desc")
        case .moderate: return Lang.s("activity_moderate_desc")
        case .active: return Lang.s("activity_active_desc")
        case .veryActive: return Lang.s("activity_very_active_desc")
        }
    }

    private func quizHeader(title: String, subtitle: String?) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(Color.black)
            if let sub = subtitle {
                Text(sub)
                    .font(.system(size: 15))
                    .foregroundStyle(Color(red: 0.55, green: 0.55, blue: 0.60))
            }
        }
        .padding(.horizontal, 20)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - HealthKit Illustration
struct HealthKitIllustration: View {
    @State private var appeared: Bool = false

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height
            let cx = w / 2
            let cy = h / 2

            ZStack {
                Circle()
                    .fill(Color(red: 0.92, green: 0.91, blue: 0.97))
                    .frame(width: min(w, h) * 0.72, height: min(w, h) * 0.72)
                    .position(x: cx, y: cy)
                    .scaleEffect(appeared ? 1 : 0.8)
                    .opacity(appeared ? 1 : 0)
                    .animation(.spring(response: 0.7, dampingFraction: 0.75).delay(0.05), value: appeared)

                // App logo card (top right)
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.white)
                        .frame(width: 72, height: 72)
                        .shadow(color: .black.opacity(0.08), radius: 12, y: 4)
                    Image("AppLogoMWP")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 56, height: 56)
                        .clipShape(.rect(cornerRadius: 12, style: .continuous))
                }
                .position(x: cx + min(w, h) * 0.24, y: cy - min(w, h) * 0.20)
                .scaleEffect(appeared ? 1 : 0.6)
                .opacity(appeared ? 1 : 0)
                .animation(.spring(response: 0.65, dampingFraction: 0.72).delay(0.12), value: appeared)

                // Heart card (bottom left)
                ZStack {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(Color.white)
                        .frame(width: 72, height: 72)
                        .shadow(color: .black.opacity(0.08), radius: 12, y: 4)
                    Image(systemName: "heart.fill")
                        .font(.system(size: 30))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(red: 1.0, green: 0.28, blue: 0.42), Color(red: 0.98, green: 0.55, blue: 0.38)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .position(x: cx - min(w, h) * 0.28, y: cy + min(w, h) * 0.18)
                .scaleEffect(appeared ? 1 : 0.6)
                .opacity(appeared ? 1 : 0)
                .animation(.spring(response: 0.65, dampingFraction: 0.72).delay(0.18), value: appeared)

                // Center checkmark
                ZStack {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 48, height: 48)
                        .shadow(color: .black.opacity(0.10), radius: 8, y: 2)
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(Color(red: 0.10, green: 0.10, blue: 0.12))
                }
                .position(x: cx, y: cy)
                .scaleEffect(appeared ? 1 : 0.4)
                .opacity(appeared ? 1 : 0)
                .animation(.spring(response: 0.55, dampingFraction: 0.68).delay(0.30), value: appeared)

                // Floating labels
                floatingLabel(Lang.s("walking"), sf: "figure.walk")
                    .position(x: cx - min(w, h) * 0.26, y: cy - min(w, h) * 0.28)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 8)
                    .animation(.easeOut(duration: 0.4).delay(0.22), value: appeared)

                floatingLabel(Lang.s("running"), sf: "figure.run")
                    .position(x: cx - min(w, h) * 0.30, y: cy - min(w, h) * 0.08)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 8)
                    .animation(.easeOut(duration: 0.4).delay(0.28), value: appeared)

                floatingLabel(Lang.s("yoga"), sf: "figure.mind.and.body")
                    .position(x: cx + min(w, h) * 0.28, y: cy + min(w, h) * 0.06)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 8)
                    .animation(.easeOut(duration: 0.4).delay(0.34), value: appeared)

                floatingLabel(Lang.s("sleep"), sf: "moon.zzz.fill")
                    .position(x: cx + min(w, h) * 0.24, y: cy + min(w, h) * 0.25)
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 8)
                    .animation(.easeOut(duration: 0.4).delay(0.40), value: appeared)
            }
        }
        .onAppear { appeared = true }
    }

    private func floatingLabel(_ text: String, sf: String) -> some View {
        HStack(spacing: 5) {
            Image(systemName: sf)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(Color(red: 0.35, green: 0.35, blue: 0.40))
            Text(text)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(Color(red: 0.15, green: 0.15, blue: 0.18))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.white)
        .clipShape(.rect(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.07), radius: 6, y: 2)
    }
}

// MARK: - Weight Chart
private struct WeightChartView: View {
    @State private var drawProgress: Double = 0

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            let points: [CGPoint] = [
                CGPoint(x: w * 0.05, y: h * 0.85),
                CGPoint(x: w * 0.25, y: h * 0.72),
                CGPoint(x: w * 0.50, y: h * 0.55),
                CGPoint(x: w * 0.85, y: h * 0.15),
            ]

            ZStack {
                Path { p in
                    p.move(to: CGPoint(x: points[0].x, y: h))
                    p.addLine(to: points[0])
                    for i in 1..<points.count {
                        let prev = points[i - 1]
                        let cur = points[i]
                        let ctrl1 = CGPoint(x: prev.x + (cur.x - prev.x) * 0.4, y: prev.y)
                        let ctrl2 = CGPoint(x: cur.x - (cur.x - prev.x) * 0.4, y: cur.y)
                        p.addCurve(to: cur, control1: ctrl1, control2: ctrl2)
                    }
                    p.addLine(to: CGPoint(x: points.last!.x, y: h))
                    p.closeSubpath()
                }
                .fill(Color(red: 0.20, green: 0.70, blue: 0.65).opacity(0.12 * drawProgress))

                Path { p in
                    p.move(to: points[0])
                    for i in 1..<points.count {
                        let prev = points[i - 1]
                        let cur = points[i]
                        let ctrl1 = CGPoint(x: prev.x + (cur.x - prev.x) * 0.4, y: prev.y)
                        let ctrl2 = CGPoint(x: cur.x - (cur.x - prev.x) * 0.4, y: cur.y)
                        p.addCurve(to: cur, control1: ctrl1, control2: ctrl2)
                    }
                }
                .trim(from: 0, to: drawProgress)
                .stroke(Color(red: 0.20, green: 0.70, blue: 0.65), style: StrokeStyle(lineWidth: 2.5, lineCap: .round))

                Path { p in
                    p.move(to: CGPoint(x: 0, y: h * 0.45))
                    p.addLine(to: CGPoint(x: w, y: h * 0.45))
                }
                .stroke(Color(red: 0.75, green: 0.75, blue: 0.78), style: StrokeStyle(lineWidth: 1, dash: [4, 4]))

                ForEach(points.indices.dropLast(), id: \.self) { i in
                    Circle()
                        .fill(Color.white)
                        .frame(width: 10, height: 10)
                        .overlay(Circle().stroke(Color(red: 0.20, green: 0.70, blue: 0.65), lineWidth: 2))
                        .position(points[i])
                }

                Image(systemName: "heart.fill")
                    .font(.system(size: 22))
                    .foregroundStyle(Color(red: 0.20, green: 0.60, blue: 0.58))
                    .position(points.last!)
                    .offset(y: -14)
                    .opacity(drawProgress)
            }
        }
        .onAppear {
            drawProgress = 0
            withAnimation(.easeInOut(duration: 1.5).delay(0.2)) {
                drawProgress = 1.0
            }
        }
    }
}
