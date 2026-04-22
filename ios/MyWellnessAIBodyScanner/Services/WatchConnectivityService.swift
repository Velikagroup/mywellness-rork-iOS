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

        if session.isReachable {
            session.sendMessage(data, replyHandler: nil, errorHandler: nil)
        }
    }

    fileprivate func respondToRequest(_ replyHandler: @escaping ([String: Any]) -> Void) {
        Task { @MainActor in
            if let vm = AppViewModel.sharedInstance {
                replyHandler(vm.buildWatchPayload())
            } else {
                replyHandler([:])
            }
        }
    }
}

extension WatchConnectivityService: WCSessionDelegate {
    nonisolated func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        Task { @MainActor in
            if let vm = AppViewModel.sharedInstance {
                vm.syncWidgetData()
            }
        }
    }
    nonisolated func sessionDidBecomeInactive(_ session: WCSession) {}
    nonisolated func sessionDidDeactivate(_ session: WCSession) {
        Task { @MainActor in
            session.activate()
        }
    }
    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        Task { @MainActor in
            if let vm = AppViewModel.sharedInstance {
                replyHandler(vm.buildWatchPayload())
            } else {
                replyHandler([:])
            }
        }
    }
    nonisolated func session(_ session: WCSession, didReceiveMessage message: [String: Any]) {}
}
