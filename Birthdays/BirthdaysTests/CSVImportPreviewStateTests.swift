//
//  CSVImportPreviewStateTests.swift
//  BirthdaysTests
//
//  Created by Codex on 3/12/26.
//

import XCTest
@testable import Birthdays

@MainActor
final class CSVImportPreviewStateTests: XCTestCase {
    func testSummaryMessageIncludesImportedAndSkippedCounts() {
        let state = CSVImportPreviewState(
            result: BirthdayCSVImportResult(
                records: [
                    BirthdayCSVRecord(name: "Alex", month: 3, day: 14, birthYear: 1992, remark: "Likes jazz"),
                    BirthdayCSVRecord(name: "Chris", month: 9, day: 10, birthYear: nil, remark: "")
                ],
                skippedRows: [
                    BirthdayCSVSkippedRow(rowNumber: 4, reason: "Missing birthday")
                ]
            )
        )

        XCTAssertEqual(state.summaryMessage, "2 records ready to import, 1 row will be skipped.")
    }

    func testHasSkippedRowsIsFalseWhenNothingWillBeSkipped() {
        let state = CSVImportPreviewState(
            result: BirthdayCSVImportResult(
                records: [
                    BirthdayCSVRecord(name: "Alex", month: 3, day: 14, birthYear: 1992, remark: "")
                ],
                skippedRows: []
            )
        )

        XCTAssertFalse(state.hasSkippedRows)
    }
}
