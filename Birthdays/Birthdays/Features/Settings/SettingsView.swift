//
//  SettingsView.swift
//  Birthdays
//
//  Created by Codex on 3/11/26.
//

import SwiftData
import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var appSettings: [AppSettings]
    @StateObject private var viewModel = SettingsViewModel()

    var body: some View {
        NavigationStack {
            Form {
                Section("Reminders") {
                    Toggle("Enabled", isOn: Binding(
                        get: { viewModel.remindersEnabled },
                        set: { newValue in
                            viewModel.remindersEnabled = newValue
                            Task {
                                try? await viewModel.handleReminderToggle(using: updateSettings)
                            }
                        }
                    ))

                    Picker("Send Reminder", selection: $viewModel.reminderOffset) {
                        Text("On the day").tag(ReminderOffset.sameDay)
                        Text("1 day before").tag(ReminderOffset.oneDayBefore)
                        Text("2 days before").tag(ReminderOffset.twoDaysBefore)
                        Text("7 days before").tag(ReminderOffset.sevenDaysBefore)
                    }

                    DatePicker(
                        "Notification Time",
                        selection: $viewModel.notificationTime,
                        displayedComponents: .hourAndMinute
                    )
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
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
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
            try? viewModel.persist(using: updateSettings)
        }
        .onChange(of: viewModel.notificationTime) { _, _ in
            try? viewModel.persist(using: updateSettings)
        }
        .onChange(of: viewModel.feb29Fallback) { _, _ in
            try? viewModel.persist(using: updateSettings)
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
}

#Preview {
    SettingsView()
        .modelContainer(for: [BirthdayRecord.self, AppSettings.self], inMemory: true)
}
