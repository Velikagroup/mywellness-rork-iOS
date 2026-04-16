import SwiftUI

@main
struct MyWellnessWatchApp: App {
    init() {
        WatchSessionService.shared.activate()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
