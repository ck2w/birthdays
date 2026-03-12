//
//  TestNotificationSchedulerTests.swift
//  BirthdaysTests
//
//  Created by Codex on 3/12/26.
//

import XCTest
import UserNotifications
@testable import Birthdays

final class TestNotificationSchedulerTests: XCTestCase {
    func testScheduleAddsTimeIntervalNotificationRequest() async throws {
        var capturedRequest: UNNotificationRequest?
        var removedIdentifiers: [String] = []
        let scheduler = TestNotificationScheduler(
            notificationCenter: NotificationCenterClient(
                add: { request in
                    capturedRequest = request
                },
                removePending: { identifiers in
                    removedIdentifiers = identifiers
                }
            )
        )

        try await scheduler.schedule(after: 3)

        XCTAssertEqual(removedIdentifiers, [TestNotificationScheduler.identifier])
        XCTAssertEqual(capturedRequest?.identifier, TestNotificationScheduler.identifier)
        XCTAssertEqual(capturedRequest?.content.title, "Test Reminder")
        XCTAssertEqual(capturedRequest?.content.body, "If you can read this, birthday notifications are working.")
        XCTAssertTrue(capturedRequest?.trigger is UNTimeIntervalNotificationTrigger)
    }
}
