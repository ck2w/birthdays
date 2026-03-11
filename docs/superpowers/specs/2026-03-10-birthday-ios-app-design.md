# Birthday iOS App Design

## Overview

This document defines the first release of an iPhone-only birthday reminder app for this repository.

The app focuses on four core capabilities:

- Manually create and edit birthday records
- Show a full birthday list sorted by the next upcoming birthday
- Send local reminders based on a single global reminder rule
- Sync birthday data and app settings across the user's Apple devices with iCloud

The design intentionally excludes heavier scope such as CSV import/export, contacts import, iPad support, and per-person custom reminder schedules.

## Product Goals

- Make entering and maintaining birthdays fast
- Make upcoming birthdays visible at a glance
- Keep reminder configuration simple and reliable
- Keep the UI close to the reference screens in [`/Users/kenchen/Projects/birthdays/pic/main_page.jpg`](/Users/kenchen/Projects/birthdays/pic/main_page.jpg), [`/Users/kenchen/Projects/birthdays/pic/settings_page.jpg`](/Users/kenchen/Projects/birthdays/pic/settings_page.jpg), and [`/Users/kenchen/Projects/birthdays/pic/main_page_sort.jpg`](/Users/kenchen/Projects/birthdays/pic/main_page_sort.jpg)

## Release Scope

### In Scope

- iPhone app only
- SwiftUI-based native UI
- Manual birthday entry
- Birthday list grouped by month
- Sorting by date and by name
- Birthday date with required month/day and optional birth year
- Global reminder rule for all birthdays
- Per-person reminder disable switch
- Configurable notification time
- Configurable handling for February 29 birthdays in non-leap years
- iCloud sync for birthday records and app settings
- Local notifications generated on-device

### Out of Scope

- CSV import
- CSV export
- Contacts import
- iPad support
- Apple Watch support
- Per-person custom reminder schedules
- Shared family or team accounts
- Notes, tags, custom avatars, or rich profile fields

## User Experience

### 1. Birthday List Screen

This is the default home screen.

Responsibilities:

- Display all saved birthdays
- Sort by the next upcoming birthday by default
- Group visible entries by month
- Show the remaining days until the next birthday
- Provide quick access to sorting and adding a new record

Each list card should show:

- A simple avatar placeholder or icon
- Person name
- Birthday copy
- If birth year exists, the upcoming age
- Days remaining, aligned on the right

Example copy:

- With year: `Turns 34 on March 14`
- Without year: `Birthday on March 14`

The top bar should mirror the reference direction:

- Left: navigation or menu affordance
- Right: sort menu and add button

### 2. Add/Edit Birthday Screen

Add and edit use the same screen.

Fields:

- Name: required
- Month/day: required
- Birth year: optional
- Disable reminders for this person: optional toggle

Behavior:

- Saving returns the user to the list
- The saved record is inserted into the correct sort position
- If reminders are globally enabled and this person is not disabled, the app schedules local notifications after save
- Editing a record re-evaluates any notification tied to that record

The first release does not need a separate read-only detail screen. Tapping a list item should open the edit form directly.

### 3. Settings Screen

The settings screen manages global behavior and should stay close to the provided reference.

Settings:

- Reminders enabled/disabled
- Reminder rule
- Notification time
- February 29 fallback behavior

Reminder rule options for v1:

- On the day
- 1 day before
- 2 days before
- 7 days before

Notification time:

- One configurable time-of-day applied to all reminders

February 29 fallback:

- In non-leap years, remind on February 28

If the user enables reminders before granting notification permission, the app should request system notification authorization from this screen.

If authorization is denied, the screen should clearly state that reminders are enabled in-app but system notifications are not permitted, and guide the user to the iOS Settings app.

### 4. Sort Menu

The sort UI should be a lightweight menu rather than a full screen.

Supported options for v1:

- Sort by date
- Sort by first name
- Sort by last name

Default is sort by date, meaning by the next upcoming birthday.

## Information Model

### Birthday Record

Each birthday record should contain:

- `id`
- `name`
- `month`
- `day`
- `birthYear` nullable
- `remindersDisabled`
- `createdAt`
- `updatedAt`

Derived values should not be persisted if they can be recalculated:

- Next birthday date
- Days remaining
- Upcoming age
- Display strings

### App Settings

The app should maintain a single global settings record containing:

- `remindersEnabled`
- `reminderOffset`
- `notificationHour`
- `notificationMinute`
- `feb29Fallback`

Expected `reminderOffset` values for v1:

- `sameDay`
- `oneDayBefore`
- `twoDaysBefore`
- `sevenDaysBefore`

Expected `feb29Fallback` values for v1:

- `feb28`

## Reminder Rules

The reminder system should be simple and predictable.

Rules:

- If global reminders are disabled, no birthday reminders are scheduled
- If global reminders are enabled, all birthdays follow the same global reminder rule
- If a birthday record has `remindersDisabled = true`, that record is skipped
- If a record changes in a way that affects scheduling, its local notifications are refreshed
- If app settings change in a way that affects scheduling, all local notifications are recalculated
- If `birthYear` is missing, notification text must not mention age

Notification examples:

- With year: `Tomorrow is Alex's 34th birthday`
- Without year: `Tomorrow is Alex's birthday`

Notification destination:

- Opening a notification should launch the app to the birthday list screen in v1

## Sync Model

The app should support iCloud sync for:

- Birthday records
- Global app settings

The app does not need to synchronize notification delivery state across devices. Each device can observe synced data and schedule its own local notifications independently.

This means:

- Birthday content syncs through iCloud
- Reminder settings sync through iCloud
- Each device re-generates its own notification requests locally

This keeps the model simple while still meeting the user's multi-device requirement.

## Core Flows

### First Launch

- Show the birthday list, initially empty
- Provide a clear add action
- Reminders remain off until the user enables them in settings

### Create Birthday

- User taps add
- User enters name and month/day
- User optionally enters birth year
- User optionally disables reminders for that person
- User saves
- App persists the record
- App refreshes the list
- App updates any needed reminders

### Edit Birthday

- User taps a birthday item
- User changes fields
- User saves
- App persists updates
- App refreshes the list ordering and display
- App updates or removes notifications for that record as needed

### Change Reminder Settings

- User opens settings
- User enables reminders or changes rule/time
- App requests permission if needed
- App persists settings
- App recalculates all reminders

## Edge Cases

The app must define behavior for the following cases:

- Invalid date input: save is blocked
- Missing birth year: age is omitted
- February 29 birthday in a non-leap year: treat as February 28
- Notification permission denied: settings show the mismatch and recovery guidance
- Cross-year sorting: birthdays in January should sort correctly when the current month is December
- Multi-device edits close together: accept the storage layer's resolved final state for v1

## Technical Architecture

Recommended stack:

- SwiftUI for all screens
- SwiftData for persistence
- iCloud-backed sync for SwiftData content
- UserNotifications for local reminders

Suggested architecture boundaries:

### UI Layer

Responsible for:

- Birthday list screen
- Add/edit form
- Settings screen
- Sort menu presentation

### Persistence and Sync Layer

Responsible for:

- Reading and writing birthday records
- Reading and writing app settings
- Observing synced changes from iCloud-backed storage

### Reminder Scheduling Layer

Responsible for:

- Turning records plus settings into notification requests
- Cancelling outdated notifications
- Rebuilding notifications when data changes

### Date Calculation Utilities

Responsible for:

- Calculating next birthday date
- Calculating days remaining
- Calculating upcoming age
- Mapping February 29 fallback behavior
- Producing list and notification display text

This separation keeps business logic testable and avoids mixing scheduling logic into views.

## Error Handling

The app should handle errors in a user-visible but lightweight way.

Examples:

- Validation errors should be inline in the form
- Notification permission problems should appear in settings
- Storage or sync issues may surface as non-blocking error states where appropriate, but v1 should avoid building a heavy diagnostics interface

The first release should prioritize graceful fallback over complex recovery flows.

## Testing Strategy

At minimum, the first implementation should include:

### Date Logic Tests

Validate:

- Next birthday calculation
- Days remaining calculation
- Cross-year ordering
- Leap year behavior
- Age calculation when birth year exists

### Reminder Scheduling Tests

Validate:

- Global reminders off means no scheduled reminders
- Per-person disabled reminders are skipped
- Each reminder offset maps to the expected scheduled date
- Editing a birthday refreshes its scheduled notification
- Changing settings rebuilds scheduled notifications

### UI Flow Tests

Validate:

- Creating a birthday
- Editing a birthday
- Sorting birthdays
- Updating reminder settings

## Deferred Features

The following items are explicitly deferred beyond v1:

- CSV import for bulk entry
- CSV export for backup or migration
- Contacts import
- iPad layouts
- Apple Watch support
- Per-person custom reminder rules
- Rich metadata such as notes, tags, profile photos, or relationships

These features should not shape v1 complexity except where future extension points are easy to preserve, such as leaving space in the settings or top-level menu for future import/export actions.

## Summary

Version 1 should deliver a focused iPhone birthday app with:

- Manual birthday entry
- A clean list-first experience
- Global reminder configuration
- Per-person reminder disable
- iCloud sync
- Reliable local notifications

The design intentionally favors clarity and reliability over breadth.
