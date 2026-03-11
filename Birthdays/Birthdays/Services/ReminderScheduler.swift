//
//  ReminderScheduler.swift
//  Birthdays
//
//  Created by Codex on 3/11/26.
//

import Foundation
import UserNotifications

struct PendingReminder: Equatable {
    let identifier: String
    let title: String
    let body: String
    let scheduledAt: Date
}

struct NotificationCenterClient {
    var add: (UNNotificationRequest) async throws -> Void
    var removePending: ([String]) -> Void

    static let live = NotificationCenterClient(
        add: { request in
            try await UNUserNotificationCenter.current().add(request)
        },
        removePending: { identifiers in
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        }
    )
}

struct ReminderScheduler {
    let calculator: BirthdayCalculator
    let calendar: Calendar
    let notificationCenter: NotificationCenterClient

    init(
        calculator: BirthdayCalculator = BirthdayCalculator(),
        calendar: Calendar = .current,
        notificationCenter: NotificationCenterClient = .live
    ) {
        self.calculator = calculator
        self.calendar = calendar
        self.notificationCenter = notificationCenter
    }

    func syncAll(records: [BirthdayRecord], settings: AppSettings, now: Date = .now) async throws {
        let identifiers = records.map(identifier(for:))
        notificationCenter.removePending(identifiers)

        guard settings.remindersEnabled else {
            return
        }

        for record in records where !record.remindersDisabled {
            guard let reminder = pendingReminder(for: record, settings: settings, now: now) else {
                continue
            }

            try await notificationCenter.add(makeRequest(from: reminder))
        }
    }

    func pendingReminder(for record: BirthdayRecord, settings: AppSettings, now: Date = .now) -> PendingReminder? {
        guard settings.remindersEnabled, !record.remindersDisabled else {
            return nil
        }

        let reminderDate = nextReminderDate(for: record, settings: settings, now: now)
        guard let reminderDate else { return nil }

        let birthdayDate = birthdayDate(forReminderDate: reminderDate, settings: settings)
        let title = "Birthday Reminder"
        let body = reminderBody(for: record, birthdayDate: birthdayDate, reminderDate: reminderDate)

        return PendingReminder(
            identifier: identifier(for: record),
            title: title,
            body: body,
            scheduledAt: reminderDate
        )
    }

    func identifier(for record: BirthdayRecord) -> String {
        "birthday-reminder-\(record.id.uuidString)"
    }

    private func nextReminderDate(for record: BirthdayRecord, settings: AppSettings, now: Date) -> Date? {
        guard let nextBirthday = calculator.nextBirthdayDate(for: record, today: now, fallback: settings.feb29Fallback) else {
            return nil
        }

        guard let firstCandidate = scheduledReminderDate(forBirthday: nextBirthday, settings: settings) else {
            return nil
        }

        if firstCandidate > now {
            return firstCandidate
        }

        guard let nextSearchDate = calendar.date(byAdding: .day, value: 1, to: nextBirthday),
              let followingBirthday = calculator.nextBirthdayDate(for: record, today: nextSearchDate, fallback: settings.feb29Fallback)
        else {
            return nil
        }

        return scheduledReminderDate(forBirthday: followingBirthday, settings: settings)
    }

    private func scheduledReminderDate(forBirthday birthday: Date, settings: AppSettings) -> Date? {
        guard let reminderBase = calendar.date(byAdding: .day, value: -settings.reminderOffset.daysInAdvance, to: birthday) else {
            return nil
        }

        let dateComponents = calendar.dateComponents([.year, .month, .day], from: reminderBase)
        var finalComponents = DateComponents()
        finalComponents.year = dateComponents.year
        finalComponents.month = dateComponents.month
        finalComponents.day = dateComponents.day
        finalComponents.hour = settings.notificationHour
        finalComponents.minute = settings.notificationMinute
        return calendar.date(from: finalComponents)
    }

    private func birthdayDate(forReminderDate reminderDate: Date, settings: AppSettings) -> Date {
        calendar.date(byAdding: .day, value: settings.reminderOffset.daysInAdvance, to: reminderDate) ?? reminderDate
    }

    private func reminderBody(for record: BirthdayRecord, birthdayDate: Date, reminderDate: Date) -> String {
        let leadText = reminderLeadText(forDaysAhead: calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: reminderDate),
            to: calendar.startOfDay(for: birthdayDate)
        ).day ?? 0)
        if let birthYear = record.birthYear {
            let age = calendar.component(.year, from: birthdayDate) - birthYear
            return "\(leadText) is \(record.name)'s \(age)th birthday"
        } else {
            return "\(leadText) is \(record.name)'s birthday"
        }
    }

    private func reminderLeadText(forDaysAhead days: Int) -> String {
        switch days {
        case 0:
            return "Today"
        case 1:
            return "Tomorrow"
        default:
            return "In \(days) days"
        }
    }

    private func makeRequest(from reminder: PendingReminder) -> UNNotificationRequest {
        let content = UNMutableNotificationContent()
        content.title = reminder.title
        content.body = reminder.body
        content.sound = .default

        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: reminder.scheduledAt)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        return UNNotificationRequest(identifier: reminder.identifier, content: content, trigger: trigger)
    }
}
