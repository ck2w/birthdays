//
//  BirthdayEditorView.swift
//  Birthdays
//
//  Created by Codex on 3/11/26.
//

import SwiftData
import SwiftUI

struct BirthdayEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: BirthdayEditorViewModel

    init(record: BirthdayRecord? = nil) {
        _viewModel = StateObject(wrappedValue: BirthdayEditorViewModel(record: record))
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Person") {
                    TextField("Name", text: $viewModel.name)
                        .textInputAutocapitalization(.words)
                        .accessibilityIdentifier("birthday_name_field")
                }

                Section("Birthday") {
                    Picker("Month", selection: $viewModel.month) {
                        ForEach(1...12, id: \.self) { month in
                            Text(monthName(for: month)).tag(month)
                        }
                    }

                    Picker("Day", selection: $viewModel.day) {
                        ForEach(1...31, id: \.self) { day in
                            Text("\(day)").tag(day)
                        }
                    }

                    TextField("Birth Year (Optional)", text: $viewModel.birthYearText)
                        .keyboardType(.numberPad)
                        .accessibilityIdentifier("birthday_year_field")
                }

                Section("Reminders") {
                    Toggle("Disable reminders for this person", isOn: $viewModel.remindersDisabled)
                }

                if let validationMessage = viewModel.validationMessage {
                    Section {
                        Text(validationMessage)
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle(viewModel.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .disabled(!viewModel.isValid)
                    .accessibilityIdentifier("birthday_save_button")
                }
            }
        }
    }

    private func save() {
        do {
            try viewModel.save { draft in
                if let existingRecord = viewModel.existingRecord {
                    viewModel.update(record: existingRecord, with: draft)
                } else {
                    modelContext.insert(viewModel.makeNewRecord(from: draft))
                }
                try modelContext.save()
            }
            dismiss()
        } catch {
            // Validation message is already set in the view model.
        }
    }

    private func monthName(for month: Int) -> String {
        let formatter = DateFormatter()
        return formatter.monthSymbols[month - 1]
    }
}

#Preview {
    BirthdayEditorView()
        .modelContainer(for: [BirthdayRecord.self, AppSettings.self], inMemory: true)
}
