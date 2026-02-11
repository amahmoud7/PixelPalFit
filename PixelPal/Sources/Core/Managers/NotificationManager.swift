import UserNotifications

@MainActor
final class NotificationManager {
    static let shared = NotificationManager()

    private let center = UNUserNotificationCenter.current()

    private init() {}

    // MARK: - Permission

    /// Requests notification permission. Returns true if granted.
    func requestPermission() async -> Bool {
        do {
            return try await center.requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            print("NotificationManager: Permission error: \(error)")
            return false
        }
    }

    /// Checks current authorization status.
    func isAuthorized() async -> Bool {
        let settings = await center.notificationSettings()
        return settings.authorizationStatus == .authorized
    }

    // MARK: - Schedule Notifications

    /// Schedules all recurring notifications. Call after permission is granted
    /// and whenever the app enters foreground.
    func scheduleAll() {
        scheduleDailyReminder()
        scheduleEveningMotivation()
        scheduleMissionReminder()
        scheduleWeeklySummary()
    }

    /// Removes all pending notifications and reschedules.
    func refreshSchedule() {
        center.removeAllPendingNotificationRequests()
        scheduleAll()
    }

    // MARK: - Daily Reminder (Morning)

    private func scheduleDailyReminder() {
        let content = UNMutableNotificationContent()
        content.title = "Your Stepper is waiting"
        content.body = "Start walking to keep your character thriving today!"
        content.sound = .default

        // 9:00 AM daily
        var dateComponents = DateComponents()
        dateComponents.hour = 9
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily_morning", content: content, trigger: trigger)
        center.add(request)
    }

    // MARK: - Evening Motivation

    private func scheduleEveningMotivation() {
        let content = UNMutableNotificationContent()
        content.title = "Still time to hit your goal"
        content.body = "A short walk can push your Stepper to vital status!"
        content.sound = .default

        // 7:00 PM daily
        var dateComponents = DateComponents()
        dateComponents.hour = 19
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily_evening", content: content, trigger: trigger)
        center.add(request)
    }

    // MARK: - Re-engagement (after 2 days inactive)

    /// Schedules a one-shot re-engagement notification 2 days from now.
    /// Call this each time the app goes to background.
    func scheduleReEngagement() {
        center.removePendingNotificationRequests(withIdentifiers: ["reengagement"])

        let content = UNMutableNotificationContent()
        content.title = "Your Stepper misses you"
        content.body = "Your character's energy is dropping. Come back and take a walk!"
        content.sound = .default

        // 2 days from now
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 48 * 60 * 60, repeats: false)
        let request = UNNotificationRequest(identifier: "reengagement", content: content, trigger: trigger)
        center.add(request)
    }

    /// Cancels the re-engagement notification (call when app becomes active).
    func cancelReEngagement() {
        center.removePendingNotificationRequests(withIdentifiers: ["reengagement"])
    }

    // MARK: - Milestone Notification

    /// Fires a local notification for streak milestones.
    func notifyStreakMilestone(_ days: Int) {
        let content = UNMutableNotificationContent()
        content.title = "\(days)-Day Streak!"
        content.body = "Your Stepper is thriving. Keep the momentum going!"
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "streak_\(days)", content: content, trigger: trigger)
        center.add(request)
    }

    // MARK: - Streak At Risk (6 PM)

    /// Schedules a streak-at-risk notification for 6 PM if the user has a streak
    /// but hasn't met today's goal yet.
    func scheduleStreakAtRisk(streak: Int, stepsRemaining: Int) {
        center.removePendingNotificationRequests(withIdentifiers: ["streak_at_risk"])

        guard streak > 0, stepsRemaining > 0 else { return }

        let content = UNMutableNotificationContent()
        content.title = "Your \(streak)-day streak needs saving!"
        content.body = "\(stepsRemaining.formatted()) more steps to go. A 20-min walk will save it."
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = 18
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: "streak_at_risk", content: content, trigger: trigger)
        center.add(request)
    }

    // MARK: - Mission Reminder (2 PM)

    /// Schedules a daily mission reminder at 2 PM.
    private func scheduleMissionReminder() {
        let content = UNMutableNotificationContent()
        content.title = "3 missions waiting"
        content.body = "Check today's challenges — your character is counting on you!"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = 14
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "mission_reminder", content: content, trigger: trigger)
        center.add(request)
    }

    // MARK: - Weekly Summary (Sunday 7 PM)

    /// Schedules a weekly summary notification for Sunday at 7 PM.
    private func scheduleWeeklySummary() {
        let content = UNMutableNotificationContent()
        content.title = "Your weekly summary is ready"
        content.body = "See how your Stepper performed this week!"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.weekday = 1 // Sunday
        dateComponents.hour = 19
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "weekly_summary", content: content, trigger: trigger)
        center.add(request)
    }

    // MARK: - Inactivity Reminder

    /// Schedules a nudge when the user has been inactive. Call from background
    /// step monitoring when step delta < 200 over 2 hours.
    /// Respects 8am-9pm window and max 3 per day.
    func scheduleInactivityReminder(activeMissionHint: String? = nil) {
        let hour = Calendar.current.component(.hour, from: Date())
        guard hour >= 8, hour < 21 else { return }

        // Check how many inactivity reminders fired today
        let todayKey = "inactivity_reminder_count_\(Calendar.current.startOfDay(for: Date()).timeIntervalSince1970)"
        let count = UserDefaults.standard.integer(forKey: todayKey)
        guard count < 3 else { return }

        let content = UNMutableNotificationContent()
        content.title = "Time to move!"

        if let hint = activeMissionHint {
            content.body = hint
        } else {
            content.body = "You've been still for a while — a quick 10-min walk gets you 1,000 steps!"
        }
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: "inactivity_\(count)", content: content, trigger: trigger)
        center.add(request)

        UserDefaults.standard.set(count + 1, forKey: todayKey)
    }
}
