# Birthday iOS App Spec

## Goal

Build an iPhone-only birthday app that lets users manually record birthdays, receive configurable reminders, and sync data across their Apple devices with iCloud.

## Product Scope

### In Scope

- iPhone app only
- Manual birthday entry and editing
- Birthday list grouped by month
- Default sorting by next upcoming birthday
- Additional sorting by first name and last name
- Birth date with required month/day and optional birth year
- One global reminder rule for all birthdays
- Per-person reminder disable switch
- Configurable notification time
- February 29 fallback handling in non-leap years
- iCloud sync for birthday records and app settings
- Local notifications

### Out of Scope

- CSV import/export
- Contacts import
- iPad support
- Apple Watch support
- Per-person custom reminder schedules
- Shared accounts
- Notes, tags, avatars, or extra profile metadata

## Main Screens

### Birthday List

- Default home screen
- Shows all birthdays
- Groups rows by month
- Sorts by next upcoming birthday by default
- Toolbar includes sort and add actions
- Each row shows:
  - placeholder icon
  - name
  - birthday text
  - upcoming age if birth year exists
  - days remaining on the right

Example row copy:

- With birth year: `Turns 34 on March 14`
- Without birth year: `Birthday on March 14`

### Add/Edit Birthday

- Same screen for create and edit
- Fields:
  - name required
  - month/day required
  - birth year optional
  - disable reminders for this person toggle
- Tapping a row opens edit directly
- No separate read-only detail screen in v1

### Settings

- Global reminder enable/disable
- Reminder offset options:
  - same day
  - 1 day before
  - 2 days before
  - 7 days before
- Notification time picker
- February 29 fallback behavior
- If notification permission is denied, show clear guidance to open iOS Settings

### Sort Menu

- Lightweight menu from the list toolbar
- Options:
  - sort by date
  - sort by first name
  - sort by last name

## Data Model

### BirthdayRecord

- `id`
- `name`
- `month`
- `day`
- `birthYear?`
- `remindersDisabled`
- `createdAt`
- `updatedAt`

Do not persist derived values like:

- next birthday date
- days remaining
- upcoming age
- display text

### AppSettings

- `remindersEnabled`
- `reminderOffset`
- `notificationHour`
- `notificationMinute`
- `feb29Fallback`

For v1:

- `reminderOffset`: `sameDay`, `oneDayBefore`, `twoDaysBefore`, `sevenDaysBefore`
- `feb29Fallback`: `feb28`

## Reminder Rules

- If global reminders are off, schedule nothing
- If global reminders are on, all birthdays use the same global reminder rule
- If a birthday has `remindersDisabled = true`, skip it
- Editing a birthday must refresh that birthday's notifications
- Changing reminder settings must rebuild all notifications
- If `birthYear` is missing, reminder copy must not mention age

Example notification copy:

- `Tomorrow is Alex's 34th birthday`
- `Tomorrow is Alex's birthday`

Opening a notification can launch the app to the birthday list in v1.

## Sync Behavior

- Sync birthday records with iCloud
- Sync app settings with iCloud
- Do not sync notification delivery state
- Each device schedules its own local notifications from synced data

## Core Flows

### First Launch

- Show empty birthday list
- Provide clear add action
- Reminders remain off until enabled in settings

### Create Birthday

- User taps add
- Enters name and month/day
- Optionally enters birth year
- Optionally disables reminders for that person
- Saves
- App persists record
- App refreshes list
- App schedules reminders if allowed

### Edit Birthday

- User taps existing row
- Changes fields
- Saves
- App persists changes
- App refreshes ordering and display
- App updates or removes notifications as needed

### Change Settings

- User opens settings
- Enables reminders or updates reminder rule/time
- App requests notification permission if needed
- App persists settings
- App rebuilds reminders

## Edge Cases

- Invalid date blocks save
- Missing birth year omits age
- February 29 birthdays use February 28 in non-leap years
- Cross-year sorting must work correctly
- If notification permission is denied, show warning state in settings
- For close multi-device edits, accept storage-layer final state in v1

## Technical Direction

- SwiftUI for UI
- SwiftData for persistence
- CloudKit-backed iCloud sync for SwiftData
- UserNotifications for local reminders
- Small focused services for:
  - date calculation
  - sorting
  - reminder scheduling
  - notification permission status

## Testing Requirements

- Unit tests for date logic
- Unit tests for sorting
- Unit tests for reminder scheduling
- Unit tests for settings persistence
- UI tests for list flow
- UI tests for settings flow
