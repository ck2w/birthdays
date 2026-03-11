//
//  BirthdaysTests.swift
//  BirthdaysTests
//
//  Created by Ken Chen on 3/11/26.
//

import XCTest
@testable import Birthdays

@MainActor
final class BirthdaysTests: XCTestCase {
    private var calendar: Calendar!
    private var calculator: BirthdayCalculator!
    private var sorter: BirthdaySorter!
    private var editorViewModel: BirthdayEditorViewModel!

    override func setUp() {
        var gregorian = Calendar(identifier: .gregorian)
        gregorian.timeZone = TimeZone(secondsFromGMT: 0)!
        calendar = gregorian
        calculator = BirthdayCalculator(calendar: gregorian)
        sorter = BirthdaySorter(calculator: calculator)
        editorViewModel = BirthdayEditorViewModel(calendar: gregorian)
    }

    override func tearDown() {
        editorViewModel = nil
        sorter = nil
        calculator = nil
        calendar = nil
    }

    func testNextBirthdayUsesCurrentYearWhenDateIsStillAhead() {
        let record = BirthdayRecord(name: "Alex", month: 3, day: 14)
        let today = makeDate(year: 2026, month: 3, day: 10)

        let nextBirthday = calculator.nextBirthdayDate(for: record, today: today, fallback: .feb28)

        XCTAssertEqual(nextBirthday, makeDate(year: 2026, month: 3, day: 14))
    }

    func testNextBirthdayRollsIntoNextYearWhenDateHasPassed() {
        let record = BirthdayRecord(name: "Alex", month: 3, day: 9)
        let today = makeDate(year: 2026, month: 3, day: 10)

        let nextBirthday = calculator.nextBirthdayDate(for: record, today: today, fallback: .feb28)

        XCTAssertEqual(nextBirthday, makeDate(year: 2027, month: 3, day: 9))
    }

    func testUpcomingAgeUsesBirthYearWhenPresent() {
        let record = BirthdayRecord(name: "Alex", month: 3, day: 14, birthYear: 1992)
        let today = makeDate(year: 2026, month: 3, day: 10)

        let age = calculator.upcomingAge(for: record, today: today, fallback: .feb28)

        XCTAssertEqual(age, 34)
    }

    func testUpcomingAgeIsNilWhenBirthYearMissing() {
        let record = BirthdayRecord(name: "Alex", month: 3, day: 14)
        let today = makeDate(year: 2026, month: 3, day: 10)

        let age = calculator.upcomingAge(for: record, today: today, fallback: .feb28)

        XCTAssertNil(age)
    }

    func testLeapDayMapsToFebruary28InNonLeapYear() {
        let record = BirthdayRecord(name: "Leap", month: 2, day: 29, birthYear: 2000)
        let today = makeDate(year: 2026, month: 2, day: 20)

        let nextBirthday = calculator.nextBirthdayDate(for: record, today: today, fallback: .feb28)
        let daysUntilBirthday = calculator.daysUntilBirthday(for: record, today: today, fallback: .feb28)
        let age = calculator.upcomingAge(for: record, today: today, fallback: .feb28)

        XCTAssertEqual(nextBirthday, makeDate(year: 2026, month: 2, day: 28))
        XCTAssertEqual(daysUntilBirthday, 8)
        XCTAssertEqual(age, 26)
    }

    func testDateSortOrdersByNextUpcomingBirthday() {
        let today = makeDate(year: 2026, month: 3, day: 10)
        let records = [
            BirthdayRecord(name: "Taylor", month: 4, day: 1),
            BirthdayRecord(name: "Alex", month: 3, day: 14),
            BirthdayRecord(name: "Chris", month: 3, day: 12),
        ]

        let sorted = sorter.sort(records, by: .date, today: today, fallback: .feb28)

        XCTAssertEqual(sorted.map(\.name), ["Chris", "Alex", "Taylor"])
    }

    func testFirstNameSortOrdersAlphabetically() {
        let today = makeDate(year: 2026, month: 3, day: 10)
        let records = [
            BirthdayRecord(name: "Taylor Smith", month: 4, day: 1),
            BirthdayRecord(name: "Alex Brown", month: 3, day: 14),
            BirthdayRecord(name: "Chris Young", month: 3, day: 12),
        ]

        let sorted = sorter.sort(records, by: .firstName, today: today, fallback: .feb28)

        XCTAssertEqual(sorted.map(\.name), ["Alex Brown", "Chris Young", "Taylor Smith"])
    }

    func testLastNameSortOrdersAlphabetically() {
        let today = makeDate(year: 2026, month: 3, day: 10)
        let records = [
            BirthdayRecord(name: "Taylor Smith", month: 4, day: 1),
            BirthdayRecord(name: "Alex Brown", month: 3, day: 14),
            BirthdayRecord(name: "Chris Young", month: 3, day: 12),
        ]

        let sorted = sorter.sort(records, by: .lastName, today: today, fallback: .feb28)

        XCTAssertEqual(sorted.map(\.name), ["Alex Brown", "Taylor Smith", "Chris Young"])
    }

    func testListPresentationGroupsRecordsByDisplayMonth() {
        let today = makeDate(year: 2026, month: 3, day: 10)
        let viewModel = BirthdayListViewModel(calculator: calculator, sorter: sorter)
        let records = [
            BirthdayRecord(name: "Alex", month: 3, day: 14, birthYear: 1992),
            BirthdayRecord(name: "Chris", month: 4, day: 2),
            BirthdayRecord(name: "Taylor", month: 4, day: 30, birthYear: 1990),
        ]

        let sections = viewModel.makeSections(
            records: records,
            sortOption: .date,
            today: today,
            fallback: .feb28
        )

        XCTAssertEqual(sections.map(\.title), ["March", "April"])
        XCTAssertEqual(sections[0].rows.map(\.name), ["Alex"])
        XCTAssertEqual(sections[1].rows.map(\.name), ["Chris", "Taylor"])
    }

    func testListPresentationUsesUpcomingAgeWhenBirthYearExists() {
        let today = makeDate(year: 2026, month: 3, day: 10)
        let viewModel = BirthdayListViewModel(calculator: calculator, sorter: sorter)
        let records = [
            BirthdayRecord(name: "Alex", month: 3, day: 14, birthYear: 1992),
            BirthdayRecord(name: "Chris", month: 3, day: 15),
        ]

        let sections = viewModel.makeSections(
            records: records,
            sortOption: .date,
            today: today,
            fallback: .feb28
        )

        XCTAssertEqual(sections[0].rows[0].subtitle, "Turns 34 on March 14")
        XCTAssertEqual(sections[0].rows[1].subtitle, "Birthday on March 15")
    }

    @MainActor
    func testEditorRejectsMissingName() {
        editorViewModel.month = 3
        editorViewModel.day = 14

        XCTAssertFalse(editorViewModel.isValid)
        XCTAssertThrowsError(
            try editorViewModel.save { _ in
                XCTFail("Save should not run when the form is invalid.")
            }
        )
        XCTAssertEqual(editorViewModel.validationMessage, "Name is required.")
    }

    @MainActor
    func testEditorProducesRecordWithOptionalBirthYear() throws {
        editorViewModel.name = "Alex"
        editorViewModel.month = 3
        editorViewModel.day = 14
        editorViewModel.birthYearText = ""
        editorViewModel.remindersDisabled = true

        var capturedDraft: BirthdayDraft?
        try editorViewModel.save { draft in
            capturedDraft = draft
        }

        XCTAssertEqual(
            capturedDraft,
            BirthdayDraft(
                name: "Alex",
                month: 3,
                day: 14,
                birthYear: nil,
                remindersDisabled: true
            )
        )
    }

    @MainActor
    func testEditorUpdatesExistingRecordFields() {
        let existing = BirthdayRecord(name: "Taylor", month: 1, day: 1, birthYear: 1990)
        let editViewModel = BirthdayEditorViewModel(record: existing, calendar: calendar)
        editViewModel.name = "Taylor Swift"
        editViewModel.month = 12
        editViewModel.day = 13
        editViewModel.birthYearText = "1989"
        editViewModel.remindersDisabled = true
        let now = makeDate(year: 2026, month: 3, day: 11)

        let draft = BirthdayDraft(
            name: "Taylor Swift",
            month: 12,
            day: 13,
            birthYear: 1989,
            remindersDisabled: true
        )
        editViewModel.update(record: existing, with: draft, now: now)

        XCTAssertEqual(existing.name, "Taylor Swift")
        XCTAssertEqual(existing.month, 12)
        XCTAssertEqual(existing.day, 13)
        XCTAssertEqual(existing.birthYear, 1989)
        XCTAssertTrue(existing.remindersDisabled)
        XCTAssertEqual(existing.updatedAt, now)
    }

    private func makeDate(year: Int, month: Int, day: Int) -> Date {
        let components = DateComponents(
            calendar: calendar,
            timeZone: calendar.timeZone,
            year: year,
            month: month,
            day: day
        )
        return calendar.date(from: components)!
    }
}
