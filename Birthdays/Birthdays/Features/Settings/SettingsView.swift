//
//  SettingsView.swift
//  Birthdays
//
//  Created by Codex on 3/11/26.
//

import SwiftData
import SwiftUI
import UniformTypeIdentifiers

private struct ExportFile: Identifiable {
    let id = UUID()
    let url: URL
}

private struct SettingsAlertState: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var appSettings: [AppSettings]
    @Query private var birthdays: [BirthdayRecord]
    @StateObject private var viewModel = SettingsViewModel()
    @State private var showingCSVImporter = false
    @State private var exportFile: ExportFile?
    @State private var importPreviewState: CSVImportPreviewState?
    @State private var alertState: SettingsAlertState?

    var body: some View {
        NavigationStack {
            Form {
                Section("Reminders") {
                    Toggle("Enabled", isOn: Binding(
                        get: { viewModel.remindersEnabled },
                        set: { newValue in
                            viewModel.remindersEnabled = newValue
                            Task {
                                do {
                                    try await viewModel.handleReminderToggle(using: updateSettings)
                                    try await rescheduleReminders()
                                } catch {
                                    assertionFailure("Failed to update reminder settings: \(error)")
                                }
                            }
                        }
                    ))
                    .accessibilityIdentifier("settings_reminders_toggle")

                    Picker("Send Reminder", selection: $viewModel.reminderOffset) {
                        Text("On the day").tag(ReminderOffset.sameDay)
                        Text("1 day before").tag(ReminderOffset.oneDayBefore)
                        Text("2 days before").tag(ReminderOffset.twoDaysBefore)
                        Text("7 days before").tag(ReminderOffset.sevenDaysBefore)
                    }
                    .accessibilityIdentifier("settings_reminder_offset_picker")

                    DatePicker(
                        "Notification Time",
                        selection: $viewModel.notificationTime,
                        displayedComponents: .hourAndMinute
                    )
                    .accessibilityIdentifier("settings_notification_time_picker")
                }

                if viewModel.permissionStatus == .denied {
                    Section {
                        Text("Notifications are denied in iOS Settings. Open Settings on your device if you want birthday reminders.")
                            .font(.footnote)
                            .foregroundStyle(.red)
                    }
                }

                Section("If February 29 doesn't exist") {
                    Picker("Send Reminder On", selection: $viewModel.feb29Fallback) {
                        Text("February 28").tag(Feb29Fallback.feb28)
                    }
                    .accessibilityIdentifier("settings_feb29_picker")
                }

                Section("Data") {
                    Button("Import CSV") {
                        showingCSVImporter = true
                    }
                    .accessibilityIdentifier("settings_import_csv_button")

                    Button("Export CSV") {
                        exportCSV()
                    }
                    .accessibilityIdentifier("settings_export_csv_button")
                }

                Section("Debug") {
                    Button("Send Test Notification") {
                        Task {
                            await viewModel.sendTestNotification()
                        }
                    }
                    .accessibilityIdentifier("settings_test_notification_button")
                }

                if let statusMessage = viewModel.statusMessage {
                    Section {
                        Text(statusMessage)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .accessibilityIdentifier("settings_done_button")
                }
            }
        }
        .task {
            do {
                let settings = try AppSettingsStore(modelContext: modelContext).fetchOrCreate()
                viewModel.load(from: settings)
                await viewModel.loadPermissionStatus()
            } catch {
                assertionFailure("Failed to load settings: \(error)")
            }
        }
        .onChange(of: viewModel.reminderOffset) { _, _ in
            persistSettingsAndReschedule()
        }
        .onChange(of: viewModel.notificationTime) { _, _ in
            persistSettingsAndReschedule()
        }
        .onChange(of: viewModel.feb29Fallback) { _, _ in
            persistSettingsAndReschedule()
        }
        .fileImporter(
            isPresented: $showingCSVImporter,
            allowedContentTypes: [.commaSeparatedText, .plainText],
            allowsMultipleSelection: false
        ) { result in
            handleImportResult(result)
        }
        .sheet(item: $exportFile) { item in
            ActivityView(activityItems: [item.url])
        }
        .sheet(item: $importPreviewState) { state in
            CSVImportPreviewView(
                state: state,
                onCancel: {
                    importPreviewState = nil
                },
                onImport: {
                    confirmImport(with: state)
                }
            )
        }
        .alert(item: $alertState) { state in
            Alert(
                title: Text(state.title),
                message: Text(state.message),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private func updateSettings(_ incoming: AppSettings) throws {
        let store = AppSettingsStore(modelContext: modelContext)
        try store.update { settings in
            settings.remindersEnabled = incoming.remindersEnabled
            settings.reminderOffset = incoming.reminderOffset
            settings.notificationHour = incoming.notificationHour
            settings.notificationMinute = incoming.notificationMinute
            settings.feb29Fallback = incoming.feb29Fallback
        }
    }

    private func persistSettingsAndReschedule() {
        Task {
            do {
                try viewModel.persist(using: updateSettings)
                try await rescheduleReminders()
            } catch {
                assertionFailure("Failed to persist reminder settings: \(error)")
            }
        }
    }

    private func rescheduleReminders() async throws {
        let settings: AppSettings
        if let existingSettings = appSettings.first {
            settings = existingSettings
        } else {
            settings = try AppSettingsStore(modelContext: modelContext).fetchOrCreate()
        }
        let records = try modelContext.fetch(FetchDescriptor<BirthdayRecord>())
        try await ReminderScheduler().syncAll(records: records, settings: settings)
    }

    private func handleImportResult(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            loadImportPreview(from: url)
        case .failure(let error):
            alertState = SettingsAlertState(
                title: "Import Failed",
                message: error.localizedDescription
            )
        }
    }

    private func loadImportPreview(from url: URL) {
        Task { @MainActor in
            let didAccess = url.startAccessingSecurityScopedResource()
            defer {
                if didAccess {
                    url.stopAccessingSecurityScopedResource()
                }
            }

            do {
                let data = try Data(contentsOf: url)
                guard let text = String(data: data, encoding: .utf8) else {
                    throw CocoaError(.fileReadInapplicableStringEncoding)
                }

                let service = BirthdayCSVService()
                let result = try service.import(from: text)
                importPreviewState = CSVImportPreviewState(result: result)
            } catch {
                alertState = SettingsAlertState(
                    title: "Import Failed",
                    message: error.localizedDescription
                )
            }
        }
    }

    private func confirmImport(with state: CSVImportPreviewState) {
        Task { @MainActor in
            do {
                for record in state.result.records {
                    modelContext.insert(
                        BirthdayRecord(
                            name: record.name,
                            month: record.month,
                            day: record.day,
                            birthYear: record.birthYear,
                            remark: record.remark
                        )
                    )
                }

                try modelContext.save()
                try await rescheduleReminders()

                importPreviewState = nil
                alertState = SettingsAlertState(
                    title: "Import Complete",
                    message: importMessage(for: state.result)
                )
            } catch {
                alertState = SettingsAlertState(
                    title: "Import Failed",
                    message: error.localizedDescription
                )
            }
        }
    }

    private func exportCSV() {
        do {
            let service = BirthdayCSVService()
            let csv = service.export(records: birthdays)
            let url = try makeExportFile(contents: csv)
            exportFile = ExportFile(url: url)
        } catch {
            alertState = SettingsAlertState(
                title: "Export Failed",
                message: error.localizedDescription
            )
        }
    }

    private func makeExportFile(contents: String) throws -> URL {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let fileName = "Birthdays-\(formatter.string(from: .now)).csv"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        try contents.write(to: url, atomically: true, encoding: .utf8)
        return url
    }

    private func importMessage(for result: BirthdayCSVImportResult) -> String {
        if result.skippedRowCount == 0 {
            return "Imported \(result.records.count) birthday entries."
        }

        return "Imported \(result.records.count) birthday entries and skipped \(result.skippedRowCount) invalid rows."
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: [BirthdayRecord.self, AppSettings.self], inMemory: true)
}
