import Foundation
import HealthKit

struct HealthSnapshot {
    var activeCalories: Double = 0
    var steps: Double = 0
    var distanceMeters: Double = 0
    var restingHeartRate: Double = 0
    var hrv: Double = 0
    var spo2: Double = 0
    var sleepHours: Double = 0
    var exerciseMinutes: Double = 0
    var flightsClimbed: Double = 0
    var standHours: Double = 0
    var walkingSpeedKmh: Double = 0
    var respiratoryRate: Double = 0
    var mindfulMinutes: Double = 0
    var basalCalories: Double = 0
}

@MainActor
class HealthKitService {
    static let shared = HealthKitService()

    private let healthStore = HKHealthStore()

    private init() {}

    var isAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    func requestAuthorization() async {
        guard isAvailable else { return }

        var readTypes = Set<HKObjectType>()
        let quantityIdentifiers: [HKQuantityTypeIdentifier] = [
            .activeEnergyBurned, .basalEnergyBurned, .stepCount,
            .distanceWalkingRunning, .heartRate, .restingHeartRate,
            .heartRateVariabilitySDNN, .oxygenSaturation,
            .bodyMassIndex, .bodyFatPercentage, .bodyMass,
            .flightsClimbed, .appleExerciseTime, .respiratoryRate,
            .appleStandTime, .walkingSpeed
        ]
        for id in quantityIdentifiers {
            if let t = HKQuantityType.quantityType(forIdentifier: id) { readTypes.insert(t) }
        }
        if let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) { readTypes.insert(sleepType) }
        if let mindfulType = HKObjectType.categoryType(forIdentifier: .mindfulSession) { readTypes.insert(mindfulType) }
        try? await healthStore.requestAuthorization(toShare: [], read: readTypes)
    }

    func requestAuthorizationAndFetchActiveCalories() async -> Double {
        let snapshot = await fetchAllHealthData()
        return snapshot.activeCalories
    }

    func fetchAllHealthData() async -> HealthSnapshot {
        guard isAvailable else { return HealthSnapshot() }

        await requestAuthorization()

        let store = healthStore

        async let activeCalories = fetchTodaySum(.activeEnergyBurned, unit: .kilocalorie(), store: store)
        async let steps = fetchTodaySum(.stepCount, unit: .count(), store: store)
        async let distance = fetchTodaySum(.distanceWalkingRunning, unit: .meter(), store: store)
        async let exerciseMin = fetchTodaySum(.appleExerciseTime, unit: .minute(), store: store)
        async let restingHR = fetchRecentAverage(.restingHeartRate, unit: HKUnit(from: "count/min"), store: store)
        async let hrv = fetchRecentAverage(.heartRateVariabilitySDNN, unit: .secondUnit(with: .milli), store: store)
        async let rawSpo2 = fetchRecentAverage(.oxygenSaturation, unit: .percent(), store: store)
        async let sleep = fetchSleepHours(store: store)
        async let flights = fetchTodaySum(.flightsClimbed, unit: .count(), store: store)
        async let standH = fetchTodaySum(.appleStandTime, unit: .minute(), store: store)
        async let walkSpeed = fetchRecentAverage(.walkingSpeed, unit: HKUnit(from: "km/hr"), store: store)
        async let respRate = fetchRecentAverage(.respiratoryRate, unit: HKUnit(from: "count/min"), store: store)
        async let mindful = fetchMindfulMinutes(store: store)
        async let basalCal = fetchTodaySum(.basalEnergyBurned, unit: .kilocalorie(), store: store)

        let spo2Raw = await rawSpo2
        let spo2 = spo2Raw > 1.0 ? spo2Raw : spo2Raw * 100.0

        return await HealthSnapshot(
            activeCalories: activeCalories,
            steps: steps,
            distanceMeters: distance,
            restingHeartRate: restingHR,
            hrv: hrv,
            spo2: spo2,
            sleepHours: sleep,
            exerciseMinutes: exerciseMin,
            flightsClimbed: flights,
            standHours: standH / 60.0,
            walkingSpeedKmh: walkSpeed,
            respiratoryRate: respRate,
            mindfulMinutes: mindful,
            basalCalories: basalCal
        )
    }

    private func fetchTodaySum(_ id: HKQuantityTypeIdentifier, unit: HKUnit, store: HKHealthStore) async -> Double {
        guard let type = HKQuantityType.quantityType(forIdentifier: id) else { return 0 }
        let now = Date()
        let startOfDay = Calendar.current.startOfDay(for: now)
        let predicate = HKQuery.predicateForSamples(withStart: startOfDay, end: now)

        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: type,
                quantitySamplePredicate: predicate,
                options: .cumulativeSum
            ) { _, stats, _ in
                let value = stats?.sumQuantity()?.doubleValue(for: unit) ?? 0
                continuation.resume(returning: value)
            }
            store.execute(query)
        }
    }

    private func fetchRecentAverage(_ id: HKQuantityTypeIdentifier, unit: HKUnit, store: HKHealthStore) async -> Double {
        guard let type = HKQuantityType.quantityType(forIdentifier: id) else { return 0 }
        let start = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let predicate = HKQuery.predicateForSamples(withStart: start, end: Date())

        return await withCheckedContinuation { continuation in
            let query = HKStatisticsQuery(
                quantityType: type,
                quantitySamplePredicate: predicate,
                options: .discreteAverage
            ) { _, stats, _ in
                let value = stats?.averageQuantity()?.doubleValue(for: unit) ?? 0
                continuation.resume(returning: value)
            }
            store.execute(query)
        }
    }

    private func fetchMindfulMinutes(store: HKHealthStore) async -> Double {
        guard let mindfulType = HKObjectType.categoryType(forIdentifier: .mindfulSession) else { return 0 }
        let start = Calendar.current.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: start, end: Date())

        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: mindfulType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, samples, _ in
                guard let samples = samples as? [HKCategorySample] else {
                    continuation.resume(returning: 0)
                    return
                }
                let totalSeconds = samples.reduce(0.0) { $0 + $1.endDate.timeIntervalSince($1.startDate) }
                continuation.resume(returning: totalSeconds / 60.0)
            }
            store.execute(query)
        }
    }

    private func fetchSleepHours(store: HKHealthStore) async -> Double {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else { return 0 }
        let start = Calendar.current.date(byAdding: .hour, value: -24, to: Date()) ?? Date()
        let predicate = HKQuery.predicateForSamples(withStart: start, end: Date())

        return await withCheckedContinuation { continuation in
            let query = HKSampleQuery(
                sampleType: sleepType,
                predicate: predicate,
                limit: HKObjectQueryNoLimit,
                sortDescriptors: nil
            ) { _, samples, _ in
                guard let samples = samples as? [HKCategorySample] else {
                    continuation.resume(returning: 0)
                    return
                }
                let asleepValues: Set<Int> = [
                    HKCategoryValueSleepAnalysis.asleepUnspecified.rawValue,
                    HKCategoryValueSleepAnalysis.asleepCore.rawValue,
                    HKCategoryValueSleepAnalysis.asleepDeep.rawValue,
                    HKCategoryValueSleepAnalysis.asleepREM.rawValue
                ]
                let totalSeconds = samples
                    .filter { asleepValues.contains($0.value) }
                    .reduce(0.0) { $0 + $1.endDate.timeIntervalSince($1.startDate) }
                continuation.resume(returning: totalSeconds / 3600.0)
            }
            store.execute(query)
        }
    }
}
