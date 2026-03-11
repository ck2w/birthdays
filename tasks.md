# Birthday iOS App Tasks

## 1. Project Setup

- [ ] Create the `Birthdays` iOS app project with SwiftUI
- [ ] Add unit test and UI test targets
- [ ] Confirm the empty project builds with `xcodebuild`

## 2. Models and Core Logic

- [ ] Add `BirthdayRecord`
- [ ] Add `AppSettings`
- [ ] Add `ReminderOffset`
- [ ] Add `Feb29Fallback`
- [ ] Write tests for next birthday calculation
- [ ] Write tests for age calculation
- [ ] Write tests for leap day handling
- [ ] Implement `BirthdayCalculator`
- [ ] Write tests for date/name sorting
- [ ] Implement `BirthdaySorter`

## 3. Persistence and App Settings

- [ ] Wire SwiftData container into the app
- [ ] Add `AppSettingsStore`
- [ ] Write tests for default settings creation
- [ ] Write tests for settings updates persistence

## 4. Birthday List

- [ ] Add list presentation/view model
- [ ] Map records into month sections and row view data
- [ ] Build birthday list screen
- [ ] Build birthday row view
- [ ] Build empty state view
- [ ] Build sort menu
- [ ] Add UI tests for empty state and list rendering

## 5. Add/Edit Birthday Flow

- [ ] Add editor view model
- [ ] Add validation for required name and month/day
- [ ] Build add/edit birthday screen
- [ ] Connect add flow from the list
- [ ] Connect edit flow from tapping a row
- [ ] Add tests for create and edit flows

## 6. Settings and Permissions

- [ ] Add notification permission client
- [ ] Build settings view model
- [ ] Build settings screen
- [ ] Handle denied notification permission state
- [ ] Add UI tests for settings interactions

## 7. Reminder Scheduling

- [ ] Write scheduler tests
- [ ] Implement `ReminderScheduler`
- [ ] Schedule reminders after create/edit when allowed
- [ ] Rebuild reminders after settings changes
- [ ] Remove reminders for records with reminders disabled

## 8. iCloud Sync

- [ ] Enable iCloud / CloudKit capability
- [ ] Confirm SwiftData models sync correctly
- [ ] Verify app still builds after capability changes

## 9. Final Verification

- [ ] Run full unit test suite
- [ ] Run full UI test suite
- [ ] Build the app successfully with `xcodebuild`
- [ ] Manually verify:
  - create birthday without year
  - create birthday with year
  - sort by date
  - sort by first name
  - sort by last name
  - enable reminders
  - deny notifications and verify warning UI
  - disable reminders for one person
