//
//  ReminderSchedulerTests.swift
//  BirthdaysTests
//
//  Created by Codex on 3/11/26.
//

import Foundation
import XCTest
@testable import Birthdays

final class ReminderSchedulerTests: XCTestCase {
    private var calendar: Calendar!

    override func setUp() {
        var gregorian = Calendar(identifier: .gregorian)
        gregorian.timeZone = TimeZone(secondsFromGMT: 0)!
        calendar = gregorian
    }

    override func tearDown() {
        calendar = nil
    }

    func testPendingReminderSkipsWhenGlobalRemindersDisabled() {
        let scheduler = makeScheduler()
        let record = BirthdayRecord(name: "Alex", month: 3, day: 14, birthYear: 1992)
        let settings = AppSettings(remindersEnabled: false)
        let now = makeDate(year: 2026, month: 3, day: 10, hour: 9, minute: 0)

        let reminder = scheduler.pendingReminder(for: record, settings: settings, now: now)

        XCTAssertNil(reminder)
    }

    func testPendingReminderSkipsWhenRecordRemindersDisabled() {
        let scheduler = makeScheduler()
        let record = BirthdayRecord(name: "Alex", month: 3, day: 14, birthYear: 1992, remindersDisabled: true)
        let settings = AppSettings(remindersEnabled: true)
        let now = makeDate(year: 2026, month: 3, day: 10, hour: 9, minute: 0)

        let reminder = scheduler.pendingReminder(for: record, settings: settings, now: now)

        XCTAssertNil(reminder)
    }

    func testPendingReminderUsesConfiguredOffsetAndTime() {
        let scheduler = makeScheduler()
        let record = BirthdayRecord(name: "Alex", month: 3, day: 14, birthYear: 1992)
        let settings = AppSettings(
            remindersEnabled: true,
            reminderOffset: .twoDaysBefore,
            notificationHour: 8,
            notificationMinute: 30
        )
        let now = makeDate(year: 2026, month: 3, day: 10, hour: 9, minute: 0)

        let reminder = scheduler.pendingReminder(for: record, settings: settings, now: now)

        XCTAssertEqual(reminder?.scheduledAt, makeDate(year: 2026, month: 3, day: 12, hour: 8, minute: 30))
        XCTAssertEqual(reminder?.body, "In 2 days is Alex's 34th birthday")
    }

    func testPendingReminderOmitsAgeWhenBirthYearMissing() {
        let scheduler = makeScheduler()
        let record = BirthdayRecord(name: "Chris", month: 3, day: 15)
        let settings = AppSettings(
            remindersEnabled: true,
            reminderOffset: .oneDayBefore,
            notificationHour: 8,
            notificationMinute: 0
        )
        let now = makeDate(year: 2026, month: 3, day: 10, hour: 9, minute: 0)

        let reminder = scheduler.pendingReminder(for: record, settings: settings, now: now)

        XCTAssertEqual(reminder?.body, "Tomorrow is Chris's birthday")
    }

    func testPendingReminderRollsForwardWhenTodayTimeAlreadyPassed() {
        let scheduler = makeScheduler()
        let record = BirthdayRecord(name: "Alex", month: 3, day: 10, birthYear: 1992)
        let settings = AppSettings(
            remindersEnabled: true,
            reminderOffset: .sameDay,
            notificationHour: 8,
            notificationMinute: 0
        )
        let now = makeDate(year: 2026, month: 3, day: 10, hour: 9, minute: 0)

        let reminder = scheduler.pendingReminder(for: record, settings: settings, now: now)

        XCTAssertEqual(reminder?.scheduledAt, makeDate(year: 2027, month: 3, day: 10, hour: 8, minute: 0))
    }

    private func makeScheduler() -> ReminderScheduler {
        ReminderScheduler(
            calculator: BirthdayCalculator(calendar: calendar),
            calendar: calendar,
            notificationCenter: .init(add: { _ in }, removePending: { _ in })
        )
    }

    private func makeDate(year: Int, month: Int, day: Int, hour: Int, minute: Int) -> Date {
        let components = DateComponents(
            calendar: calendar,
            timeZone: calendar.timeZone,
            year: year,
            month: month,
            day: day,
            hour: hour,
            minute: minute
        )
        return calendar.date(from: components)!
    }
}
