# CSV Import Preview Design

## Goal

Add a lightweight CSV import preview flow so users can inspect parsed birthday rows before the app writes them into SwiftData.

## Scope

In scope:

- Parse the selected CSV file without immediately inserting records
- Show an import preview screen listing valid records
- Show a summary of how many rows will be imported and how many will be skipped
- Show lightweight skipped-row details with row number and reason
- Commit imported records only after explicit user confirmation

Out of scope:

- Per-row selection toggles
- Editing imported rows during preview
- Automatic deduplication or merge
- Conflict blocking against existing stored birthdays

## User Flow

1. User opens `Settings` and taps `Import CSV`.
2. The file picker returns a single CSV file.
3. The app reads and parses the file into a preview result.
4. The app presents an `Import Preview` screen instead of importing immediately.
5. The preview shows:
   - importable record count
   - skipped row count
   - importable rows
   - skipped row details
6. If the user taps `Cancel`, the preview is dismissed and no data changes are made.
7. If the user taps `Import`, the app inserts the previewed rows, saves the model context, reschedules reminders, dismisses the preview, and shows the existing completion alert.

## Data Design

`BirthdayCSVService` should keep parsing responsibilities and return richer preview data.

Recommended additions:

- `BirthdayCSVSkippedRow`
  - `rowNumber`
  - `reason`
- `BirthdayCSVImportResult`
  - `records`
  - `skippedRows`
  - computed `skippedRowCount`

Reasons should stay simple and user-facing, for example:

- `Missing name`
- `Missing birthday`
- `Unsupported birthday format`

This preserves the current no-deduplication product rule while making skipped rows understandable in the preview.

## UI Design

Create a focused `CSVImportPreviewView` with:

- navigation title `Import Preview`
- summary section
- list of valid rows
- optional skipped-row section
- toolbar or bottom actions for `Cancel` and `Import`

Each valid row should show enough information to confirm correctness:

- name
- formatted birthday
- remark if present

Skipped rows do not need a complex layout. A compact row like `Row 4: Missing birthday` is enough for v1.

## Implementation Boundaries

Modify:

- `Birthdays/Birthdays/Services/BirthdayCSVService.swift`
- `Birthdays/Birthdays/Features/Settings/SettingsView.swift`
- `Birthdays/BirthdaysTests/BirthdayCSVServiceTests.swift`

Create:

- `Birthdays/Birthdays/Features/Settings/CSVImportPreviewView.swift`

`SettingsView` should remain responsible for file picking, navigation state, persistence, and reminder rescheduling.
`BirthdayCSVService` should remain responsible for parsing only.
`CSVImportPreviewView` should remain a pure presentation layer over preview state and user actions.

## Testing Strategy

Required:

- unit tests for skipped-row detail reporting
- unit tests for row-number attribution
- unit tests for preview parsing that preserves valid rows while collecting skipped rows

Optional for the first pass:

- UI coverage for the preview screen

## Notes

This design intentionally optimizes for a small, reviewable change. It improves import safety without turning CSV import into a full workflow engine.
