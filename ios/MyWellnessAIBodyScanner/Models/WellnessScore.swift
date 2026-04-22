import SwiftUI

enum WellnessParameterStatus {
    case good, moderate, needsAttention

    var color: Color {
        switch self {
        case .good: return Color(red: 0.17, green: 0.72, blue: 0.45)
        case .moderate: return Color.orange
        case .needsAttention: return Color.red
        }
    }

    var score: Double {
        switch self {
        case .good: return 1.0
        case .moderate: return 0.5
        case .needsAttention: return 0.0
        }
    }

    var sfIcon: String {
        switch self {
        case .good: return "checkmark.circle.fill"
        case .moderate: return "exclamationmark.circle.fill"
        case .needsAttention: return "xmark.circle.fill"
        }
    }

    var label: String {
        switch self {
        case .good: return Lang.s("status_good")
        case .moderate: return Lang.s("status_fair")
        case .needsAttention: return Lang.s("status_needs_improvement")
        }
    }
}

enum WellnessMood {
    case excellent, good, fair, poor

    var emoji: String {
        switch self {
        case .excellent: return "😄"
        case .good: return "🙂"
        case .fair: return "😐"
        case .poor: return "😔"
        }
    }

    var fullLabel: String {
        switch self {
        case .excellent: return Lang.s("mood_full_excellent")
        case .good: return Lang.s("mood_full_good")
        case .fair: return Lang.s("mood_full_fair")
        case .poor: return Lang.s("mood_full_poor")
        }
    }

    var shortLabel: String {
        switch self {
        case .excellent: return Lang.s("mood_short_excellent")
        case .good: return Lang.s("mood_short_good")
        case .fair: return Lang.s("mood_short_fair")
        case .poor: return Lang.s("mood_short_low")
        }
    }

    var moodLabel: String {
        switch self {
        case .excellent: return Lang.s("mood_excellent")
        case .good: return Lang.s("mood_good")
        case .fair: return Lang.s("mood_fair")
        case .poor: return Lang.s("mood_poor")
        }
    }

    var isPositive: Bool {
        switch self {
        case .excellent, .good: return true
        case .fair, .poor: return false
        }
    }

    var color: Color {
        switch self {
        case .excellent: return Color(red: 0.17, green: 0.72, blue: 0.45)
        case .good: return Color(red: 0.17, green: 0.60, blue: 0.52)
        case .fair: return Color.orange
        case .poor: return Color.red
        }
    }

    var uiColor: UIColor {
        switch self {
        case .excellent: return UIColor(red: 0.17, green: 0.72, blue: 0.45, alpha: 1)
        case .good: return UIColor(red: 0.17, green: 0.60, blue: 0.52, alpha: 1)
        case .fair: return UIColor.orange
        case .poor: return UIColor.red
        }
    }

    var memojiSaturation: Double {
        switch self {
        case .excellent: return 1.35
        case .good:      return 1.0
        case .fair:      return 0.5
        case .poor:      return 0.18
        }
    }

    var memojiColorMultiply: Color {
        switch self {
        case .excellent: return Color(red: 1.0,  green: 0.96, blue: 0.82)
        case .good:      return .white
        case .fair:      return Color(red: 1.0,  green: 0.94, blue: 0.78)
        case .poor:      return Color(red: 0.82, green: 0.88, blue: 1.0)
        }
    }

    var memojiBrightness: Double {
        switch self {
        case .excellent: return  0.06
        case .good:      return  0.0
        case .fair:      return -0.04
        case .poor:      return -0.14
        }
    }

    var storageKey: String {
        switch self {
        case .excellent: return "excellent"
        case .good:      return "good"
        case .fair:      return "fair"
        case .poor:      return "poor"
        }
    }

    static func from(score: Double) -> WellnessMood {
        if score >= 0.78 { return .excellent }
        if score >= 0.55 { return .good }
        if score >= 0.33 { return .fair }
        return .poor
    }
}

struct WellnessParameter: Identifiable {
    let id: UUID = UUID()
    let name: String
    let icon: String
    let displayValue: String
    let unit: String
    let status: WellnessParameterStatus
    let description: String
    let currentNormalized: Double
    let hasData: Bool
    let requiresWearable: Bool

    init(
        name: String, icon: String, displayValue: String, unit: String,
        status: WellnessParameterStatus, description: String,
        currentNormalized: Double, hasData: Bool = true, requiresWearable: Bool = false
    ) {
        self.name = name
        self.icon = icon
        self.displayValue = displayValue
        self.unit = unit
        self.status = status
        self.description = description
        self.currentNormalized = currentNormalized
        self.hasData = hasData
        self.requiresWearable = requiresWearable
    }
}

struct WellnessScoreEngine {
    static func compute(
        snapshot: HealthSnapshot,
        profile: UserProfile,
        calorieBalance: Int,
        wearableEnabled: Bool = true
    ) -> (parameters: [WellnessParameter], score: Double, mood: WellnessMood) {
        var params: [WellnessParameter] = []

        let balanceStatus: WellnessParameterStatus = {
            if calorieBalance >= -300 && calorieBalance <= 150 { return .good }
            if (calorieBalance < -300 && calorieBalance >= -700) || (calorieBalance > 150 && calorieBalance <= 700) { return .moderate }
            return .needsAttention
        }()
        let balanceDescription: String = {
            if calorieBalance < -700 { return Lang.s("cal_deficit_very_high") }
            if calorieBalance < -300 { return Lang.s("cal_deficit_slight") }
            if calorieBalance <= 150 { return Lang.s("cal_balance_optimal") }
            if calorieBalance <= 700 { return Lang.s("cal_surplus_slight") }
            return Lang.s("cal_surplus_excessive")
        }()
        params.append(WellnessParameter(
            name: Lang.s("param_calorie_balance"),
            icon: "flame.fill",
            displayValue: "\(calorieBalance > 0 ? "+" : "")\(calorieBalance)",
            unit: "kcal",
            status: balanceStatus,
            description: balanceDescription,
            currentNormalized: clamp((Double(calorieBalance) + 1500) / 3000.0)
        ))

        let bmi = profile.bmi
        let bmiStatus: WellnessParameterStatus = {
            if bmi >= 18.5 && bmi < 25.0 { return .good }
            if (bmi >= 17.0 && bmi < 18.5) || (bmi >= 25.0 && bmi < 27.5) { return .moderate }
            return .needsAttention
        }()
        params.append(WellnessParameter(
            name: Lang.s("param_bmi"),
            icon: "figure.stand",
            displayValue: String(format: "%.1f", bmi),
            unit: "kg/m²",
            status: bmiStatus,
            description: bmiStatus == .good ? Lang.s("bmi_normal") : bmi >= 25 ? Lang.s("bmi_overweight") : Lang.s("bmi_underweight"),
            currentNormalized: clamp((bmi - 14.0) / 21.0)
        ))

        let weightStatus: WellnessParameterStatus = {
            let diff = abs(profile.currentWeightKg - profile.targetWeightKg)
            if diff <= 2 { return .good }
            if diff <= 8 { return .moderate }
            return .needsAttention
        }()
        params.append(WellnessParameter(
            name: Lang.s("param_body_weight"),
            icon: "scalemass.fill",
            displayValue: String(format: "%.1f", profile.currentWeightKg),
            unit: "kg",
            status: weightStatus,
            description: weightStatus == .good ? Lang.s("weight_near_goal") : Lang.s("weight_remaining").replacingOccurrences(of: "%@", with: String(format: "%.1f", abs(profile.currentWeightKg - profile.targetWeightKg))),
            currentNormalized: clamp(1.0 - abs(profile.currentWeightKg - profile.targetWeightKg) / 20.0)
        ))

        if let bf = profile.bodyFatPercentage {
            let bfStatus: WellnessParameterStatus
            let bfNorm: Double
            if profile.gender == .male {
                bfStatus = bf < 20 ? .good : bf < 26 ? .moderate : .needsAttention
                bfNorm = clamp(bf / 40.0)
            } else {
                bfStatus = bf < 30 ? .good : bf < 36 ? .moderate : .needsAttention
                bfNorm = clamp(bf / 50.0)
            }
            params.append(WellnessParameter(
                name: Lang.s("param_body_fat"),
                icon: "figure.arms.open",
                displayValue: String(format: "%.1f", bf),
                unit: "%",
                status: bfStatus,
                description: bfStatus == .good ? Lang.s("bf_optimal") : Lang.s("bf_reduce"),
                currentNormalized: bfNorm
            ))
        } else {
            params.append(WellnessParameter(
                name: Lang.s("param_body_fat"),
                icon: "figure.arms.open",
                displayValue: "--",
                unit: "%",
                status: .moderate,
                description: Lang.s("bf_enter_measures"),
                currentNormalized: 0.5,
                hasData: false
            ))
        }

        do {
            let hasSteps = snapshot.steps > 0
            let stepsStatus: WellnessParameterStatus = hasSteps ? (snapshot.steps >= 8000 ? .good : snapshot.steps >= 5000 ? .moderate : .needsAttention) : .needsAttention
            let stepsDesc: String = {
                if !hasSteps { return Lang.s("steps_no_data") }
                if snapshot.steps >= 8000 { return Lang.s("steps_great") }
                if snapshot.steps >= 5000 { return Lang.s("steps_extra_walk") }
                return Lang.s("steps_move_more")
            }()
            params.append(WellnessParameter(
                name: Lang.s("param_steps_today"),
                icon: "figure.walk",
                displayValue: hasSteps ? String(format: "%.0f", snapshot.steps) : "--",
                unit: Lang.s("unit_steps"),
                status: stepsStatus,
                description: stepsDesc,
                currentNormalized: hasSteps ? clamp(snapshot.steps / 15000.0) : 0,
                hasData: hasSteps
            ))
        }

        do {
            let hasCalActive = snapshot.activeCalories > 0
            let calStatus: WellnessParameterStatus = hasCalActive ? (snapshot.activeCalories >= 400 ? .good : snapshot.activeCalories >= 200 ? .moderate : .needsAttention) : .needsAttention
            let calDesc: String = {
                if !hasCalActive { return Lang.s("cal_active_no_data") }
                if snapshot.activeCalories >= 400 { return Lang.s("cal_active_great") }
                if snapshot.activeCalories >= 200 { return Lang.s("cal_active_good_start") }
                return Lang.s("cal_active_few")
            }()
            params.append(WellnessParameter(
                name: Lang.s("param_active_calories"),
                icon: "bolt.fill",
                displayValue: hasCalActive ? "\(Int(snapshot.activeCalories))" : "--",
                unit: "kcal",
                status: calStatus,
                description: calDesc,
                currentNormalized: hasCalActive ? clamp(snapshot.activeCalories / 1000.0) : 0,
                hasData: hasCalActive,
                requiresWearable: true
            ))
        }

        do {
            let hasBasal = snapshot.basalCalories > 0
            let basalStatus: WellnessParameterStatus = hasBasal ? (snapshot.basalCalories >= 1200 ? .good : snapshot.basalCalories >= 800 ? .moderate : .needsAttention) : .moderate
            params.append(WellnessParameter(
                name: Lang.s("param_basal_calories"),
                icon: "flame",
                displayValue: hasBasal ? "\(Int(snapshot.basalCalories))" : "--",
                unit: "kcal",
                status: basalStatus,
                description: hasBasal ? Lang.s("cal_basal_normal") : Lang.s("cal_basal_no_data"),
                currentNormalized: hasBasal ? clamp(snapshot.basalCalories / 2500.0) : 0.5,
                hasData: hasBasal,
                requiresWearable: true
            ))
        }

        do {
            let hasEx = snapshot.exerciseMinutes > 0
            let exStatus: WellnessParameterStatus = hasEx ? (snapshot.exerciseMinutes >= 30 ? .good : snapshot.exerciseMinutes >= 15 ? .moderate : .needsAttention) : .needsAttention
            let exDesc: String = {
                if !hasEx { return Lang.s("exercise_no_data") }
                if snapshot.exerciseMinutes >= 30 { return Lang.s("exercise_goal_reached") }
                if snapshot.exerciseMinutes >= 15 { return Lang.s("exercise_almost") }
                return Lang.s("exercise_too_little")
            }()
            params.append(WellnessParameter(
                name: Lang.s("param_exercise_minutes"),
                icon: "figure.run",
                displayValue: hasEx ? "\(Int(snapshot.exerciseMinutes))" : "--",
                unit: "min",
                status: exStatus,
                description: exDesc,
                currentNormalized: hasEx ? clamp(snapshot.exerciseMinutes / 90.0) : 0,
                hasData: hasEx,
                requiresWearable: true
            ))
        }

        do {
            let distKm = snapshot.distanceMeters / 1000.0
            let hasDist = distKm > 0.01
            let distStatus: WellnessParameterStatus = hasDist ? (distKm >= 5 ? .good : distKm >= 3 ? .moderate : .needsAttention) : .needsAttention
            let distDesc: String = {
                if !hasDist { return Lang.s("dist_no_data") }
                if distKm >= 5 { return Lang.s("dist_great") }
                if distKm >= 3 { return Lang.s("dist_good") }
                return Lang.s("dist_low")
            }()
            params.append(WellnessParameter(
                name: Lang.s("param_distance"),
                icon: "map.fill",
                displayValue: hasDist ? String(format: "%.1f", distKm) : "--",
                unit: "km",
                status: distStatus,
                description: distDesc,
                currentNormalized: hasDist ? clamp(distKm / 10.0) : 0,
                hasData: hasDist
            ))
        }

        do {
            let hasFlights = snapshot.flightsClimbed > 0
            let flightStatus: WellnessParameterStatus = hasFlights ? (snapshot.flightsClimbed >= 10 ? .good : snapshot.flightsClimbed >= 5 ? .moderate : .needsAttention) : .needsAttention
            let flightDesc: String = {
                if !hasFlights { return Lang.s("flights_no_data") }
                if snapshot.flightsClimbed >= 10 { return Lang.s("flights_excellent") }
                if snapshot.flightsClimbed >= 5 { return Lang.s("flights_good") }
                return Lang.s("flights_few")
            }()
            params.append(WellnessParameter(
                name: Lang.s("param_flights_climbed"),
                icon: "figure.stairs",
                displayValue: hasFlights ? "\(Int(snapshot.flightsClimbed))" : "--",
                unit: Lang.s("unit_floors"),
                status: flightStatus,
                description: flightDesc,
                currentNormalized: hasFlights ? clamp(snapshot.flightsClimbed / 20.0) : 0,
                hasData: hasFlights
            ))
        }

        do {
            let hasStand = snapshot.standHours > 0
            let standStatus: WellnessParameterStatus = hasStand ? (snapshot.standHours >= 10 ? .good : snapshot.standHours >= 6 ? .moderate : .needsAttention) : .needsAttention
            let standDesc: String = {
                if !hasStand { return Lang.s("stand_no_data") }
                if snapshot.standHours >= 10 { return Lang.s("stand_great") }
                if snapshot.standHours >= 6 { return Lang.s("stand_almost") }
                return Lang.s("stand_sedentary")
            }()
            params.append(WellnessParameter(
                name: Lang.s("param_stand_hours"),
                icon: "figure.stand",
                displayValue: hasStand ? "\(Int(snapshot.standHours))" : "--",
                unit: Lang.s("unit_hours"),
                status: standStatus,
                description: standDesc,
                currentNormalized: hasStand ? clamp(snapshot.standHours / 14.0) : 0,
                hasData: hasStand,
                requiresWearable: true
            ))
        }

        do {
            let hasSleep = snapshot.sleepHours > 0
            let sleepStatus: WellnessParameterStatus = hasSleep ? ((snapshot.sleepHours >= 7 && snapshot.sleepHours <= 9) ? .good : (snapshot.sleepHours >= 6 && snapshot.sleepHours <= 10) ? .moderate : .needsAttention) : .needsAttention
            let sleepDesc: String = {
                if !hasSleep { return Lang.s("sleep_no_data") }
                if snapshot.sleepHours >= 7 && snapshot.sleepHours <= 9 { return Lang.s("sleep_optimal") }
                if snapshot.sleepHours < 7 { return Lang.s("sleep_more") }
                return Lang.s("sleep_excessive")
            }()
            params.append(WellnessParameter(
                name: Lang.s("param_sleep"),
                icon: "moon.zzz.fill",
                displayValue: hasSleep ? String(format: "%.1f", snapshot.sleepHours) : "--",
                unit: Lang.s("unit_hours"),
                status: sleepStatus,
                description: sleepDesc,
                currentNormalized: hasSleep ? clamp(snapshot.sleepHours / 12.0) : 0,
                hasData: hasSleep,
                requiresWearable: true
            ))
        }

        do {
            let hasHR = snapshot.restingHeartRate > 25
            let hrStatus: WellnessParameterStatus = hasHR ? ((snapshot.restingHeartRate >= 50 && snapshot.restingHeartRate <= 75) ? .good : (snapshot.restingHeartRate >= 40 && snapshot.restingHeartRate <= 90) ? .moderate : .needsAttention) : .moderate
            let hrDesc: String = {
                if !hasHR { return Lang.s("hr_no_data") }
                if snapshot.restingHeartRate >= 50 && snapshot.restingHeartRate <= 75 { return Lang.s("hr_excellent") }
                if snapshot.restingHeartRate > 75 { return Lang.s("hr_high") }
                return Lang.s("hr_very_low")
            }()
            params.append(WellnessParameter(
                name: Lang.s("param_resting_hr"),
                icon: "heart.fill",
                displayValue: hasHR ? "\(Int(snapshot.restingHeartRate))" : "--",
                unit: "bpm",
                status: hrStatus,
                description: hrDesc,
                currentNormalized: hasHR ? clamp((snapshot.restingHeartRate - 30) / 90.0) : 0.5,
                hasData: hasHR,
                requiresWearable: true
            ))
        }

        do {
            let hasHRV = snapshot.hrv > 0
            let hrvStatus: WellnessParameterStatus = hasHRV ? (snapshot.hrv >= 50 ? .good : snapshot.hrv >= 25 ? .moderate : .needsAttention) : .moderate
            let hrvDesc: String = {
                if !hasHRV { return Lang.s("hrv_no_data") }
                if snapshot.hrv >= 50 { return Lang.s("hrv_excellent") }
                if snapshot.hrv >= 25 { return Lang.s("hrv_decent") }
                return Lang.s("hrv_low")
            }()
            params.append(WellnessParameter(
                name: Lang.s("param_hrv"),
                icon: "waveform.path.ecg",
                displayValue: hasHRV ? "\(Int(snapshot.hrv))" : "--",
                unit: "ms",
                status: hrvStatus,
                description: hrvDesc,
                currentNormalized: hasHRV ? clamp(snapshot.hrv / 120.0) : 0.5,
                hasData: hasHRV,
                requiresWearable: true
            ))
        }

        do {
            let hasSpo2 = snapshot.spo2 > 50
            let spo2Status: WellnessParameterStatus = hasSpo2 ? (snapshot.spo2 >= 97 ? .good : snapshot.spo2 >= 95 ? .moderate : .needsAttention) : .moderate
            let spo2Desc: String = {
                if !hasSpo2 { return Lang.s("spo2_no_data") }
                if snapshot.spo2 >= 97 { return Lang.s("spo2_optimal") }
                if snapshot.spo2 >= 95 { return Lang.s("spo2_slightly_low") }
                return Lang.s("spo2_low")
            }()
            params.append(WellnessParameter(
                name: Lang.s("param_blood_oxygen"),
                icon: "lungs.fill",
                displayValue: hasSpo2 ? String(format: "%.0f", snapshot.spo2) : "--",
                unit: "%",
                status: spo2Status,
                description: spo2Desc,
                currentNormalized: hasSpo2 ? clamp((snapshot.spo2 - 88.0) / 12.0) : 0.5,
                hasData: hasSpo2,
                requiresWearable: true
            ))
        }

        do {
            let hasResp = snapshot.respiratoryRate > 0
            let respStatus: WellnessParameterStatus = hasResp ? ((snapshot.respiratoryRate >= 12 && snapshot.respiratoryRate <= 20) ? .good : (snapshot.respiratoryRate >= 10 && snapshot.respiratoryRate <= 24) ? .moderate : .needsAttention) : .moderate
            let respDesc: String = {
                if !hasResp { return Lang.s("resp_no_data") }
                if snapshot.respiratoryRate >= 12 && snapshot.respiratoryRate <= 20 { return Lang.s("resp_normal") }
                if snapshot.respiratoryRate < 12 { return Lang.s("resp_low") }
                return Lang.s("resp_high")
            }()
            params.append(WellnessParameter(
                name: Lang.s("param_respiratory_rate"),
                icon: "wind",
                displayValue: hasResp ? String(format: "%.0f", snapshot.respiratoryRate) : "--",
                unit: Lang.s("unit_breaths_min"),
                status: respStatus,
                description: respDesc,
                currentNormalized: hasResp ? clamp((snapshot.respiratoryRate - 6.0) / 24.0) : 0.5,
                hasData: hasResp,
                requiresWearable: true
            ))
        }

        do {
            let hasSpeed = snapshot.walkingSpeedKmh > 0
            let speedStatus: WellnessParameterStatus = hasSpeed ? (snapshot.walkingSpeedKmh >= 5.0 ? .good : snapshot.walkingSpeedKmh >= 4.0 ? .moderate : .needsAttention) : .moderate
            let speedDesc: String = {
                if !hasSpeed { return Lang.s("speed_no_data") }
                if snapshot.walkingSpeedKmh >= 5.0 { return Lang.s("speed_excellent") }
                if snapshot.walkingSpeedKmh >= 4.0 { return Lang.s("speed_good") }
                return Lang.s("speed_low")
            }()
            params.append(WellnessParameter(
                name: Lang.s("param_walking_speed"),
                icon: "speedometer",
                displayValue: hasSpeed ? String(format: "%.1f", snapshot.walkingSpeedKmh) : "--",
                unit: "km/h",
                status: speedStatus,
                description: speedDesc,
                currentNormalized: hasSpeed ? clamp(snapshot.walkingSpeedKmh / 8.0) : 0.5,
                hasData: hasSpeed
            ))
        }

        do {
            let hasMindful = snapshot.mindfulMinutes > 0
            let mindStatus: WellnessParameterStatus = hasMindful ? (snapshot.mindfulMinutes >= 10 ? .good : snapshot.mindfulMinutes >= 5 ? .moderate : .needsAttention) : .needsAttention
            let mindDesc: String = {
                if !hasMindful { return Lang.s("mind_no_data") }
                if snapshot.mindfulMinutes >= 10 { return Lang.s("mind_great") }
                if snapshot.mindfulMinutes >= 5 { return Lang.s("mind_good_start") }
                return Lang.s("mind_add_more")
            }()
            params.append(WellnessParameter(
                name: Lang.s("param_mindfulness"),
                icon: "brain.head.profile",
                displayValue: hasMindful ? "\(Int(snapshot.mindfulMinutes))" : "--",
                unit: "min",
                status: mindStatus,
                description: mindDesc,
                currentNormalized: hasMindful ? clamp(snapshot.mindfulMinutes / 30.0) : 0,
                hasData: hasMindful
            ))
        }

        let visibleParams = wearableEnabled ? params : params.filter { !$0.requiresWearable }

        let scorableParams = visibleParams.filter { $0.hasData }
        let totalScore: Double
        if scorableParams.isEmpty {
            totalScore = 0.5
        } else {
            let sum = scorableParams.reduce(0.0) { $0 + $1.status.score }
            totalScore = sum / Double(scorableParams.count)
        }

        let mood = WellnessMood.from(score: totalScore)
        return (visibleParams, totalScore, mood)
    }

    private static func clamp(_ value: Double) -> Double {
        Swift.min(1.0, Swift.max(0.0, value))
    }
}
