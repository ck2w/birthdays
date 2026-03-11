//
//  NotificationPermissionClient.swift
//  Birthdays
//
//  Created by Codex on 3/11/26.
//

import Foundation
import UserNotifications

enum NotificationPermissionStatus: String {
    case notDetermined
    case denied
    case authorized
    case provisional
    case ephemeral

    var allowsNotifications: Bool {
        switch self {
        case .authorized, .provisional, .ephemeral:
            return true
        case .notDetermined, .denied:
            return false
        }
    }
}

struct NotificationPermissionClient {
    var getStatus: () async -> NotificationPermissionStatus
    var requestAccess: () async -> Bool

    static let live = NotificationPermissionClient(
        getStatus: {
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            switch settings.authorizationStatus {
            case .notDetermined:
                return .notDetermined
            case .denied:
                return .denied
            case .authorized:
                return .authorized
            case .provisional:
                return .provisional
            case .ephemeral:
                return .ephemeral
            @unknown default:
                return .notDetermined
            }
        },
        requestAccess: {
            do {
                return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
            } catch {
                return false
            }
        }
    )
}
