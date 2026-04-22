import SwiftUI
import AudioToolbox

struct ConditionalSensoryFeedback<T: Equatable>: ViewModifier {
    let feedback: SensoryFeedback
    let trigger: T
    @AppStorage("hapticEnabled") private var hapticEnabled: Bool = true

    func body(content: Content) -> some View {
        if hapticEnabled {
            content.sensoryFeedback(feedback, trigger: trigger)
        } else {
            content
        }
    }
}

extension View {
    func conditionalSensoryFeedback<T: Equatable>(_ feedback: SensoryFeedback, trigger: T) -> some View {
        modifier(ConditionalSensoryFeedback(feedback: feedback, trigger: trigger))
    }
}

enum HapticHelper {
    static func impact(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
        guard UserDefaults.standard.object(forKey: "hapticEnabled") as? Bool ?? true else { return }
        UIImpactFeedbackGenerator(style: style).impactOccurred()
    }

    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        guard UserDefaults.standard.object(forKey: "hapticEnabled") as? Bool ?? true else { return }
        UINotificationFeedbackGenerator().notificationOccurred(type)
    }

    static func selection() {
        guard UserDefaults.standard.object(forKey: "hapticEnabled") as? Bool ?? true else { return }
        UISelectionFeedbackGenerator().selectionChanged()
    }

    static func vibrate() {
        guard UserDefaults.standard.object(forKey: "hapticEnabled") as? Bool ?? true else { return }
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
}
