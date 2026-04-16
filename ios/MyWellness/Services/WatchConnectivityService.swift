import Foundation
import WatchConnectivity

@MainActor
class WatchConnectivityService: NSObject {
    static let shared = WatchConnectivityService()
    private let session = WCSession.default

    private override init() {
        super.init()
    }

    func activate() {
        guard WCSession.isSupported() else { return }
        session.delegate = self
        session.activate()
    }

    func sendWellnessData(_ data: [String: Any]) {
        guard WCSession.isSupported(), session.activationState == .activated else { return }

        do {
            try session.updateApplicationContext(data)
        } catch {
            if session.isReachable {
                session.sendMessage(data, replyHandler: nil)
            }
        }
    }
}

extension WatchConnectivityService: WCSessionDelegate {
    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {}
    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {}
    nonisolated func sessionDidDeactivate(_ session: WCSession) {
        Task { @MainActor in
            session.activate()
        }
    }
}
