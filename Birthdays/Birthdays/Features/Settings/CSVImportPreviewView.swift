//
//  CSVImportPreviewView.swift
//  Birthdays
//
//  Created by Codex on 3/12/26.
//

import SwiftUI

struct CSVImportPreviewState: Identifiable, Equatable {
    let id = UUID()
    let result: BirthdayCSVImportResult

    var summaryMessage: String {
        let importedCount = result.records.count
        let skippedCount = result.skippedRowCount
        let recordLabel = importedCount == 1 ? "record" : "records"

        if skippedCount == 0 {
            return "\(importedCount) \(recordLabel) ready to import."
        }

        let skippedLabel = skippedCount == 1 ? "row will" : "rows will"
        return "\(importedCount) \(recordLabel) ready to import, \(skippedCount) \(skippedLabel) be skipped."
    }

    var hasSkippedRows: Bool {
        !result.skippedRows.isEmpty
    }
}

struct CSVImportPreviewView: View {
    let state: CSVImportPreviewState
    let onCancel: () -> Void
    let onImport: () -> Void

    var body: some View {
        NavigationStack {
            List {
                Section("Summary") {
                    Text(state.summaryMessage)
                        .accessibilityIdentifier("csv_import_preview_summary")
                }

                Section("Ready to Import") {
                    ForEach(Array(state.result.records.enumerated()), id: \.offset) { _, record in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(record.name)
                                .font(.headline)
                            Text(formattedBirthday(for: record))
                                .font(.subheadline)
                                .foregroundStyle(.secondary)

                            if !record.remark.isEmpty {
                                Text(record.remark)
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .padding(.vertical, 2)
                    }
                }

                if state.hasSkippedRows {
                    Section("Skipped Rows") {
                        ForEach(Array(state.result.skippedRows.enumerated()), id: \.offset) { _, skippedRow in
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Row \(skippedRow.rowNumber)")
                                    .font(.headline)
                                Text(skippedRow.reason)
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.vertical, 2)
                        }
                    }
                }
            }
            .navigationTitle("Import Preview")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: onCancel)
                        .accessibilityIdentifier("csv_import_preview_cancel_button")
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Import", action: onImport)
                        .disabled(state.result.records.isEmpty)
                        .accessibilityIdentifier("csv_import_preview_import_button")
                }
            }
        }
    }

    private func formattedBirthday(for record: BirthdayCSVRecord) -> String {
        let month = String(format: "%02d", record.month)
        let day = String(format: "%02d", record.day)

        if let birthYear = record.birthYear {
            return "\(birthYear)-\(month)-\(day)"
        }

        return "--\(month)-\(day)"
    }
}
