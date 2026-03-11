//
//  SettingsViewModelTests.swift
//  BirthdaysTests
//
//  Created by Codex on 3/11/26.
//

import XCTest
@testable import Birthdays

@MainActor
final class SettingsViewModelTests: XCTestCase {
    func testLoadCopiesSettingsValues() {
        let viewModel = SettingsViewModel(permissionClient: .init(getStatus: { .authorized }, requestAccess: { true }))
        let settings = AppSettings(
            remindersEnabled: true,
            reminderOffset: .sevenDaysBefore,
            notificationHour: 9,
            notificationMinute: 30,
            feb29Fallback: .feb28
        )

        viewModel.load(from: settings)

        XCTAssertTrue(viewModel.remindersEnabled)
        XCTAssertEqual(viewModel.reminderOffset, .sevenDaysBefore)
        XCTAssertEqual(viewModel.feb29Fallback, .feb28)
        let components = Calendar.current.dateComponents([.hour, .minute], from: viewModel.notificationTime)
        XCTAssertEqual(components.hour, 9)
        XCTAssertEqual(components.minute, 30)
    }

    func testLoadPermissionStatusReadsClient() async {
        let viewModel = SettingsViewModel(permissionClient: .init(getStatus: { .denied }, requestAccess: { false }))

        await viewModel.loadPermissionStatus()

        XCTAssertEqual(viewModel.permissionStatus, .denied)
    }
}
