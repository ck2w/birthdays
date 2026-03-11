//
//  BirthdayCalculator.swift
//  Birthdays
//
//  Created by Codex on 3/11/26.
//

import Foundation

struct BirthdayCalculator {
    let calendar: Calendar

    init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    func nextBirthdayDate(for record: BirthdayRecord, today: Date, fallback: Feb29Fallback) -> Date? {
        nextBirthdayDate(month: record.month, day: record.day, today: today, fallback: fallback)
    }

    func nextBirthdayDate(month: Int, day: Int, today: Date, fallback: Feb29Fallback) -> Date? {
        let todayAtStart = calendar.startOfDay(for: today)
        let currentYear = calendar.component(.year, from: todayAtStart)

        for year in [currentYear, currentYear + 1] {
            let resolved = resolvedMonthDay(month: month, day: day, year: year, fallback: fallback)
            var components = DateComponents()
            components.calendar = calendar
            components.year = year
            components.month = resolved.month
            components.day = resolved.day

            guard let candidate = calendar.date(from: components) else {
                continue
            }

            if candidate >= todayAtStart {
                return candidate
            }
        }

        return nil
    }

    func daysUntilBirthday(for record: BirthdayRecord, today: Date, fallback: Feb29Fallback) -> Int? {
        guard let nextBirthday = nextBirthdayDate(for: record, today: today, fallback: fallback) else {
            return nil
        }

        return calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: today),
            to: calendar.startOfDay(for: nextBirthday)
        ).day
    }

    func upcomingAge(for record: BirthdayRecord, today: Date, fallback: Feb29Fallback) -> Int? {
        guard let birthYear = record.birthYear,
              let nextBirthday = nextBirthdayDate(for: record, today: today, fallback: fallback)
        else {
            return nil
        }

        let birthdayYear = calendar.component(.year, from: nextBirthday)
        return birthdayYear - birthYear
    }

    private func resolvedMonthDay(month: Int, day: Int, year: Int, fallback: Feb29Fallback) -> (month: Int, day: Int) {
        guard month == 2, day == 29, !calendar.range(of: .day, in: .month, for: dateForMonth(year: year, month: 2))!.contains(29) else {
            return (month, day)
        }

        switch fallback {
        case .feb28:
            return (2, 28)
        }
    }

    private func dateForMonth(year: Int, month: Int) -> Date {
        var components = DateComponents()
        components.calendar = calendar
        components.year = year
        components.month = month
        components.day = 1
        return calendar.date(from: components) ?? .distantPast
    }
}
