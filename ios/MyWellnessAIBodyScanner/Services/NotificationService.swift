import Foundation
import UserNotifications

struct NotificationService {
    static func syncAllNotifications() {
        let breakfastOn = UserDefaults.standard.bool(forKey: "breakfastReminder")
        let lunchOn = UserDefaults.standard.bool(forKey: "lunchReminder")
        let dinnerOn = UserDefaults.standard.bool(forKey: "dinnerReminder")
        let weightOn = UserDefaults.standard.bool(forKey: "weightReminder")

        let reminders: [(id: String, title: String, body: String, hour: Int, minute: Int, enabled: Bool)] = [
            ("breakfast", Lang.s("notif_title_breakfast"), Lang.s("time_for_breakfast"), 8, 0, breakfastOn),
            ("lunch", Lang.s("notif_title_lunch"), Lang.s("time_for_lunch"), 12, 30, lunchOn),
            ("dinner", Lang.s("notif_title_dinner"), Lang.s("time_for_dinner"), 19, 30, dinnerOn),
            ("weight", Lang.s("notif_title_weight"), Lang.s("dont_forget_weight"), 7, 0, weightOn)
        ]

        let center = UNUserNotificationCenter.current()

        for r in reminders {
            let identifier = "mywellness_\(r.id)"
            if r.enabled {
                center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                    guard granted else { return }
                    let content = UNMutableNotificationContent()
                    content.title = r.title
                    content.body = r.body
                    content.sound = .default

                    var components = DateComponents()
                    components.hour = r.hour
                    components.minute = r.minute

                    let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
                    let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

                    center.removePendingNotificationRequests(withIdentifiers: [identifier])
                    center.add(request)
                }
            } else {
                center.removePendingNotificationRequests(withIdentifiers: [identifier])
            }
        }
    }
}
