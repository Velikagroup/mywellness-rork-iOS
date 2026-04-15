import Foundation
import SwiftUI
import WidgetKit

@Observable
@MainActor
class AppViewModel {
    var hasCompletedOnboarding: Bool = false
    var userProfile: UserProfile = UserProfile()
    var nutritionPlan: NutritionPlan = NutritionPlan()

    var hasCompletedBodyScan: Bool {
        !bodyScanHistory.isEmpty
    }

    var hasExistingProfile: Bool {
        UserDefaults.standard.data(forKey: profileKey) != nil
    }
    var workoutPlan: WorkoutPlan = WorkoutPlan()
    var weightHistory: [WeightEntry] = []
    var todayLog: DayLog = DayLog()
    var isGeneratingPlan: Bool = false
    var generationError: String?
    private var generationTask: Task<Void, Never>?
    var isGeneratingMealImages: Bool = false
    private var mealImageGenerationId: UUID = UUID()
    var quizPreferences: MealPlanQuizPreferences?
    var workoutQuizPreferences: WorkoutQuizPreferences?
    var selectedTabIndex: Int = 0
    var shouldOpenCameraHub: Bool = false
    var healthActiveCalories: Double = 0
    var healthSnapshot: HealthSnapshot = HealthSnapshot()
    var memojiImages: [String: Data] = [:]
    var mealScannedImages: [String: Data] = [:]
    var dailySnapshots: [String: DaySnapshot] = [:]
    var shoppingListItems: [ShoppingListItem] = []
    var pantryItems: [PantryItem] = []
    var bodyScanHistory: [BodyScanRecord] = []
    var foodScanHistory: [FoodScanRecord] = []
    var foodProductScanHistory: [FoodProductScanRecord] = []
    var todaySessionOverride: WorkoutDay?
    var todaySessionOverrideDate: String?
    var isModifyingSession: Bool = false
    var sessionModificationError: String?
    var pendingScanPlan: NutritionPlan?
    var isPendingPlanAccepted: Bool = false
    var wearableDeviceEnabled: Bool = false
    private var midnightTask: Task<Void, Never>?

    private let profileKey = "userProfile"
    private let nutritionKey = "nutritionPlan"
    private let workoutKey = "workoutPlan"
    private let weightKey = "weightHistory"
    private let logKey = "todayLog"
    private let onboardingKey = "hasCompletedOnboarding"
    private let memojiImagesKey = "memojiImages"
    private let memojiLegacyKey = "memojiImageData"
    private let mealImagesKey = "mealScannedImages"
    private let dailySnapshotsKey = "dailySnapshots"
    private let shoppingListKey = "shoppingListItems"
    private let pantryKey = "pantryItems"
    private let bodyScanHistoryKey = "bodyScanHistory"
    private let foodScanHistoryKey = "foodScanHistory"
    private let foodProductScanHistoryKey = "foodProductScanHistory"
    private let sessionOverrideKey = "todaySessionOverride"
    private let sessionOverrideDateKey = "todaySessionOverrideDate"
    private let pendingScanPlanKey = "pendingScanPlan"
    private let wearableDeviceKey = "wearableDeviceEnabled"

    init() {
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        wearableDeviceEnabled = UserDefaults.standard.bool(forKey: wearableDeviceKey)
        loadAll()
        Task {
            await fetchHealthData()
        }
        scheduleMidnightRollover()
    }

    func fetchHealthData() async {
        healthSnapshot = await HealthKitService.shared.fetchAllHealthData()
        healthActiveCalories = healthSnapshot.activeCalories
        syncWidgetData()
    }

    var wellnessResult: (parameters: [WellnessParameter], score: Double, mood: WellnessMood) {
        WellnessScoreEngine.compute(snapshot: healthSnapshot, profile: userProfile, calorieBalance: calorieBalance, wearableEnabled: wearableDeviceEnabled)
    }

    func toggleWearableDevice(_ enabled: Bool) {
        wearableDeviceEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: wearableDeviceKey)
    }

    var wellnessMood: WellnessMood { wellnessResult.mood }
    var wellnessParameters: [WellnessParameter] { wellnessResult.parameters }
    var wellnessScore: Double { wellnessResult.score }

    func saveMemojiImages(_ images: [String: Data]) {
        memojiImages = images
        UserDefaults.standard.set(images, forKey: memojiImagesKey)
    }

    func memojiUIImage(for mood: WellnessMood) -> UIImage? {
        let fallbackOrder: [WellnessMood]
        switch mood {
        case .excellent: fallbackOrder = [.excellent, .good, .fair, .poor]
        case .good:      fallbackOrder = [.good, .excellent, .fair, .poor]
        case .fair:      fallbackOrder = [.fair, .good, .poor, .excellent]
        case .poor:      fallbackOrder = [.poor, .fair, .good, .excellent]
        }
        for candidate in fallbackOrder {
            if let data = memojiImages[candidate.storageKey], let img = UIImage(data: data) {
                return img
            }
        }
        return nil
    }

    func saveProfile(_ profile: UserProfile) {
        userProfile = profile
        hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: onboardingKey)
        weightHistory = DefaultData.defaultWeightHistory(for: profile)
        weightHistory.append(WeightEntry(date: Date(), weightKg: profile.currentWeightKg))
        saveAll()
        generationTask = Task {
            await regeneratePlans()
        }
    }

    func prepareProfile(_ profile: UserProfile) {
        userProfile = profile
        weightHistory = DefaultData.defaultWeightHistory(for: profile)
        weightHistory.append(WeightEntry(date: Date(), weightKg: profile.currentWeightKg))
        saveAll()
        generationTask = Task {
            await regeneratePlans()
        }
    }

    func regeneratePlans() async {
        isGeneratingPlan = true
        generationError = nil

        let generated = WorkoutPlanGenerator.generateSafe(profile: userProfile, preferences: workoutQuizPreferences)
        let localized = WorkoutLocalization.localizePlanSafe(generated)
        workoutPlan = localized.days.isEmpty ? WorkoutLocalization.localizePlanSafe(DefaultData.workoutPlan(for: userProfile)) : localized

        isGeneratingPlan = false
        saveAll()
    }

    func cancelGeneration() {
        generationTask?.cancel()
        generationTask = nil
        isGeneratingPlan = false
        generationError = nil
        saveAll()
    }

    func generatePlanFromBodyScan() {
        let plan = MealPlanGenerator.generateSafe(profile: userProfile, preferences: quizPreferences)
        if plan.days.isEmpty {
            pendingScanPlan = DefaultData.nutritionPlan(for: userProfile)
        } else {
            pendingScanPlan = plan
        }
        isPendingPlanAccepted = false
        savePendingScanPlan()
    }

    func generatePlanFromBodyScanSafe() {
        let fallbackPlan = DefaultData.nutritionPlan(for: userProfile)
        let plan: NutritionPlan
        let generated = MealPlanGenerator.generateSafe(profile: userProfile, preferences: quizPreferences)
        plan = generated.days.isEmpty ? fallbackPlan : generated
        pendingScanPlan = plan
        isPendingPlanAccepted = false
        savePendingScanPlan()
    }

    func acceptPendingPlan() {
        guard let plan = pendingScanPlan else { return }
        nutritionPlan = MealImageService.shared.assignCachedImages(to: plan)
        pendingScanPlan = nil
        isPendingPlanAccepted = true
        todayLog = DayLog()
        saveNutrition()
        saveTodayLog()
        savePendingScanPlan()
        syncWidgetData()
        generateMealImages()
    }

    private func savePendingScanPlan() {
        if let plan = pendingScanPlan, let data = try? JSONEncoder().encode(plan) {
            UserDefaults.standard.set(data, forKey: pendingScanPlanKey)
        } else {
            UserDefaults.standard.removeObject(forKey: pendingScanPlanKey)
        }
    }

    func regenerateWithQuiz(preferences: MealPlanQuizPreferences) async throws {
        quizPreferences = preferences
        isGeneratingPlan = true
        generationError = nil

        let generated = MealPlanGenerator.generateSafe(profile: userProfile, preferences: preferences)
        nutritionPlan = generated.days.isEmpty ? DefaultData.nutritionPlan(for: userProfile) : generated

        nutritionPlan = MealImageService.shared.assignCachedImages(to: nutritionPlan)
        pendingScanPlan = nil
        savePendingScanPlan()
        todayLog = DayLog()
        isGeneratingPlan = false
        saveAll()
        generateMealImages()
    }

    func regenerateWorkoutWithQuiz(preferences: WorkoutQuizPreferences) async throws {
        workoutQuizPreferences = preferences
        isGeneratingPlan = true
        generationError = nil
        let generated = WorkoutPlanGenerator.generateSafe(profile: userProfile, preferences: preferences)
        let localized = WorkoutLocalization.localizePlanSafe(generated)
        workoutPlan = localized.days.isEmpty ? WorkoutLocalization.localizePlanSafe(DefaultData.workoutPlan(for: userProfile)) : localized
        isGeneratingPlan = false
        saveAll()
    }

    func toggleMealCompletion(mealId: UUID) {
        if todayLog.completedMealIds.contains(mealId) {
            todayLog.completedMealIds.remove(mealId)
        } else {
            todayLog.completedMealIds.insert(mealId)
            todayLog.caloriesConsumed = todayCaloriesConsumed
        }
        saveTodayLog()
    }

    func toggleExerciseCompletion(dayIndex: Int, exerciseId: UUID) {
        guard dayIndex < workoutPlan.days.count else { return }
        if let idx = workoutPlan.days[dayIndex].exercises.firstIndex(where: { $0.id == exerciseId }) {
            workoutPlan.days[dayIndex].exercises[idx].isCompleted.toggle()
        }
        saveWorkout()
    }

    func toggleSetCompletion(dayIndex: Int, exerciseId: UUID, setNumber: Int) {
        guard dayIndex < workoutPlan.days.count else { return }
        guard let idx = workoutPlan.days[dayIndex].exercises.firstIndex(where: { $0.id == exerciseId }) else { return }
        if workoutPlan.days[dayIndex].exercises[idx].completedSets.contains(setNumber) {
            workoutPlan.days[dayIndex].exercises[idx].completedSets.remove(setNumber)
            workoutPlan.days[dayIndex].exercises[idx].isCompleted = false
        } else {
            workoutPlan.days[dayIndex].exercises[idx].completedSets.insert(setNumber)
            let ex = workoutPlan.days[dayIndex].exercises[idx]
            if ex.completedSets.count >= ex.sets {
                workoutPlan.days[dayIndex].exercises[idx].isCompleted = true
            }
        }
        saveWorkout()
    }

    func deleteExercise(dayIndex: Int, exerciseId: UUID) {
        guard dayIndex < workoutPlan.days.count else { return }
        workoutPlan.days[dayIndex].exercises.removeAll { $0.id == exerciseId }
        saveWorkout()
    }

    func addExercise(dayIndex: Int, exercise: Exercise) {
        guard dayIndex < workoutPlan.days.count else { return }
        let insertIndex = workoutPlan.days[dayIndex].exercises.lastIndex(where: { $0.category == .main }) ?? workoutPlan.days[dayIndex].exercises.count
        workoutPlan.days[dayIndex].exercises.insert(exercise, at: insertIndex + 1)
        saveWorkout()
    }

    func replaceExercise(dayIndex: Int, exerciseId: UUID, newExercise: Exercise) {
        guard dayIndex < workoutPlan.days.count else { return }
        guard let idx = workoutPlan.days[dayIndex].exercises.firstIndex(where: { $0.id == exerciseId }) else { return }
        var replacement = newExercise
        replacement.category = workoutPlan.days[dayIndex].exercises[idx].category
        workoutPlan.days[dayIndex].exercises[idx] = replacement
        saveWorkout()
    }

    func completeWorkout(dayIndex: Int) {
        guard dayIndex < workoutPlan.days.count else { return }
        for i in workoutPlan.days[dayIndex].exercises.indices {
            let ex = workoutPlan.days[dayIndex].exercises[i]
            workoutPlan.days[dayIndex].exercises[i].isCompleted = true
            for s in 1...max(ex.sets, 1) {
                workoutPlan.days[dayIndex].exercises[i].completedSets.insert(s)
            }
        }
        saveWorkout()
    }

    func addWeightEntry(_ weightKg: Double) {
        let entry = WeightEntry(date: Date(), weightKg: weightKg)
        weightHistory.append(entry)
        userProfile.currentWeightKg = weightKg
        saveAll()
    }

    var todayDayPlan: DayPlan? {
        let weekday = Calendar.current.component(.weekday, from: Date())
        let days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        let dayName = days[weekday - 1]
        return nutritionPlan.days.first { $0.dayName == dayName }
    }

    var todayWorkoutDay: WorkoutDay? {
        let weekday = Calendar.current.component(.weekday, from: Date())
        let days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        let dayName = days[weekday - 1]
        return workoutPlan.days.first { $0.dayName == dayName }
    }

    var todayCaloriesConsumed: Int {
        guard let plan = todayDayPlan else { return 0 }
        return plan.meals
            .filter { todayLog.completedMealIds.contains($0.id) }
            .reduce(0) { $0 + $1.calories }
    }

    var todayPlannedCalories: Int {
        let photoExtra = todayLog.photoScannedCalories
        guard let plan = todayDayPlan else { return photoExtra }
        return plan.meals.reduce(0) { total, meal in
            total + (todayLog.mealCalorieOverrides[meal.id.uuidString] ?? meal.calories)
        } + photoExtra
    }

    func addPhotoCalories(_ calories: Int) {
        todayLog.photoScannedCalories += calories
        saveTodayLog()
    }

    func addScannedCaloriesForMeal(mealId: UUID, scannedCalories: Int, imageData: Data? = nil) {
        todayLog.completedMealIds.insert(mealId)
        todayLog.mealCalorieOverrides[mealId.uuidString] = scannedCalories
        todayLog.caloriesConsumed = todayCaloriesConsumed
        if let data = imageData {
            mealScannedImages[mealId.uuidString] = data
            UserDefaults.standard.set(mealScannedImages, forKey: mealImagesKey)
        }
        saveTodayLog()
    }

    var effectiveBMR: Double {
        if healthSnapshot.basalCalories > 0 {
            return healthSnapshot.basalCalories
        }
        return userProfile.bmr
    }

    var effectiveTDEE: Double {
        effectiveBMR * userProfile.activityLevel.multiplier
    }

    var healthSurplus: Double {
        let neat = effectiveTDEE - effectiveBMR
        guard healthActiveCalories > neat else { return 0 }
        return healthActiveCalories - neat
    }

    var totalCaloriesBurned: Double {
        effectiveTDEE + healthSurplus
    }

    var todayCaloriesBurned: Int {
        Int(totalCaloriesBurned)
    }

    var calorieBalance: Int {
        todayPlannedCalories - Int(totalCaloriesBurned)
    }

    var balanceLabel: String {
        let balance = calorieBalance
        if balance < -700 { return Lang.s("strong_deficit") }
        if balance < -300 { return Lang.s("moderate_deficit") }
        if balance < 100 { return Lang.s("on_target") }
        if balance < 400 { return Lang.s("moderate_surplus") }
        return Lang.s("strong_surplus")
    }

    var balanceLabelColor: Color {
        let balance = calorieBalance
        if balance < -300 { return Color(red: 0.17, green: 0.60, blue: 0.52) }
        if balance < 100 { return .blue }
        return .orange
    }

    private func loadAll() {
        if let data = UserDefaults.standard.data(forKey: profileKey),
           let decoded = try? JSONDecoder().decode(UserProfile.self, from: data) {
            userProfile = decoded
        }
        if let data = UserDefaults.standard.data(forKey: nutritionKey),
           let decoded = try? JSONDecoder().decode(NutritionPlan.self, from: data) {
            let normalizedDays = decoded.days.map { DayPlan(id: $0.id, dayName: DayNameNormalizer.normalize($0.dayName), meals: $0.meals) }
            nutritionPlan = NutritionPlan(days: normalizedDays, createdAt: decoded.createdAt)
        }
        if let data = UserDefaults.standard.data(forKey: workoutKey),
           let decoded = try? JSONDecoder().decode(WorkoutPlan.self, from: data) {
            workoutPlan = decoded
        }
        if let data = UserDefaults.standard.data(forKey: weightKey),
           let decoded = try? JSONDecoder().decode([WeightEntry].self, from: data) {
            weightHistory = decoded
        }
        if let data = UserDefaults.standard.data(forKey: dailySnapshotsKey),
           let decoded = try? JSONDecoder().decode([String: DaySnapshot].self, from: data) {
            dailySnapshots = decoded
        }
        if let data = UserDefaults.standard.data(forKey: logKey),
           let decoded = try? JSONDecoder().decode(DayLog.self, from: data) {
            let calendar = Calendar.current
            if calendar.isDateInToday(decoded.date) {
                todayLog = decoded
            } else {
                archiveLogAsSnapshot(decoded)
            }
        }
        if let dict = UserDefaults.standard.object(forKey: memojiImagesKey) as? [String: Data] {
            memojiImages = dict
        } else if let legacy = UserDefaults.standard.data(forKey: memojiLegacyKey) {
            memojiImages = [WellnessMood.good.storageKey: legacy]
        }
        if let dict = UserDefaults.standard.object(forKey: mealImagesKey) as? [String: Data] {
            mealScannedImages = dict
        }
        if let data = UserDefaults.standard.data(forKey: shoppingListKey),
           let decoded = try? JSONDecoder().decode([ShoppingListItem].self, from: data) {
            shoppingListItems = decoded
        }
        if let data = UserDefaults.standard.data(forKey: pantryKey),
           let decoded = try? JSONDecoder().decode([PantryItem].self, from: data) {
            pantryItems = decoded
        }
        if let data = UserDefaults.standard.data(forKey: bodyScanHistoryKey),
           let decoded = try? JSONDecoder().decode([BodyScanRecord].self, from: data) {
            bodyScanHistory = decoded
        }
        if let data = UserDefaults.standard.data(forKey: foodScanHistoryKey),
           let decoded = try? JSONDecoder().decode([FoodScanRecord].self, from: data) {
            foodScanHistory = decoded
        }
        if let data = UserDefaults.standard.data(forKey: foodProductScanHistoryKey),
           let decoded = try? JSONDecoder().decode([FoodProductScanRecord].self, from: data) {
            foodProductScanHistory = decoded
        }
        if let data = UserDefaults.standard.data(forKey: pendingScanPlanKey),
           let decoded = try? JSONDecoder().decode(NutritionPlan.self, from: data) {
            pendingScanPlan = decoded
        }
        loadSessionOverride()
    }

    func checkDayRollover() {
        guard let data = UserDefaults.standard.data(forKey: logKey),
              let decoded = try? JSONDecoder().decode(DayLog.self, from: data) else { return }
        let calendar = Calendar.current
        if !calendar.isDateInToday(decoded.date) {
            archiveLogAsSnapshot(decoded)
            todayLog = DayLog()
            clearSessionOverride()
            saveTodayLog()
            scheduleMidnightRollover()
        }
    }

    private func archiveLogAsSnapshot(_ log: DayLog) {
        let key = DateFormatter.dayKey.string(from: log.date)
        guard dailySnapshots[key] == nil else { return }
        let plan = dayPlan(for: log.date)
        var protein: Double = 0
        var carbs: Double = 0
        var fat: Double = 0
        if let plan {
            let completed = plan.meals.filter { log.completedMealIds.contains($0.id) }
            protein = completed.reduce(0) { $0 + $1.protein }
            carbs = completed.reduce(0) { $0 + $1.carbs }
            fat = completed.reduce(0) { $0 + $1.fat }
        }
        let caloriesConsumed: Int
        if let plan {
            caloriesConsumed = plan.meals
                .filter { log.completedMealIds.contains($0.id) }
                .reduce(0) { $0 + (log.mealCalorieOverrides[$1.id.uuidString] ?? $1.calories) }
        } else {
            caloriesConsumed = log.caloriesConsumed
        }
        let snap = DaySnapshot(
            date: log.date,
            wellnessScore: dailySnapshots[key]?.wellnessScore ?? 0.5,
            caloriesConsumed: caloriesConsumed + log.photoScannedCalories,
            caloriesBurned: Int(totalCaloriesBurned),
            completedMealCount: log.completedMealIds.count,
            totalMealCount: plan?.meals.count ?? 0,
            proteinConsumed: protein,
            carbsConsumed: carbs,
            fatConsumed: fat,
            photoScannedCalories: log.photoScannedCalories,
            weightKg: weightHistory.last(where: { Calendar.current.isDate($0.date, inSameDayAs: log.date) })?.weightKg ?? weightHistory.last?.weightKg
        )
        dailySnapshots[key] = snap
        if let data = try? JSONEncoder().encode(dailySnapshots) {
            UserDefaults.standard.set(data, forKey: dailySnapshotsKey)
        }
    }

    private func dayPlan(for date: Date) -> DayPlan? {
        let days = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        let weekday = Calendar.current.component(.weekday, from: date)
        let dayName = days[weekday - 1]
        return nutritionPlan.days.first { $0.dayName == dayName }
    }

    private func scheduleMidnightRollover() {
        midnightTask?.cancel()
        midnightTask = Task { [weak self] in
            guard let self else { return }
            let calendar = Calendar.current
            let now = Date()
            guard let tomorrow = calendar.nextDate(
                after: now,
                matching: DateComponents(hour: 0, minute: 0, second: 0),
                matchingPolicy: .nextTime
            ) else { return }
            let interval = tomorrow.timeIntervalSince(now)
            guard interval > 0 else { return }
            do {
                try await Task.sleep(for: .seconds(interval))
            } catch {
                return
            }
            guard !Task.isCancelled else { return }
            self.saveCurrentDaySnapshot()
            self.todayLog = DayLog()
            self.clearSessionOverride()
            self.saveTodayLog()
            self.scheduleMidnightRollover()
        }
    }

    func saveCurrentProfile() {
        if let data = try? JSONEncoder().encode(userProfile) {
            UserDefaults.standard.set(data, forKey: profileKey)
        }
        syncWidgetData()
    }

    private let widgetGroupID = "group.app.rork.zdxfa09dhovxfuxepqeqb"

    func syncWidgetData() {
        guard let shared = UserDefaults(suiteName: widgetGroupID) else { return }
        shared.set(Int(healthSnapshot.steps), forKey: "widget_steps")
        shared.set(Int(healthSnapshot.restingHeartRate), forKey: "widget_bpm")
        shared.set(healthSnapshot.sleepHours, forKey: "widget_sleepHours")
        shared.set(Int(healthSnapshot.activeCalories), forKey: "widget_activeCalories")
        shared.set(calorieBalance, forKey: "widget_calorieBalance")
        shared.set(wellnessScore, forKey: "widget_wellnessScore")
        shared.set(wellnessMood.moodLabel, forKey: "widget_moodLabel")
        shared.set(wellnessMood.storageKey, forKey: "widget_moodKey")
        let moodColor = wellnessMood.uiColor
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0
        moodColor.getRed(&r, green: &g, blue: &b, alpha: nil)
        shared.set(Double(r), forKey: "widget_moodColorR")
        shared.set(Double(g), forKey: "widget_moodColorG")
        shared.set(Double(b), forKey: "widget_moodColorB")
        shared.set(userProfile.bmi, forKey: "widget_bmi")
        if let memojiImage = memojiUIImage(for: wellnessMood),
           let pngData = memojiImage.pngData() {
            shared.set(pngData, forKey: "widget_memojiData")
        }
        WidgetCenter.shared.reloadAllTimelines()
    }

    private func saveAll() {
        saveProfile()
        saveNutrition()
        saveWorkout()
        saveWeights()
        saveTodayLog()
        saveCurrentDaySnapshot()
        syncWidgetData()
    }

    func saveCurrentDaySnapshot() {
        let key = DateFormatter.dayKey.string(from: Date())
        var protein: Double = 0
        var carbs: Double = 0
        var fat: Double = 0
        if let plan = todayDayPlan {
            let completed = plan.meals.filter { todayLog.completedMealIds.contains($0.id) }
            protein = completed.reduce(0) { $0 + $1.protein }
            carbs = completed.reduce(0) { $0 + $1.carbs }
            fat = completed.reduce(0) { $0 + $1.fat }
        }
        let snap = DaySnapshot(
            date: Date(),
            wellnessScore: wellnessScore,
            caloriesConsumed: todayCaloriesConsumed,
            caloriesBurned: Int(totalCaloriesBurned),
            completedMealCount: todayLog.completedMealIds.count,
            totalMealCount: todayDayPlan?.meals.count ?? 0,
            proteinConsumed: protein,
            carbsConsumed: carbs,
            fatConsumed: fat,
            photoScannedCalories: todayLog.photoScannedCalories,
            weightKg: weightHistory.last?.weightKg
        )
        dailySnapshots[key] = snap
        if let data = try? JSONEncoder().encode(dailySnapshots) {
            UserDefaults.standard.set(data, forKey: dailySnapshotsKey)
        }
    }

    func snapshot(for date: Date) -> DaySnapshot? {
        guard !Calendar.current.isDateInToday(date) else { return nil }
        let key = DateFormatter.dayKey.string(from: date)
        return dailySnapshots[key]
    }

    private func saveProfile() {
        if let data = try? JSONEncoder().encode(userProfile) {
            UserDefaults.standard.set(data, forKey: profileKey)
        }
    }

    func generateMealImages() {
        isGeneratingMealImages = true
        let generationId = UUID()
        mealImageGenerationId = generationId
        MealImageService.shared.generateImagesForPlan(nutritionPlan) { [weak self] updatedPlan in
            guard let self, self.mealImageGenerationId == generationId else { return }
            self.nutritionPlan = updatedPlan
            self.saveNutrition()
        }
        Task {
            try? await Task.sleep(for: .seconds(300))
            isGeneratingMealImages = false
        }
    }

    private func saveNutrition() {
        if let data = try? JSONEncoder().encode(nutritionPlan) {
            UserDefaults.standard.set(data, forKey: nutritionKey)
        }
    }

    private func saveWorkout() {
        if let data = try? JSONEncoder().encode(workoutPlan) {
            UserDefaults.standard.set(data, forKey: workoutKey)
        }
    }

    private func saveWeights() {
        if let data = try? JSONEncoder().encode(weightHistory) {
            UserDefaults.standard.set(data, forKey: weightKey)
        }
    }

    private func saveTodayLog() {
        if let data = try? JSONEncoder().encode(todayLog) {
            UserDefaults.standard.set(data, forKey: logKey)
        }
    }

    func addDayToShoppingList(dayPlan: DayPlan) {
        let newItems = dayPlan.meals.flatMap { meal in
            meal.ingredients.map { ingredient in
                ShoppingListItem(
                    name: ingredient.name,
                    amount: "\(String(format: "%.0f", ingredient.amount)) \(ingredient.unit)",
                    category: ShoppingListItem.category(for: ingredient.name)
                )
            }
        }
        for item in newItems {
            if !shoppingListItems.contains(where: { $0.name.lowercased() == item.name.lowercased() }) {
                shoppingListItems.append(item)
            }
        }
        saveShoppingList()
    }

    func addWeekToShoppingList() {
        for day in nutritionPlan.days {
            addDayToShoppingList(dayPlan: day)
        }
    }

    func toggleShoppingItem(id: UUID) {
        if let idx = shoppingListItems.firstIndex(where: { $0.id == id }) {
            shoppingListItems[idx].isChecked.toggle()
            saveShoppingList()
        }
    }

    func clearShoppingList() {
        shoppingListItems = []
        saveShoppingList()
    }

    func addPantryItem(_ item: PantryItem) {
        pantryItems.append(item)
        savePantry()
    }

    func deletePantryItem(id: UUID) {
        pantryItems.removeAll { $0.id == id }
        savePantry()
    }

    func updatePantryItem(_ item: PantryItem) {
        if let idx = pantryItems.firstIndex(where: { $0.id == item.id }) {
            pantryItems[idx] = item
            savePantry()
        }
    }


    private func saveShoppingList() {
        if let data = try? JSONEncoder().encode(shoppingListItems) {
            UserDefaults.standard.set(data, forKey: shoppingListKey)
        }
    }

    private func savePantry() {
        if let data = try? JSONEncoder().encode(pantryItems) {
            UserDefaults.standard.set(data, forKey: pantryKey)
        }
    }

    func addBodyScanRecord(_ result: BodyScan2Result) {
        let record = BodyScanRecord(from: result)
        bodyScanHistory.append(record)
        if let data = try? JSONEncoder().encode(bodyScanHistory) {
            UserDefaults.standard.set(data, forKey: bodyScanHistoryKey)
        }
    }

    func addFoodScanRecord(_ record: FoodScanRecord) {
        foodScanHistory.append(record)
        if let data = try? JSONEncoder().encode(foodScanHistory) {
            UserDefaults.standard.set(data, forKey: foodScanHistoryKey)
        }
    }

    func updateFoodScanRecord(_ record: FoodScanRecord) {
        if let idx = foodScanHistory.firstIndex(where: { $0.id == record.id }) {
            foodScanHistory[idx] = record
            if let data = try? JSONEncoder().encode(foodScanHistory) {
                UserDefaults.standard.set(data, forKey: foodScanHistoryKey)
            }
        }
    }

    func deleteFoodScanRecord(id: UUID) {
        foodScanHistory.removeAll { $0.id == id }
        if let data = try? JSONEncoder().encode(foodScanHistory) {
            UserDefaults.standard.set(data, forKey: foodScanHistoryKey)
        }
    }

    func addFoodProductScanRecord(_ record: FoodProductScanRecord) {
        foodProductScanHistory.append(record)
        if let data = try? JSONEncoder().encode(foodProductScanHistory) {
            UserDefaults.standard.set(data, forKey: foodProductScanHistoryKey)
        }
    }

    func deleteFoodProductScanRecord(id: UUID) {
        foodProductScanHistory.removeAll { $0.id == id }
        if let data = try? JSONEncoder().encode(foodProductScanHistory) {
            UserDefaults.standard.set(data, forKey: foodProductScanHistoryKey)
        }
    }

    func removeIngredient(mealId: UUID, ingredientId: UUID) {
        for dayIndex in nutritionPlan.days.indices {
            for mealIndex in nutritionPlan.days[dayIndex].meals.indices {
                if nutritionPlan.days[dayIndex].meals[mealIndex].id == mealId {
                    let removed = nutritionPlan.days[dayIndex].meals[mealIndex].ingredients.first(where: { $0.id == ingredientId })
                    nutritionPlan.days[dayIndex].meals[mealIndex].ingredients.removeAll { $0.id == ingredientId }
                    if let removed {
                        nutritionPlan.days[dayIndex].meals[mealIndex].calories -= removed.calories
                        let ratio = removed.calories > 0 ? Double(removed.calories) : 0
                        let totalOld = Double(nutritionPlan.days[dayIndex].meals[mealIndex].calories + removed.calories)
                        if totalOld > 0 {
                            let factor = ratio / totalOld
                            nutritionPlan.days[dayIndex].meals[mealIndex].protein -= nutritionPlan.days[dayIndex].meals[mealIndex].protein * factor
                            nutritionPlan.days[dayIndex].meals[mealIndex].carbs -= nutritionPlan.days[dayIndex].meals[mealIndex].carbs * factor
                            nutritionPlan.days[dayIndex].meals[mealIndex].fat -= nutritionPlan.days[dayIndex].meals[mealIndex].fat * factor
                        }
                    }
                    saveNutrition()
                    return
                }
            }
        }
    }

    func substituteIngredient(mealId: UUID, ingredientId: UUID, newIngredient: Ingredient) {
        for dayIndex in nutritionPlan.days.indices {
            for mealIndex in nutritionPlan.days[dayIndex].meals.indices {
                if nutritionPlan.days[dayIndex].meals[mealIndex].id == mealId {
                    if let idx = nutritionPlan.days[dayIndex].meals[mealIndex].ingredients.firstIndex(where: { $0.id == ingredientId }) {
                        let old = nutritionPlan.days[dayIndex].meals[mealIndex].ingredients[idx]
                        var updated = newIngredient
                        updated.id = UUID()
                        nutritionPlan.days[dayIndex].meals[mealIndex].ingredients[idx] = updated
                        let calorieDiff = newIngredient.calories - old.calories
                        nutritionPlan.days[dayIndex].meals[mealIndex].calories += calorieDiff
                        let totalCal = Double(nutritionPlan.days[dayIndex].meals[mealIndex].calories)
                        if totalCal > 0 && old.calories > 0 {
                            let factor = Double(calorieDiff) / totalCal
                            nutritionPlan.days[dayIndex].meals[mealIndex].protein += nutritionPlan.days[dayIndex].meals[mealIndex].protein * factor
                            nutritionPlan.days[dayIndex].meals[mealIndex].carbs += nutritionPlan.days[dayIndex].meals[mealIndex].carbs * factor
                            nutritionPlan.days[dayIndex].meals[mealIndex].fat += nutritionPlan.days[dayIndex].meals[mealIndex].fat * factor
                        }
                    }
                    saveNutrition()
                    return
                }
            }
        }
    }

    func mealById(_ mealId: UUID) -> Meal? {
        for day in nutritionPlan.days {
            if let meal = day.meals.first(where: { $0.id == mealId }) {
                return meal
            }
        }
        return nil
    }

    func applyScanNutritionPlan(_ plan: NutritionPlan) {
        mealImageGenerationId = UUID()
        let normalizedDays = plan.days.map { DayPlan(id: $0.id, dayName: DayNameNormalizer.normalize($0.dayName), meals: $0.meals) }
        nutritionPlan = NutritionPlan(days: normalizedDays, createdAt: plan.createdAt)
        pendingScanPlan = nil
        todayLog = DayLog()
        saveNutrition()
        saveTodayLog()
        savePendingScanPlan()
        syncWidgetData()
        generateMealImages()
    }

    func applyScanWorkoutPlan(_ plan: WorkoutPlan) {
        workoutPlan = WorkoutLocalization.localizePlanSafe(plan)
        saveWorkout()
        syncWidgetData()
    }

    func modifyTodaySession(userRequest: String) async {
        let todayName = Date().weekdayName
        guard let currentDay = workoutPlan.days.first(where: { $0.dayName == todayName }) else { return }

        isModifyingSession = true
        sessionModificationError = nil

        do {
            let modifiedDay = try await AIService.modifyTodaySession(
                currentDay: currentDay,
                userRequest: userRequest,
                profile: userProfile
            )
            todaySessionOverride = modifiedDay
            todaySessionOverrideDate = DateFormatter.dayKey.string(from: Date())
            saveSessionOverride()
        } catch {
            sessionModificationError = error.localizedDescription
        }

        isModifyingSession = false
    }

    func clearSessionOverride() {
        todaySessionOverride = nil
        todaySessionOverrideDate = nil
        UserDefaults.standard.removeObject(forKey: sessionOverrideKey)
        UserDefaults.standard.removeObject(forKey: sessionOverrideDateKey)
    }

    func effectiveWorkoutDay(for dayName: String) -> WorkoutDay? {
        let todayName = Date().weekdayName
        if dayName == todayName,
           let override = todaySessionOverride,
           let savedDate = todaySessionOverrideDate,
           savedDate == DateFormatter.dayKey.string(from: Date()) {
            return override
        }
        return workoutPlan.days.first(where: { $0.dayName == dayName })
    }

    var hasActiveSessionOverride: Bool {
        guard let savedDate = todaySessionOverrideDate else { return false }
        return savedDate == DateFormatter.dayKey.string(from: Date()) && todaySessionOverride != nil
    }

    private func saveSessionOverride() {
        if let override = todaySessionOverride,
           let data = try? JSONEncoder().encode(override) {
            UserDefaults.standard.set(data, forKey: sessionOverrideKey)
        }
        if let date = todaySessionOverrideDate {
            UserDefaults.standard.set(date, forKey: sessionOverrideDateKey)
        }
    }

    private func loadSessionOverride() {
        let savedDate = UserDefaults.standard.string(forKey: sessionOverrideDateKey)
        let todayKey = DateFormatter.dayKey.string(from: Date())
        if savedDate == todayKey,
           let data = UserDefaults.standard.data(forKey: sessionOverrideKey),
           let decoded = try? JSONDecoder().decode(WorkoutDay.self, from: data) {
            todaySessionOverride = decoded
            todaySessionOverrideDate = savedDate
        } else {
            clearSessionOverride()
        }
    }

    func logout() {
        hasCompletedOnboarding = false
        UserDefaults.standard.set(false, forKey: onboardingKey)
        UserDefaults.standard.set(false, forKey: "hasOnboarded")
        AuthService.shared.signOut()
    }

    func deleteAccount() {
        AuthService.shared.signOut()
        EmailAutomationService.shared.resetAll()
        let domain = Bundle.main.bundleIdentifier ?? ""
        UserDefaults.standard.removePersistentDomain(forName: domain)
        UserDefaults.standard.synchronize()
        userProfile = UserProfile()
        nutritionPlan = NutritionPlan()
        workoutPlan = WorkoutPlan()
        weightHistory = []
        todayLog = DayLog()
        memojiImages = [:]
        mealScannedImages = [:]
        hasCompletedOnboarding = false
    }
}

nonisolated struct DayLog: Codable, Sendable {
    var date: Date = Date()
    var completedMealIds: Set<UUID> = []
    var caloriesConsumed: Int = 0
    var photoScannedCalories: Int = 0
    var mealCalorieOverrides: [String: Int] = [:]

    enum CodingKeys: String, CodingKey {
        case date, completedMealIds, caloriesConsumed, photoScannedCalories, mealCalorieOverrides
    }

    init() {}

    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        date = (try? c.decode(Date.self, forKey: .date)) ?? Date()
        completedMealIds = (try? c.decode(Set<UUID>.self, forKey: .completedMealIds)) ?? []
        caloriesConsumed = (try? c.decode(Int.self, forKey: .caloriesConsumed)) ?? 0
        photoScannedCalories = (try? c.decode(Int.self, forKey: .photoScannedCalories)) ?? 0
        mealCalorieOverrides = (try? c.decode([String: Int].self, forKey: .mealCalorieOverrides)) ?? [:]
    }
}
