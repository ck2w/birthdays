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
    var id: UUID = UUID()
    var name: String = ""
    var month: Int = 1
    var day: Int = 1
    var birthYear: Int?
    var remark: String = ""
    var remindersDisabled: Bool = false
    var createdAt: Date = Date.now
    var updatedAt: Date = Date.now

    init(
        id: UUID = UUID(),
        name: String,
        month: Int,
        day: Int,
        birthYear: Int? = nil,
        remark: String = "",
        remindersDisabled: Bool = false,
        createdAt: Date = .now,
        updatedAt: Date = .now
    ) {
        self.id = id
        self.name = name
        self.month = month
        self.day = day
        self.birthYear = birthYear
        self.remark = remark
        self.remindersDisabled = remindersDisabled
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
