//
//  BirthdayCSVServiceTests.swift
//  BirthdaysTests
//
//  Created by Codex on 3/11/26.
//

import XCTest
@testable import Birthdays

@MainActor
final class BirthdayCSVServiceTests: XCTestCase {
    private var service: BirthdayCSVService!

    override func setUp() {
        var gregorian = Calendar(identifier: .gregorian)
        gregorian.timeZone = TimeZone(secondsFromGMT: 0)!
        service = BirthdayCSVService(calendar: gregorian)
    }

    override func tearDown() {
        service = nil
    }

    func testExportUsesExpectedColumnsAndBirthdayFormat() {
        let records = [
            BirthdayRecord(name: "Alex", month: 3, day: 14, birthYear: 1992, remark: "Likes jazz"),
            BirthdayRecord(name: "Chris", month: 9, day: 10, remark: "MBTI: INTJ"),
        ]

        let csv = service.export(records: records)

        XCTAssertEqual(
            csv,
            """
            name,birthday,remarks
            Alex,1992-03-14,Likes jazz
            Chris,--09-10,MBTI: INTJ
            """
        )
    }

    func testImportParsesYearlessAndFullBirthdays() throws {
        let csv = """
        name,birthday,remarks
        Alex,1992-03-14,Likes jazz
        Chris,--09-10,MBTI: INTJ
        """

        let result = try service.import(from: csv)

        XCTAssertEqual(
            result,
            BirthdayCSVImportResult(
                records: [
                    BirthdayCSVRecord(name: "Alex", month: 3, day: 14, birthYear: 1992, remark: "Likes jazz"),
                    BirthdayCSVRecord(name: "Chris", month: 9, day: 10, birthYear: nil, remark: "MBTI: INTJ")
                ],
                skippedRows: []
            )
        )
    }

    func testImportSkipsInvalidRowsAndSupportsQuotedFields() throws {
        let csv = """
        name,birthday,remarks
        "Alex Brown",1992-03-14,"Likes books, jazz, and tea"
        Taylor,not-a-date,Invalid
        NoBirthday,,Missing
        """

        let result = try service.import(from: csv)

        XCTAssertEqual(
            result,
            BirthdayCSVImportResult(
                records: [
                    BirthdayCSVRecord(
                        name: "Alex Brown",
                        month: 3,
                        day: 14,
                        birthYear: 1992,
                        remark: "Likes books, jazz, and tea"
                    )
                ],
                skippedRows: [
                    BirthdayCSVSkippedRow(rowNumber: 3, reason: "Unsupported birthday format"),
                    BirthdayCSVSkippedRow(rowNumber: 4, reason: "Missing birthday")
                ]
            )
        )
    }

    func testImportReportsSkippedRowDetails() throws {
        let csv = """
        name,birthday,remarks
        Alex,1992-03-14,Likes jazz
        ,1992-05-01,Missing name
        Taylor,not-a-date,Invalid date
        """

        let result = try service.import(from: csv)

        XCTAssertEqual(
            result.skippedRows,
            [
                BirthdayCSVSkippedRow(rowNumber: 3, reason: "Missing name"),
                BirthdayCSVSkippedRow(rowNumber: 4, reason: "Unsupported birthday format")
            ]
        )
    }
}
