//
//  AppSettings.swift
//  Birthdays
//
//  Created by Codex on 3/11/26.
//

import Foundation
import SwiftData

@Model
final class AppSettings {
    var id: UUID = UUID()
    var remindersEnabled: Bool = false
    var reminderOffset: ReminderOffset = ReminderOffset.oneDayBefore
    var notificationHour: Int = 8
    var notificationMinute: Int = 0
    var feb29Fallback: Feb29Fallback = Feb29Fallback.feb28

    init(
        id: UUID = UUID(),
        remindersEnabled: Bool = false,
        reminderOffset: ReminderOffset = .oneDayBefore,
        notificationHour: Int = 8,
        notificationMinute: Int = 0,
        feb29Fallback: Feb29Fallback = .feb28
    ) {
        self.id = id
        self.remindersEnabled = remindersEnabled
        self.reminderOffset = reminderOffset
        self.notificationHour = notificationHour
        self.notificationMinute = notificationMinute
        self.feb29Fallback = feb29Fallback
    }
}
