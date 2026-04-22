import SwiftUI
import UserNotifications

struct PreferencesView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AppViewModel.self) private var appVM
    @AppStorage("useMetricUnits") private var useMetric: Bool = true
    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = true
    @AppStorage("hapticEnabled") private var hapticEnabled: Bool = true
    @State private var showNotificationDeniedAlert: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            headerBar(title: Lang.s("preferences_title"), onBack: { dismiss() })

            ScrollView {
                VStack(spacing: 16) {
                    settingsCard {
                        VStack(spacing: 0) {
                            toggleRow(title: Lang.s("metric_units"), isOn: $useMetric)
                            Divider().padding(.leading, 16)
                            notificationToggleRow
                            Divider().padding(.leading, 16)
                            toggleRow(title: Lang.s("haptic_feedback"), isOn: $hapticEnabled)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
            }
        }
        .background(Color(.systemGroupedBackground))
        .task {
            await syncNotificationStatus()
        }
        .alert(Lang.s("notif_disabled_title"), isPresented: $showNotificationDeniedAlert) {
            Button(Lang.s("open_settings")) {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button(Lang.s("cancel"), role: .cancel) {}
        } message: {
            Text(Lang.s("notif_disabled_msg"))
        }
    }

    private var notificationToggleRow: some View {
        Toggle(isOn: Binding(
            get: { notificationsEnabled },
            set: { newValue in
                Task {
                    if newValue {
                        await requestNotificationPermission()
                    } else {
                        showNotificationDeniedAlert = true
                    }
                }
            }
        )) {
            Text(Lang.s("notifications_label"))
                .font(.subheadline)
        }
        .tint(Color.wellnessTeal)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private func syncNotificationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        notificationsEnabled = settings.authorizationStatus == .authorized
    }

    private func requestNotificationPermission() async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()

        switch settings.authorizationStatus {
        case .notDetermined:
            do {
                let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
                notificationsEnabled = granted
            } catch {
                notificationsEnabled = false
            }
        case .denied:
            notificationsEnabled = false
            showNotificationDeniedAlert = true
        case .authorized, .provisional, .ephemeral:
            notificationsEnabled = true
        @unknown default:
            notificationsEnabled = false
        }
    }

    private func toggleRow(title: String, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            Text(title)
                .font(.subheadline)
        }
        .tint(Color.wellnessTeal)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private func settingsCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: 0) {
            content()
        }
        .background(Color(.systemBackground).opacity(0.80))
        .clipShape(.rect(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
    }
}
