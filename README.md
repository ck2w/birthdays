# Birthdays 🎂

Birthdays is a small iPhone app for keeping track of birthdays, setting reminders, and moving birthday data across platforms with CSV import and export.

The key idea is simple: even if you are not using iCloud sync, your birthday data is not trapped inside one app or one Apple device. You can export to CSV, keep a backup, and import the same data somewhere else later.

Right now the project is set up for local development with a Personal Team in Xcode. Birthday data is stored locally with SwiftData, and the app keeps a future path open for CloudKit-backed iCloud sync when a paid Apple Developer account is available.

## What It Does ✨

- CSV export for easy backup and cross-platform data migration
- CSV import preview before confirming changes
- CSV import support for `YYYY-MM-DD` and `--MM-DD` birthdays
- Manual birthday creation and editing
- Required month/day with optional birth year
- Free-form remarks for gift ideas, MBTI, and other notes
- Birthday list grouped by month
- Sorting by upcoming date, first name, and last name
- Global reminder settings
- Per-person reminder disable switch
- Configurable notification time
- Send Test Notification from settings
- February 29 fallback handling
- Swipe-to-delete from the birthday list
- Local persistence with SwiftData
- Local notifications with `UserNotifications`

## Current Status 🚧

Implemented:

- CSV import and export with preview before import confirmation
- Local backup and cross-platform migration through CSV
- Birthday list UI
- Add/edit birthday flow
- Settings screen
- Reminder scheduling
- Notification permission handling
- Test notification flow
- Local data persistence
- UI test scaffolding for core flows
- Local manual verification for primary user flows

Not currently available in Personal Team mode:

- Real iCloud / CloudKit sync
- Cross-device sync verification

## Tech Stack 🛠️

- SwiftUI
- SwiftData
- UserNotifications
- XCTest / XCUITest

## Preview 📱

<img src="docs/images/home-screen.png" alt="Birthdays home screen" width="30%" />

## Project Structure 📁

```text
Birthdays/
├── Birthdays.xcodeproj
├── Birthdays/
│   ├── Features/
│   ├── Models/
│   ├── Services/
│   ├── Stores/
│   ├── Assets.xcassets/
│   ├── BirthdaysApp.swift
│   └── ContentView.swift
├── BirthdaysTests/
├── BirthdaysUITests/
├── spec.md
└── tasks.md
```

## Getting Started 🚀

### Requirements

- Xcode 26 or newer
- iOS Simulator

### Run the App

1. Open [`Birthdays.xcodeproj`](Birthdays/Birthdays.xcodeproj) in Xcode.
2. Select the `Birthdays` scheme.
3. Choose an iPhone simulator.
4. Press `Run`.

## Personal Team Note 👀

If you use a free Personal Team in Xcode, the app runs in local-only mode.

That means:

- Birthday data is stored on device with SwiftData
- Notifications work normally
- iCloud sync is disabled in the active project configuration

When you later move to a paid Apple Developer account, you can re-enable:

- iCloud / CloudKit capability in Xcode
- CloudKit-backed SwiftData configuration
- Cross-device sync verification

## Testing 🧪

Build from the command line:

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

## Roadmap 🗺️

- Re-enable CloudKit when a paid developer account is available
- Improve CSV import validation and conflict handling
- Revisit command-line full test runs if stricter local automation is needed

## Documentation 📚

- [`spec.md`](spec.md): product and technical specification
- [`tasks.md`](tasks.md): implementation checklist and remaining work
