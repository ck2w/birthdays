# CLAUDE.md

## Project Overview

Birthdays is an iPhone-only iOS app for tracking birthdays, setting reminders, and migrating data via CSV import/export. Data is stored locally with SwiftData, with a future path for CloudKit-backed iCloud sync.

## Tech Stack

- SwiftUI
- SwiftData
- UserNotifications
- XCTest / XCUITest
- Xcode 26+, iOS Simulator

## Project Structure

```
Birthdays/
├── Birthdays.xcodeproj
├── Birthdays/
│   ├── Features/        # Screen-level views and view models
│   ├── Models/          # BirthdayRecord, AppSettings, enums
│   ├── Services/        # BirthdayCalculator, BirthdaySorter, ReminderScheduler, CSV
│   ├── Stores/          # AppSettingsStore
│   ├── Assets.xcassets/
│   ├── BirthdaysApp.swift
│   └── ContentView.swift
├── BirthdaysTests/
├── BirthdaysUITests/
├── spec.md              # Product and technical specification
└── tasks.md             # Implementation checklist
```

## Build and Test Commands

Build:
```bash
xcodebuild -project Birthdays/Birthdays.xcodeproj -scheme Birthdays -sdk iphonesimulator build
```

Run unit tests:
```bash
xcodebuild -project Birthdays/Birthdays.xcodeproj -scheme Birthdays -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test -only-testing:BirthdaysTests
```

Run UI tests:
```bash
xcodebuild -project Birthdays/Birthdays.xcodeproj -scheme Birthdays -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test -only-testing:BirthdaysUITests
```

## Key Architecture Decisions

- **No derived value persistence**: Fields like `nextBirthday`, `daysRemaining`, `upcomingAge` are computed at runtime, never stored.
- **Local-only by default**: Uses a standard SwiftData configuration (no CloudKit) for Personal Team development. A CloudKit-backed path is stubbed for future use.
- **Single global reminder rule**: All birthdays share one reminder config; per-person overrides are limited to a disable toggle.
- **CSV format**: `name,birthday,remarks` — birthday is `YYYY-MM-DD` with year or `--MM-DD` without.

## Data Models

**BirthdayRecord**: `id`, `name`, `month`, `day`, `birthYear?`, `remark`, `remindersDisabled`, `createdAt`, `updatedAt`

**AppSettings**: `remindersEnabled`, `reminderOffset`, `notificationHour`, `notificationMinute`, `feb29Fallback`

## Reminder Logic

- If global reminders are off, schedule nothing.
- Skip records where `remindersDisabled = true`.
- Editing a birthday or changing settings triggers a full reminder rebuild.
- Feb 29 birthdays fall back to Feb 28 in non-leap years.

## Development Notes

- iCloud/CloudKit capability is disabled for Personal Team builds. Re-enable in Xcode Signing & Capabilities when a paid Apple Developer account is available.
- Full command-line test suite runs may hit simulator/test-runner instability; prefer targeted test runs.
- Do not deduplicate on CSV import — all valid rows are created as new records.
