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
    @Attribute(.unique) var id: UUID
    var remindersEnabled: Bool
    var reminderOffset: ReminderOffset
    var notificationHour: Int
    var notificationMinute: Int
    var feb29Fallback: Feb29Fallback

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
