//
//  AppLaunchOptions.swift
//  Birthdays
//
//  Created by Codex on 3/11/26.
//

import Foundation
import SwiftData

enum AppLaunchOptions {
    private static let arguments = ProcessInfo.processInfo.arguments
    private static let environment = ProcessInfo.processInfo.environment

    static var isRunningPreviews: Bool {
        environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }

    static var isUITesting: Bool {
        arguments.contains("UITEST")
    }

    static var shouldSeedBirthday: Bool {
        arguments.contains("UITEST_SEED_BIRTHDAY")
    }

    static func configure(container: ModelContainer) throws {
        guard isUITesting else { return }

        if shouldSeedBirthday {
            let context = container.mainContext
            context.insert(BirthdayRecord(
                name: "Alex Johnson",
                month: 3,
                day: 14,
                birthYear: 1992
            ))
            try context.save()
        }
    }
}
