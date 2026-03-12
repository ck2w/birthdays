//
//  TestNotificationScheduler.swift
//  Birthdays
//
//  Created by Codex on 3/12/26.
//

import Foundation
import UserNotifications

struct TestNotificationScheduler {
    private let notificationCenter: NotificationCenterClient

    init(notificationCenter: NotificationCenterClient = .live) {
        self.notificationCenter = notificationCenter
    }

    func schedule(after interval: TimeInterval = 5) async throws {
        notificationCenter.removePending([Self.identifier])
        try await notificationCenter.add(makeRequest(after: interval))
    }

    private func makeRequest(after interval: TimeInterval) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.title = "Test Reminder"
        content.body = "If you can read this, birthday notifications are working."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: max(interval, 1), repeats: false)
        return UNNotificationRequest(
            identifier: Self.identifier,
            content: content,
            trigger: trigger
        )
    }

    static let identifier = "birthday-test-reminder"
}
