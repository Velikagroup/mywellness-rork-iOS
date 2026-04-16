import SwiftUI

@main
struct MyWellnessWatchApp: App {
    @Environment(\.scenePhase) private var scenePhase

    init() {
        WatchSessionService.shared.activate()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    WatchSessionService.shared.requestLatestData()
                }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                WatchSessionService.shared.requestLatestData()
            }
        }
    }
}
