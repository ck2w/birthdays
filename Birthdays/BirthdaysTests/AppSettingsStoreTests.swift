//
//  AppSettingsStoreTests.swift
//  BirthdaysTests
//
//  Created by Codex on 3/11/26.
//

import SwiftData
import XCTest
@testable import Birthdays

@MainActor
final class AppSettingsStoreTests: XCTestCase {
    func testDefaultSettingsAreCreatedOnFirstLoad() throws {
        let container = try makeInMemoryContainer()
        let store = AppSettingsStore(modelContext: container.mainContext)

        let settings = try store.fetchOrCreate()

        XCTAssertFalse(settings.remindersEnabled)
        XCTAssertEqual(settings.reminderOffset, .oneDayBefore)
        XCTAssertEqual(settings.notificationHour, 8)
        XCTAssertEqual(settings.notificationMinute, 0)
        XCTAssertEqual(settings.feb29Fallback, .feb28)
    }

    func testUpdatingSettingsPersistsReminderConfiguration() throws {
        let container = try makeInMemoryContainer()
        let store = AppSettingsStore(modelContext: container.mainContext)

        _ = try store.update { settings in
            settings.remindersEnabled = true
            settings.reminderOffset = .sevenDaysBefore
            settings.notificationHour = 9
            settings.notificationMinute = 30
        }

        let fetched = try store.fetchOrCreate()

        XCTAssertTrue(fetched.remindersEnabled)
        XCTAssertEqual(fetched.reminderOffset, .sevenDaysBefore)
        XCTAssertEqual(fetched.notificationHour, 9)
        XCTAssertEqual(fetched.notificationMinute, 30)
    }

    private func makeInMemoryContainer() throws -> ModelContainer {
        let schema = Schema([
            BirthdayRecord.self,
            AppSettings.self,
        ])

        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        return try ModelContainer(for: schema, configurations: [configuration])
    }
}
