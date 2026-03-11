//
//  BirthdaysUITests.swift
//  BirthdaysUITests
//
//  Created by Ken Chen on 3/11/26.
//

import XCTest

final class BirthdaysUITests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UITEST"]
    }

    override func tearDownWithError() throws {
        app = nil
    }

    @MainActor
    func testEmptyStateAndCreateBirthdayFlow() throws {
        app.launch()

        XCTAssertTrue(app.staticTexts["empty_state_title"].waitForExistence(timeout: 2))
        XCTAssertEqual(app.staticTexts["empty_state_title"].label, "No birthdays yet")

        app.buttons["empty_state_add_button"].tap()

        let nameField = app.textFields["birthday_name_field"]
        XCTAssertTrue(nameField.waitForExistence(timeout: 2))
        nameField.tap()
        nameField.typeText("Taylor Swift")

        app.buttons["birthday_save_button"].tap()

        XCTAssertTrue(app.staticTexts["Taylor Swift"].waitForExistence(timeout: 2))
    }

    @MainActor
    func testSeededBirthdayListRendersAndSortMenuOpens() throws {
        app.launchArguments += ["UITEST_SEED_BIRTHDAY"]
        app.launch()

        XCTAssertTrue(app.staticTexts["Alex Johnson"].waitForExistence(timeout: 2))

        app.buttons["Sort birthdays"].tap()

        XCTAssertTrue(app.buttons["Sort by First Name"].waitForExistence(timeout: 2))
        XCTAssertTrue(app.buttons["Sort by Last Name"].exists)
        app.buttons["Sort by Last Name"].tap()
    }

    @MainActor
    func testSettingsScreenInteractions() throws {
        app.launch()

        app.buttons["birthday_menu_button"].tap()

        let remindersToggle = app.switches["settings_reminders_toggle"]
        XCTAssertTrue(remindersToggle.waitForExistence(timeout: 2))
        remindersToggle.tap()

        XCTAssertTrue(app.otherElements["settings_reminder_offset_picker"].exists)
        XCTAssertTrue(app.otherElements["settings_notification_time_picker"].exists)
        XCTAssertTrue(app.otherElements["settings_feb29_picker"].exists)

        app.buttons["settings_done_button"].tap()
        XCTAssertTrue(app.navigationBars["Birthdays"].waitForExistence(timeout: 2))
    }
}
