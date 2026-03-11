//
//  BirthdayRecord.swift
//  Birthdays
//
//  Created by Codex on 3/11/26.
//

import Foundation
import SwiftData

@Model
final class BirthdayRecord {
    @Attribute(.unique) var id: UUID
    var name: String
    var month: Int
    var day: Int
    var birthYear: Int?
    var remindersDisabled: Bool
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        month: Int,
        day: Int,
        birthYear: Int? = nil,
        remindersDisabled: Bool = false,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.month = month
        self.day = day
        self.birthYear = birthYear
        self.remindersDisabled = remindersDisabled
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
