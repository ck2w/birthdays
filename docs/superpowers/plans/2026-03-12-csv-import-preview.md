# CSV Import Preview Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a CSV import preview screen that shows parsed records and skipped rows before writing any imported birthdays to storage.

**Architecture:** Extend the CSV parsing result to include skipped-row details, keep parsing inside `BirthdayCSVService`, and move persistence behind an explicit confirmation step in `SettingsView`. Add a small preview view in the settings feature to render the parsed data without owning persistence logic.

**Tech Stack:** SwiftUI, SwiftData, XCTest, UserNotifications

---

## Chunk 1: Parse Preview Data

### Task 1: Extend CSV parsing results for preview

**Files:**
- Modify: `Birthdays/Birthdays/Services/BirthdayCSVService.swift`
- Test: `Birthdays/BirthdaysTests/BirthdayCSVServiceTests.swift`

- [ ] **Step 1: Write the failing tests**

Add tests that assert:
- invalid rows return skipped-row details with row numbers
- missing required values produce explicit reasons
- valid rows still appear in `records`

- [ ] **Step 2: Run test to verify it fails**

Run: `xcodebuild -project Birthdays/Birthdays.xcodeproj -scheme Birthdays -destination 'id=4B2581B4-8124-43AC-B7E3-7C9C229A4C85' test -only-testing:BirthdaysTests/BirthdayCSVServiceTests`
Expected: FAIL because skipped-row detail data does not exist yet.

- [ ] **Step 3: Write minimal implementation**

Update `BirthdayCSVService` to:
- add a skipped-row model
- capture row numbers while iterating over CSV rows
- store specific user-facing skip reasons
- keep existing valid record parsing behavior

- [ ] **Step 4: Run test to verify it passes**

Run: `xcodebuild -project Birthdays/Birthdays.xcodeproj -scheme Birthdays -destination 'id=4B2581B4-8124-43AC-B7E3-7C9C229A4C85' test -only-testing:BirthdaysTests/BirthdayCSVServiceTests`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add Birthdays/Birthdays/Services/BirthdayCSVService.swift Birthdays/BirthdaysTests/BirthdayCSVServiceTests.swift
git commit -m "feat: add csv import preview parsing"
```

## Chunk 2: Present Preview UI

### Task 2: Add a preview screen for parsed rows

**Files:**
- Create: `Birthdays/Birthdays/Features/Settings/CSVImportPreviewView.swift`
- Modify: `Birthdays/Birthdays/Features/Settings/SettingsView.swift`

- [ ] **Step 1: Write the failing test or define the view contract**

If practical, add a focused UI test; otherwise define the contract in code first:
- preview shows summary counts
- preview lists importable rows
- preview shows skipped rows when present
- import action is explicit

- [ ] **Step 2: Run the targeted verification**

Run a build-focused check first:
`xcodebuild -project Birthdays/Birthdays.xcodeproj -scheme Birthdays -destination 'id=4B2581B4-8124-43AC-B7E3-7C9C229A4C85' build`
Expected: PASS before behavior wiring is complete or reveal missing symbols for the new view.

- [ ] **Step 3: Write minimal implementation**

Implement `CSVImportPreviewView` as a presentational SwiftUI screen with:
- summary section
- importable rows list
- skipped-row section
- cancel/import actions passed in as closures

Update `SettingsView` to:
- parse file contents into preview state
- present preview instead of importing immediately

- [ ] **Step 4: Run build to verify it passes**

Run: `xcodebuild -project Birthdays/Birthdays.xcodeproj -scheme Birthdays -destination 'id=4B2581B4-8124-43AC-B7E3-7C9C229A4C85' build`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add Birthdays/Birthdays/Features/Settings/CSVImportPreviewView.swift Birthdays/Birthdays/Features/Settings/SettingsView.swift
git commit -m "feat: add csv import preview screen"
```

## Chunk 3: Confirm Import and Preserve Existing Behavior

### Task 3: Move persistence behind confirmation

**Files:**
- Modify: `Birthdays/Birthdays/Features/Settings/SettingsView.swift`

- [ ] **Step 1: Write the failing behavior check**

Add or document a regression check for:
- cancel does not write records
- import writes previewed rows
- import completion alert still uses final counts
- reminder rescheduling still occurs after import

- [ ] **Step 2: Run verification to confirm current behavior is incomplete**

Run: `xcodebuild -project Birthdays/Birthdays.xcodeproj -scheme Birthdays -destination 'id=4B2581B4-8124-43AC-B7E3-7C9C229A4C85' build`
Expected: current implementation still imports immediately, so the intended confirmation flow is not present.

- [ ] **Step 3: Write minimal implementation**

Update `SettingsView` so:
- file selection only creates preview state
- import confirmation performs insertion and save
- cancel drops preview state
- success alert still shows imported and skipped totals

- [ ] **Step 4: Run verification**

Run:
- `xcodebuild -project Birthdays/Birthdays.xcodeproj -scheme Birthdays -destination 'id=4B2581B4-8124-43AC-B7E3-7C9C229A4C85' test -only-testing:BirthdaysTests/BirthdayCSVServiceTests`
- `xcodebuild -project Birthdays/Birthdays.xcodeproj -scheme Birthdays -destination 'id=4B2581B4-8124-43AC-B7E3-7C9C229A4C85' build`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add Birthdays/Birthdays/Features/Settings/SettingsView.swift Birthdays/Birthdays/Features/Settings/CSVImportPreviewView.swift Birthdays/Birthdays/Services/BirthdayCSVService.swift Birthdays/BirthdaysTests/BirthdayCSVServiceTests.swift
git commit -m "feat: confirm csv imports with preview"
```
