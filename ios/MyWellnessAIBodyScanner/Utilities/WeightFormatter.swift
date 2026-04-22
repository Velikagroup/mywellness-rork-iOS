import SwiftUI

struct WeightFormatter {
    static func format(_ kg: Double, metric: Bool) -> String {
        if metric {
            return String(format: "%.1f", kg)
        } else {
            return String(format: "%.1f", kg * 2.20462)
        }
    }

    static func formatWithUnit(_ kg: Double, metric: Bool) -> String {
        if metric {
            return String(format: "%.1f kg", kg)
        } else {
            return String(format: "%.1f lbs", kg * 2.20462)
        }
    }

    static var unit: String {
        UserDefaults.standard.bool(forKey: "useMetricUnits") ? "kg" : "lbs"
    }

    static func toKg(_ value: Double, metric: Bool) -> Double {
        metric ? value : value / 2.20462
    }

    static func fromKg(_ kg: Double, metric: Bool) -> Double {
        metric ? kg : kg * 2.20462
    }
}
