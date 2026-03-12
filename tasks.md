# Birthday iOS App Tasks

## 1. Project Setup

- [x] Create the `Birthdays` iOS app project with SwiftUI
- [x] Add unit test and UI test targets
- [x] Confirm the empty project builds with `xcodebuild`

## 2. Models and Core Logic

- [x] Add `BirthdayRecord`
- [x] Add `AppSettings`
- [x] Add `ReminderOffset`
- [x] Add `Feb29Fallback`
- [x] Write tests for next birthday calculation
- [x] Write tests for age calculation
- [x] Write tests for leap day handling
- [x] Implement `BirthdayCalculator`
- [x] Write tests for date/name sorting
- [x] Implement `BirthdaySorter`

## 3. Persistence and App Settings

- [x] Wire SwiftData container into the app
- [x] Add `AppSettingsStore`
- [x] Write tests for default settings creation
- [x] Write tests for settings updates persistence

## 4. Birthday List

- [x] Add list presentation/view model
- [x] Map records into month sections and row view data
- [x] Build birthday list screen
- [x] Build birthday row view
- [x] Build empty state view
- [x] Build sort menu
- [x] Add swipe-to-delete flow
- [x] Remove reminders after deleting a birthday
- [x] Add UI tests for empty state and list rendering

## 5. Add/Edit Birthday Flow

- [x] Add editor view model
- [x] Add validation for required name and month/day
- [x] Build add/edit birthday screen
- [x] Connect add flow from the list
- [x] Connect edit flow from tapping a row
- [x] Add tests for create and edit flows

## 6. Settings and Permissions

- [x] Add notification permission client
- [x] Build settings view model
- [x] Build settings screen
- [x] Handle denied notification permission state
- [x] Add UI tests for settings interactions

## 7. Reminder Scheduling

- [x] Write scheduler tests
- [x] Implement `ReminderScheduler`
- [x] Schedule reminders after create/edit when allowed
- [x] Rebuild reminders after settings changes
- [x] Remove reminders for records with reminders disabled

## 8. Sync Readiness

- [x] Add a CloudKit-capable SwiftData configuration path in code
- [x] Confirm SwiftData models are compatible with CloudKit requirements
- [x] Verify app still builds after sync-related model changes
- [x] Reconfigure the project to run without iCloud capability on Personal Team
- [ ] Re-enable iCloud / CloudKit capability after moving to a paid Apple Developer account
- [ ] Set Apple Team and confirm iCloud container in Xcode Signing & Capabilities
- [ ] Verify sync on a second signed-in device or simulator pair

## 9. Final Verification

- [ ] Run full unit test suite
- [ ] Run full UI test suite
- [x] Build the app successfully with `xcodebuild`
- [ ] Manually verify:
  - [x] create birthday without year
  - [x] create birthday with year
  - [x] sort by date
  - [x] sort by first name
  - [x] sort by last name
  - [x] delete a birthday and confirm it disappears
  - [x] verify deleted birthday reminder is removed
  - [x] enable reminders
  - [x] deny notifications and verify warning UI
  - [x] disable reminders for one person
  - [ ] after enabling paid developer account support, verify a newly added birthday syncs to another device
  - [ ] after enabling paid developer account support, verify a settings change syncs to another device
