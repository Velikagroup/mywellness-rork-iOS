import Foundation
import WatchConnectivity

@MainActor
@Observable
class WatchSessionService: NSObject {
    static let shared = WatchSessionService()

    var steps: Int = 0
    var bpm: Int = 0
    var sleepHours: Double = 0
    var activeCalories: Int = 0
    var wellnessScore: Double = 0.5
    var moodLabel: String = "---"
    var moodColorR: Double = 0.17
    var moodColorG: Double = 0.60
    var moodColorB: Double = 0.52
    var memojiData: Data? = nil

    private let storageKey = "watchWellnessData"

    private override init() {
        super.init()
        loadFromDisk()
    }

    func activate() {
        guard WCSession.isSupported() else { return }
        WCSession.default.delegate = self
        WCSession.default.activate()
    }

    private func applyContext(_ context: [String: Any]) {
        steps = context["widget_steps"] as? Int ?? 0
        bpm = context["widget_bpm"] as? Int ?? 0
        sleepHours = context["widget_sleepHours"] as? Double ?? 0
        activeCalories = context["widget_activeCalories"] as? Int ?? 0
        wellnessScore = context["widget_wellnessScore"] as? Double ?? 0.5
        moodLabel = context["widget_moodLabel"] as? String ?? "---"
        moodColorR = context["widget_moodColorR"] as? Double ?? 0.17
        moodColorG = context["widget_moodColorG"] as? Double ?? 0.60
        moodColorB = context["widget_moodColorB"] as? Double ?? 0.52
        memojiData = context["widget_memojiData"] as? Data
        saveToDisk()
    }

    private func saveToDisk() {
        var dict: [String: Any] = [
            "widget_steps": steps,
            "widget_bpm": bpm,
            "widget_sleepHours": sleepHours,
            "widget_activeCalories": activeCalories,
            "widget_wellnessScore": wellnessScore,
            "widget_moodLabel": moodLabel,
            "widget_moodColorR": moodColorR,
            "widget_moodColorG": moodColorG,
            "widget_moodColorB": moodColorB
        ]
        if let data = memojiData {
            dict["widget_memojiData"] = data
        }
        UserDefaults.standard.set(dict, forKey: storageKey)
    }

    private func loadFromDisk() {
        guard let dict = UserDefaults.standard.dictionary(forKey: storageKey) else { return }
        steps = dict["widget_steps"] as? Int ?? 0
        bpm = dict["widget_bpm"] as? Int ?? 0
        sleepHours = dict["widget_sleepHours"] as? Double ?? 0
        activeCalories = dict["widget_activeCalories"] as? Int ?? 0
        wellnessScore = dict["widget_wellnessScore"] as? Double ?? 0.5
        moodLabel = dict["widget_moodLabel"] as? String ?? "---"
        moodColorR = dict["widget_moodColorR"] as? Double ?? 0.17
        moodColorG = dict["widget_moodColorG"] as? Double ?? 0.60
        moodColorB = dict["widget_moodColorB"] as? Double ?? 0.52
        memojiData = dict["widget_memojiData"] as? Data
    }
}

extension WatchSessionService: WCSessionDelegate {
    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}

    nonisolated func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        Task { @MainActor in
            self.applyContext(applicationContext)
        }
    }

    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {
        Task { @MainActor in
            self.applyContext(message)
        }
    }

    nonisolated func session(_ session: WCSession, didReceiveUserInfo userInfo: [String: Any] = [:]) {
        Task { @MainActor in
            self.applyContext(userInfo)
        }
    }
}
