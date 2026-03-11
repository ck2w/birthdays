# Birthday iOS App Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build an iPhone-only birthday reminder app with manual birthday entry, iCloud-backed persistence, and local notifications using a single global reminder rule.

**Architecture:** Use a native SwiftUI app backed by SwiftData models for birthday records and app settings. Keep business logic isolated in small services for date calculations, sorting, and notification scheduling so views stay thin and test coverage focuses on deterministic logic first.

**Tech Stack:** SwiftUI, SwiftData, CloudKit/iCloud sync for SwiftData, UserNotifications, XCTest, XCUITest, `xcodebuild`

---

## File Structure

Planned project layout:

- Create: `Birthdays.xcodeproj`
- Create: `Birthdays/`
- Create: `Birthdays/BirthdaysApp.swift`
- Create: `Birthdays/Models/BirthdayRecord.swift`
- Create: `Birthdays/Models/AppSettings.swift`
- Create: `Birthdays/Models/ReminderOffset.swift`
- Create: `Birthdays/Models/Feb29Fallback.swift`
- Create: `Birthdays/Services/BirthdayCalculator.swift`
- Create: `Birthdays/Services/BirthdaySorter.swift`
- Create: `Birthdays/Services/ReminderScheduler.swift`
- Create: `Birthdays/Services/NotificationPermissionClient.swift`
- Create: `Birthdays/Stores/AppSettingsStore.swift`
- Create: `Birthdays/Features/BirthdayList/BirthdayListView.swift`
- Create: `Birthdays/Features/BirthdayList/BirthdayListViewModel.swift`
- Create: `Birthdays/Features/BirthdayList/BirthdayRowView.swift`
- Create: `Birthdays/Features/BirthdayEditor/BirthdayEditorView.swift`
- Create: `Birthdays/Features/BirthdayEditor/BirthdayEditorViewModel.swift`
- Create: `Birthdays/Features/Settings/SettingsView.swift`
- Create: `Birthdays/Features/Settings/SettingsViewModel.swift`
- Create: `Birthdays/Features/Shared/EmptyStateView.swift`
- Create: `Birthdays/Features/Shared/SortMenuView.swift`
- Create: `Birthdays/Resources/Assets.xcassets`
- Create: `BirthdaysTests/`
- Create: `BirthdaysTests/BirthdayCalculatorTests.swift`
- Create: `BirthdaysTests/BirthdaySorterTests.swift`
- Create: `BirthdaysTests/ReminderSchedulerTests.swift`
- Create: `BirthdaysTests/AppSettingsStoreTests.swift`
- Create: `BirthdaysUITests/`
- Create: `BirthdaysUITests/BirthdayListFlowUITests.swift`
- Create: `BirthdaysUITests/SettingsFlowUITests.swift`

Notes for implementer:

- Keep each file focused on one responsibility.
- Views should delegate business logic to services or small view models.
- Do not persist derived values such as age or days remaining.
- Use SwiftData models only for persisted fields.

## Chunk 1: Bootstrap the iOS Project

### Task 1: Create the Xcode app skeleton

**Files:**
- Create: `Birthdays.xcodeproj`
- Create: `Birthdays/BirthdaysApp.swift`
- Create: `Birthdays/Resources/Assets.xcassets`
- Create: `BirthdaysTests/`
- Create: `BirthdaysUITests/`

- [ ] **Step 1: Create the empty iOS app target and test targets**

Use Xcode to create:

- An iOS App named `Birthdays`
- Interface: SwiftUI
- Language: Swift
- Include Unit Tests: yes
- Include UI Tests: yes
- Storage: none for now, to be wired manually

- [ ] **Step 2: Verify the generated project builds before changes**

Run:

```bash
xcodebuild -scheme Birthdays -destination 'platform=iOS Simulator,name=iPhone 16' build
```

Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 3: Commit the scaffold**

```bash
git add Birthdays.xcodeproj Birthdays BirthdaysTests BirthdaysUITests
git commit -m "chore: scaffold birthdays ios app"
```

## Chunk 2: Define the Domain Model and Pure Date Logic

### Task 2: Add the persisted model types

**Files:**
- Create: `Birthdays/Models/BirthdayRecord.swift`
- Create: `Birthdays/Models/AppSettings.swift`
- Create: `Birthdays/Models/ReminderOffset.swift`
- Create: `Birthdays/Models/Feb29Fallback.swift`
- Modify: `Birthdays/BirthdaysApp.swift`
- Test: `BirthdaysTests/BirthdayCalculatorTests.swift`

- [ ] **Step 1: Write the failing date-logic tests**

```swift
func testNextBirthdayUsesCurrentYearWhenDateIsStillAhead()
func testNextBirthdayRollsIntoNextYearWhenDateHasPassed()
func testUpcomingAgeUsesBirthYearWhenPresent()
func testUpcomingAgeIsNilWhenBirthYearMissing()
func testLeapDayMapsToFebruary28InNonLeapYear()
```

- [ ] **Step 2: Run the tests and confirm they fail**

Run:

```bash
xcodebuild test -scheme Birthdays -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:BirthdaysTests/BirthdayCalculatorTests
```

Expected: failure because calculator types do not exist yet.

- [ ] **Step 3: Implement persisted enums and models**

Create minimal model definitions for:

- `BirthdayRecord`
- `AppSettings`
- `ReminderOffset`
- `Feb29Fallback`

Persist only:

- `name`
- `month`
- `day`
- `birthYear`
- `remindersDisabled`
- settings fields from the spec

- [ ] **Step 4: Add a minimal `BirthdayCalculator` implementation**

Implement methods for:

- `nextBirthdayDate(for:today:fallback:)`
- `daysUntilBirthday(for:today:fallback:)`
- `upcomingAge(for:today:fallback:)`

- [ ] **Step 5: Re-run the calculator tests**

Run the same `xcodebuild test` command.

Expected: calculator tests pass.

- [ ] **Step 6: Commit**

```bash
git add Birthdays/BirthdaysApp.swift Birthdays/Models Birthdays/Services/BirthdayCalculator.swift BirthdaysTests/BirthdayCalculatorTests.swift
git commit -m "feat: add birthday models and date calculator"
```

### Task 3: Add sorting logic

**Files:**
- Create: `Birthdays/Services/BirthdaySorter.swift`
- Test: `BirthdaysTests/BirthdaySorterTests.swift`

- [ ] **Step 1: Write the failing sorter tests**

```swift
func testDateSortOrdersByNextUpcomingBirthday()
func testFirstNameSortOrdersAlphabetically()
func testLastNameSortOrdersAlphabetically()
```

- [ ] **Step 2: Run the sorter tests and confirm they fail**

Run:

```bash
xcodebuild test -scheme Birthdays -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:BirthdaysTests/BirthdaySorterTests
```

Expected: failure because sorter type does not exist.

- [ ] **Step 3: Implement `BirthdaySorter`**

Provide deterministic sorting functions that accept records and a current date.

- [ ] **Step 4: Re-run the sorter tests**

Expected: sorter tests pass.

- [ ] **Step 5: Commit**

```bash
git add Birthdays/Services/BirthdaySorter.swift BirthdaysTests/BirthdaySorterTests.swift
git commit -m "feat: add birthday sorting logic"
```

## Chunk 3: Wire Persistence and App Settings

### Task 4: Add a SwiftData container and settings store

**Files:**
- Modify: `Birthdays/BirthdaysApp.swift`
- Create: `Birthdays/Stores/AppSettingsStore.swift`
- Test: `BirthdaysTests/AppSettingsStoreTests.swift`

- [ ] **Step 1: Write the failing settings-store tests**

```swift
func testDefaultSettingsAreCreatedOnFirstLoad()
func testUpdatingSettingsPersistsReminderConfiguration()
```

- [ ] **Step 2: Run the settings tests and confirm they fail**

Run:

```bash
xcodebuild test -scheme Birthdays -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:BirthdaysTests/AppSettingsStoreTests
```

Expected: failure because store and container wiring do not exist.

- [ ] **Step 3: Implement the app container setup**

Wire a `ModelContainer` in `BirthdaysApp` for:

- `BirthdayRecord`
- `AppSettings`

Prepare the container so CloudKit-backed sync can be enabled during app capability setup.

- [ ] **Step 4: Implement `AppSettingsStore`**

Responsibilities:

- Fetch or create the singleton settings record
- Save updated settings values
- Expose an API that view models can use

- [ ] **Step 5: Re-run the settings tests**

Expected: settings-store tests pass.

- [ ] **Step 6: Commit**

```bash
git add Birthdays/BirthdaysApp.swift Birthdays/Stores/AppSettingsStore.swift BirthdaysTests/AppSettingsStoreTests.swift
git commit -m "feat: add app settings persistence"
```

## Chunk 4: Build the Birthday List Experience

### Task 5: Create the list view model

**Files:**
- Create: `Birthdays/Features/BirthdayList/BirthdayListViewModel.swift`
- Modify: `Birthdays/Services/BirthdayCalculator.swift`
- Modify: `Birthdays/Services/BirthdaySorter.swift`
- Test: `BirthdaysTests/BirthdaySorterTests.swift`

- [ ] **Step 1: Add a failing test for grouped list presentation**

```swift
func testListPresentationGroupsRecordsByDisplayMonth()
func testListPresentationUsesUpcomingAgeWhenBirthYearExists()
```

- [ ] **Step 2: Run targeted tests and confirm failure**

Run:

```bash
xcodebuild test -scheme Birthdays -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:BirthdaysTests/BirthdaySorterTests
```

Expected: failure because list presentation helpers do not exist.

- [ ] **Step 3: Implement the view-model mapping**

Add a small presentation layer that turns models into:

- section title
- subtitle text
- right-side day count
- stable row identifiers

- [ ] **Step 4: Re-run tests**

Expected: grouping and subtitle tests pass.

- [ ] **Step 5: Commit**

```bash
git add Birthdays/Features/BirthdayList/BirthdayListViewModel.swift Birthdays/Services/BirthdayCalculator.swift Birthdays/Services/BirthdaySorter.swift BirthdaysTests/BirthdaySorterTests.swift
git commit -m "feat: add birthday list presentation logic"
```

### Task 6: Build the list UI

**Files:**
- Create: `Birthdays/Features/BirthdayList/BirthdayListView.swift`
- Create: `Birthdays/Features/BirthdayList/BirthdayRowView.swift`
- Create: `Birthdays/Features/Shared/EmptyStateView.swift`
- Create: `Birthdays/Features/Shared/SortMenuView.swift`
- Modify: `Birthdays/BirthdaysApp.swift`
- Test: `BirthdaysUITests/BirthdayListFlowUITests.swift`

- [ ] **Step 1: Write the failing UI tests**

Add tests for:

- empty list shows add affordance
- saved birthdays appear in the list
- sort menu is reachable

- [ ] **Step 2: Run the UI tests and confirm they fail**

Run:

```bash
xcodebuild test -scheme Birthdays -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:BirthdaysUITests/BirthdayListFlowUITests
```

Expected: failure because the list UI and accessibility hooks do not exist.

- [ ] **Step 3: Implement the SwiftUI list**

Requirements:

- grouped by month
- default date sort
- toolbar add button
- toolbar sort menu
- empty state when no birthdays exist

- [ ] **Step 4: Re-run the UI tests**

Expected: list UI tests pass.

- [ ] **Step 5: Commit**

```bash
git add Birthdays/BirthdaysApp.swift Birthdays/Features/BirthdayList Birthdays/Features/Shared BirthdaysUITests/BirthdayListFlowUITests.swift
git commit -m "feat: build birthday list screen"
```

## Chunk 5: Build Create/Edit Birthday Flow

### Task 7: Add the birthday editor view model

**Files:**
- Create: `Birthdays/Features/BirthdayEditor/BirthdayEditorViewModel.swift`
- Test: `BirthdaysTests/BirthdayCalculatorTests.swift`

- [ ] **Step 1: Write failing editor validation tests**

```swift
func testEditorRejectsMissingName()
func testEditorRejectsMissingMonthDay()
func testEditorProducesRecordWithOptionalBirthYear()
```

- [ ] **Step 2: Run the tests and confirm they fail**

Run:

```bash
xcodebuild test -scheme Birthdays -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:BirthdaysTests/BirthdayCalculatorTests
```

Expected: failure because editor validation logic does not exist.

- [ ] **Step 3: Implement editor state and validation**

Keep the view model responsible for:

- form field state
- validation messages
- mapping form input into `BirthdayRecord`

- [ ] **Step 4: Re-run the tests**

Expected: editor validation tests pass.

- [ ] **Step 5: Commit**

```bash
git add Birthdays/Features/BirthdayEditor/BirthdayEditorViewModel.swift BirthdaysTests/BirthdayCalculatorTests.swift
git commit -m "feat: add birthday editor validation"
```

### Task 8: Build the add/edit screen and connect it to the list

**Files:**
- Create: `Birthdays/Features/BirthdayEditor/BirthdayEditorView.swift`
- Modify: `Birthdays/Features/BirthdayList/BirthdayListView.swift`
- Modify: `Birthdays/Features/BirthdayList/BirthdayListViewModel.swift`
- Test: `BirthdaysUITests/BirthdayListFlowUITests.swift`

- [ ] **Step 1: Add failing UI tests for creating and editing birthdays**

Add tests for:

- opening the add form
- saving a valid birthday
- editing an existing birthday
- toggling per-person reminders

- [ ] **Step 2: Run the UI tests and confirm they fail**

Run the same `BirthdayListFlowUITests` target.

- [ ] **Step 3: Implement the editor UI**

Requirements:

- name field
- month/day picker or equivalent controls
- optional birth year input
- per-person reminder toggle
- save button disabled for invalid state

- [ ] **Step 4: Present the editor from the list and support editing existing records**

- [ ] **Step 5: Re-run the UI tests**

Expected: add/edit UI tests pass.

- [ ] **Step 6: Commit**

```bash
git add Birthdays/Features/BirthdayEditor Birthdays/Features/BirthdayList BirthdaysUITests/BirthdayListFlowUITests.swift
git commit -m "feat: add birthday editor flow"
```

## Chunk 6: Build Settings and Notification Permission Flow

### Task 9: Implement notification permission access

**Files:**
- Create: `Birthdays/Services/NotificationPermissionClient.swift`
- Test: `BirthdaysTests/ReminderSchedulerTests.swift`

- [ ] **Step 1: Write failing tests for permission-state mapping**

```swift
func testPermissionClientMapsDeniedStatus()
func testPermissionClientMapsAuthorizedStatus()
```

- [ ] **Step 2: Run the tests and confirm they fail**

Run:

```bash
xcodebuild test -scheme Birthdays -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:BirthdaysTests/ReminderSchedulerTests
```

Expected: failure because permission client does not exist.

- [ ] **Step 3: Implement `NotificationPermissionClient`**

Expose:

- current authorization status
- request authorization

- [ ] **Step 4: Re-run the targeted tests**

Expected: permission tests pass.

- [ ] **Step 5: Commit**

```bash
git add Birthdays/Services/NotificationPermissionClient.swift BirthdaysTests/ReminderSchedulerTests.swift
git commit -m "feat: add notification permission client"
```

### Task 10: Build the settings view model and settings UI

**Files:**
- Create: `Birthdays/Features/Settings/SettingsViewModel.swift`
- Create: `Birthdays/Features/Settings/SettingsView.swift`
- Modify: `Birthdays/Stores/AppSettingsStore.swift`
- Test: `BirthdaysUITests/SettingsFlowUITests.swift`

- [ ] **Step 1: Write failing UI tests for settings**

Add tests for:

- opening settings
- toggling reminders
- changing reminder offset
- changing notification time
- displaying denied-permission guidance

- [ ] **Step 2: Run the settings UI tests and confirm they fail**

Run:

```bash
xcodebuild test -scheme Birthdays -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:BirthdaysUITests/SettingsFlowUITests
```

Expected: failure because settings UI does not exist.

- [ ] **Step 3: Implement settings view model**

Responsibilities:

- load and update app settings
- expose available reminder offsets
- expose permission state
- handle enable-reminders action

- [ ] **Step 4: Implement the settings screen**

Requirements:

- global reminder toggle
- reminder offset picker
- notification time picker
- February 29 fallback row
- permission warning copy when notifications are denied

- [ ] **Step 5: Re-run the settings UI tests**

Expected: settings UI tests pass.

- [ ] **Step 6: Commit**

```bash
git add Birthdays/Features/Settings Birthdays/Stores/AppSettingsStore.swift BirthdaysUITests/SettingsFlowUITests.swift
git commit -m "feat: add reminder settings screen"
```

## Chunk 7: Implement Reminder Scheduling

### Task 11: Add reminder scheduling logic

**Files:**
- Create: `Birthdays/Services/ReminderScheduler.swift`
- Test: `BirthdaysTests/ReminderSchedulerTests.swift`

- [ ] **Step 1: Write failing scheduler tests**

```swift
func testSchedulerSkipsAllBirthdaysWhenGlobalRemindersDisabled()
func testSchedulerSkipsBirthdayWhenRecordRemindersDisabled()
func testSchedulerSchedulesForConfiguredOffsetAndTime()
func testSchedulerOmitsAgeWhenBirthYearMissing()
func testSchedulerRefreshesRequestsForEditedBirthday()
```

- [ ] **Step 2: Run the scheduler tests and confirm they fail**

Run:

```bash
xcodebuild test -scheme Birthdays -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:BirthdaysTests/ReminderSchedulerTests
```

Expected: failure because scheduler does not exist.

- [ ] **Step 3: Implement `ReminderScheduler` with an injectable notification center client**

Required responsibilities:

- build reminder date from record + settings
- build localized notification body
- replace existing pending requests for changed records
- rebuild all requests when global settings change

- [ ] **Step 4: Re-run the scheduler tests**

Expected: reminder scheduler tests pass.

- [ ] **Step 5: Commit**

```bash
git add Birthdays/Services/ReminderScheduler.swift BirthdaysTests/ReminderSchedulerTests.swift
git commit -m "feat: add birthday reminder scheduling"
```

### Task 12: Hook reminder scheduling into app flows

**Files:**
- Modify: `Birthdays/Features/BirthdayEditor/BirthdayEditorViewModel.swift`
- Modify: `Birthdays/Features/Settings/SettingsViewModel.swift`
- Modify: `Birthdays/Stores/AppSettingsStore.swift`
- Test: `BirthdaysUITests/BirthdayListFlowUITests.swift`
- Test: `BirthdaysUITests/SettingsFlowUITests.swift`

- [ ] **Step 1: Add failing integration tests around save and settings changes**

Add checks for:

- saving a birthday schedules reminders when allowed
- disabling a person's reminders removes pending requests
- changing global reminder settings rebuilds pending requests

- [ ] **Step 2: Run the affected test suites and confirm failure**

Run:

```bash
xcodebuild test -scheme Birthdays -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:BirthdaysUITests/BirthdayListFlowUITests -only-testing:BirthdaysUITests/SettingsFlowUITests
```

Expected: failure because scheduling hooks are not wired.

- [ ] **Step 3: Inject and connect the scheduler**

Wire scheduling calls into:

- record save flow
- record edit flow
- settings update flow

- [ ] **Step 4: Re-run the affected tests**

Expected: integration tests pass.

- [ ] **Step 5: Commit**

```bash
git add Birthdays/Features/BirthdayEditor/BirthdayEditorViewModel.swift Birthdays/Features/Settings/SettingsViewModel.swift Birthdays/Stores/AppSettingsStore.swift BirthdaysUITests/BirthdayListFlowUITests.swift BirthdaysUITests/SettingsFlowUITests.swift
git commit -m "feat: wire reminder scheduling into app flows"
```

## Chunk 8: Enable iCloud Sync and Final Verification

### Task 13: Enable app capabilities and verify sync configuration

**Files:**
- Modify: `Birthdays.xcodeproj`
- Modify: `Birthdays/BirthdaysApp.swift`

- [ ] **Step 1: Enable the CloudKit/iCloud capability in the app target**

Configure the app target for the correct iCloud container and CloudKit-backed SwiftData sync.

- [ ] **Step 2: Verify local build still succeeds**

Run:

```bash
xcodebuild -scheme Birthdays -destination 'platform=iOS Simulator,name=iPhone 16' build
```

Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 3: Commit**

```bash
git add Birthdays.xcodeproj Birthdays/BirthdaysApp.swift
git commit -m "feat: enable icloud sync"
```

### Task 14: Run full verification before completion

**Files:**
- No code changes required unless failures are found

- [ ] **Step 1: Run the full test suite**

Run:

```bash
xcodebuild test -scheme Birthdays -destination 'platform=iOS Simulator,name=iPhone 16'
```

Expected: all unit tests and UI tests pass.

- [ ] **Step 2: Run a final build**

Run:

```bash
xcodebuild -scheme Birthdays -destination 'platform=iOS Simulator,name=iPhone 16' build
```

Expected: `** BUILD SUCCEEDED **`

- [ ] **Step 3: Perform a manual checklist in the simulator**

Verify:

- create a birthday without year
- create a birthday with year
- sort by date
- sort by first and last name
- enable reminders
- deny notifications and confirm warning UI
- disable reminders for one person

- [ ] **Step 4: Commit any final fixes**

```bash
git add .
git commit -m "chore: finalize birthday ios app"
```

## Execution Notes

- Keep commits small and aligned to the tasks above.
- Prefer dependency injection for notification and date providers so tests stay deterministic.
- Do not add CSV import/export work in this implementation; that is intentionally deferred.
- If simulator device names differ locally, use `xcrun simctl list devices` and substitute an available iPhone simulator.

Plan complete and saved to `docs/superpowers/plans/2026-03-10-birthday-ios-app.md`. Ready to execute?
