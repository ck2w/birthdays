//
//  SettingsViewModel.swift
//  Birthdays
//
//  Created by Codex on 3/11/26.
//

import Combine
import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    @Published var remindersEnabled: Bool = false
    @Published var reminderOffset: ReminderOffset = .oneDayBefore
    @Published var notificationTime: Date = .now
    @Published var feb29Fallback: Feb29Fallback = .feb28
    @Published var permissionStatus: NotificationPermissionStatus = .notDetermined

    private let permissionClient: NotificationPermissionClient

    init(permissionClient: NotificationPermissionClient = .live) {
        self.permissionClient = permissionClient
    }

    func load(from settings: AppSettings) {
        remindersEnabled = settings.remindersEnabled
        reminderOffset = settings.reminderOffset

        var components = DateComponents()
        components.hour = settings.notificationHour
        components.minute = settings.notificationMinute
        notificationTime = Calendar.current.date(from: components) ?? .now

        feb29Fallback = settings.feb29Fallback
    }

    func loadPermissionStatus() async {
        permissionStatus = await permissionClient.getStatus()
    }

    func persist(using update: (AppSettings) throws -> Void) throws {
        try updateSettings(using: update)
    }

    func handleReminderToggle(using update: (AppSettings) throws -> Void) async throws {
        if remindersEnabled && permissionStatus == .notDetermined {
            let granted = await permissionClient.requestAccess()
            permissionStatus = await permissionClient.getStatus()
            if !granted && !permissionStatus.allowsNotifications {
                remindersEnabled = false
            }
        }

        try updateSettings(using: update)
    }

    private func updateSettings(using update: (AppSettings) throws -> Void) throws {
        let components = Calendar.current.dateComponents([.hour, .minute], from: notificationTime)
        let hour = components.hour ?? 8
        let minute = components.minute ?? 0
        try update(AppSettings(
            remindersEnabled: remindersEnabled,
            reminderOffset: reminderOffset,
            notificationHour: hour,
            notificationMinute: minute,
            feb29Fallback: feb29Fallback
        ))
    }
}

private extension SettingsViewModel {
    func update(_ freshSettings: AppSettings, using update: (AppSettings) throws -> Void) throws {
        try update(freshSettings)
    }
}
