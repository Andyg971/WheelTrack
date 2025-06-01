import Foundation
import UserNotifications

/// Service pour gérer les notifications locales (rappels)
class NotificationService {
    /// Demande l'autorisation d'envoyer des notifications
    static func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }

    /// Planifie une notification locale à une date donnée
    static func scheduleNotification(title: String, body: String, date: Date, identifier: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Erreur lors de la planification de la notification :", error)
            }
        }
    }

    /// Annule une notification locale
    static func cancelNotification(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
}

/*
// Exemple d'utilisation :
NotificationService.requestAuthorization { granted in
    if granted {
        NotificationService.scheduleNotification(
            title: "Rappel de maintenance",
            body: "N'oublie pas ta vidange demain !",
            date: Date().addingTimeInterval(3600),
            identifier: "maintenance_reminder"
        )
    }
}
*/ 