import SwiftUI
import UserNotifications

struct RemindersView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("breakfastReminder") private var breakfastReminder: Bool = true
    @AppStorage("lunchReminder") private var lunchReminder: Bool = true
    @AppStorage("dinnerReminder") private var dinnerReminder: Bool = true
    @AppStorage("weightReminder") private var weightReminder: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            headerBar(title: Lang.s("reminders"), onBack: { dismiss() })

            ScrollView {
                VStack(spacing: 16) {
                    VStack(spacing: 0) {
                        reminderRow(
                            id: "breakfast",
                            title: Lang.s("breakfast"),
                            subtitle: "08:00",
                            hour: 8, minute: 0,
                            notifTitle: Lang.s("notif_title_breakfast"),
                            body: Lang.s("time_for_breakfast"),
                            isOn: $breakfastReminder
                        )
                        Divider().padding(.leading, 16)
                        reminderRow(
                            id: "lunch",
                            title: Lang.s("lunch"),
                            subtitle: "12:30",
                            hour: 12, minute: 30,
                            notifTitle: Lang.s("notif_title_lunch"),
                            body: Lang.s("time_for_lunch"),
                            isOn: $lunchReminder
                        )
                        Divider().padding(.leading, 16)
                        reminderRow(
                            id: "dinner",
                            title: Lang.s("dinner"),
                            subtitle: "19:30",
                            hour: 19, minute: 30,
                            notifTitle: Lang.s("notif_title_dinner"),
                            body: Lang.s("time_for_dinner"),
                            isOn: $dinnerReminder
                        )
                        Divider().padding(.leading, 16)
                        reminderRow(
                            id: "weight",
                            title: Lang.s("log_weight_reminder"),
                            subtitle: Lang.s("every_morning"),
                            hour: 7, minute: 0,
                            notifTitle: Lang.s("notif_title_weight"),
                            body: Lang.s("dont_forget_weight"),
                            isOn: $weightReminder
                        )
                    }
                    .background(Color(.systemBackground))
                    .clipShape(.rect(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
            }
        }
        .background(Color(.systemGroupedBackground))
        .onAppear {
            syncAllNotifications()
        }
    }



    private func reminderRow(
        id: String,
        title: String,
        subtitle: String,
        hour: Int,
        minute: Int,
        notifTitle: String,
        body: String,
        isOn: Binding<Bool>
    ) -> some View {
        Toggle(isOn: Binding(
            get: { isOn.wrappedValue },
            set: { newValue in
                isOn.wrappedValue = newValue
                if newValue {
                    scheduleNotification(id: id, title: notifTitle, body: body, hour: hour, minute: minute)
                } else {
                    cancelNotification(id: id)
                }
            }
        )) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .tint(Color.wellnessTeal)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private func scheduleNotification(id: String, title: String, body: String, hour: Int, minute: Int) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            guard granted else { return }
            let content = UNMutableNotificationContent()
            content.title = title
            content.body = body
            content.sound = .default

            var components = DateComponents()
            components.hour = hour
            components.minute = minute

            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            let request = UNNotificationRequest(identifier: "mywellness_\(id)", content: content, trigger: trigger)

            center.removePendingNotificationRequests(withIdentifiers: ["mywellness_\(id)"])
            center.add(request)
        }
    }

    private func cancelNotification(id: String) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: ["mywellness_\(id)"])
    }

    private func syncAllNotifications() {
        NotificationService.syncAllNotifications()
    }
}
