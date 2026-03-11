//
//  BirthdaysApp.swift
//  Birthdays
//
//  Created by Ken Chen on 3/11/26.
//

import SwiftData
import SwiftUI

@main
struct BirthdaysApp: App {
    private var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            BirthdayRecord.self,
            AppSettings.self,
        ])

        do {
            let configuration: ModelConfiguration
            if AppLaunchOptions.isRunningPreviews || AppLaunchOptions.isUITesting {
                configuration = ModelConfiguration(
                    schema: schema,
                    isStoredInMemoryOnly: true,
                    cloudKitDatabase: .none
                )
            } else {
                configuration = ModelConfiguration(
                    schema: schema,
                    isStoredInMemoryOnly: false,
                    cloudKitDatabase: .none
                )
            }

            let container = try ModelContainer(for: schema, configurations: [configuration])
            try AppLaunchOptions.configure(container: container)
            return container
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
