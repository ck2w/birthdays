//
//  AppSettingsStore.swift
//  Birthdays
//
//  Created by Codex on 3/11/26.
//

import Foundation
import SwiftData

@MainActor
final class AppSettingsStore {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchOrCreate() throws -> AppSettings {
        var descriptor = FetchDescriptor<AppSettings>()
        descriptor.fetchLimit = 1

        if let existing = try modelContext.fetch(descriptor).first {
            return existing
        }

        let settings = AppSettings()
        modelContext.insert(settings)
        try modelContext.save()
        return settings
    }

    @discardableResult
    func update(_ mutate: (AppSettings) -> Void) throws -> AppSettings {
        let settings = try fetchOrCreate()
        mutate(settings)
        try modelContext.save()
        return settings
    }
}
