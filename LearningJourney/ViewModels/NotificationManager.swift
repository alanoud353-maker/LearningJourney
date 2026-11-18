//
//  NotificationManager.swift
//  LearningJourney
//
//  Created by alanoud on 08/06/1448 AH.
//

import Foundation
import UserNotifications

struct NotificationManager {
    private let center = UNUserNotificationCenter.current()
    private let reminderID = "streakReminder"

    // طلب إذن الإشعارات من المستخدم.
    func requestPermission() async throws -> Bool {
        try await center.requestAuthorization(
            options: [.alert, .sound]
        )
    }

    // إلغاء التذكير السابق.
    func cancelReminder() {
        center.removePendingNotificationRequests(
            withIdentifiers: [reminderID]
        )

        center.removeDeliveredNotifications(
            withIdentifiers: [reminderID]
        )
    }

    // التذكير بعد 24 ساعة من آخر نشاط.
    func scheduleReminder(
        lastActivityDate: Date,
        goalEndDate: Date,
        streakCount: Int
    ) async throws {
        cancelReminder()

        let reminderDate = lastActivityDate
            .addingTimeInterval(24 * 60 * 60)

        let resetDate = lastActivityDate
            .addingTimeInterval(32 * 60 * 60)

        let secondsUntilReminder = reminderDate.timeIntervalSinceNow

        guard streakCount > 0,
              secondsUntilReminder > 0,
              resetDate < goalEndDate else {
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "Keep your streak going 🔥"

        let deadline = resetDate.formatted(
            date: .abbreviated,
            time: .shortened
        )

        content.body = "Log your learning before \(deadline) to keep your streak."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: secondsUntilReminder,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: reminderID,
            content: content,
            trigger: trigger
        )

        try await center.add(request)
    }
}
