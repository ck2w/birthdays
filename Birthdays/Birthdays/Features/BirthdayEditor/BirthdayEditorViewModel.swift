//
//  BirthdayEditorViewModel.swift
//  Birthdays
//
//  Created by Codex on 3/11/26.
//

import Combine
import Foundation

@MainActor
final class BirthdayEditorViewModel: ObservableObject {
    @Published var name: String
    @Published var month: Int
    @Published var day: Int
    @Published var birthYearText: String
    @Published var remindersDisabled: Bool
    @Published var validationMessage: String?

    let title: String
    let existingRecord: BirthdayRecord?
    private let calendar: Calendar

    init(record: BirthdayRecord? = nil, calendar: Calendar = .current) {
        self.existingRecord = record
        self.calendar = calendar
        self.title = record == nil ? "Add Birthday" : "Edit Birthday"
        self.name = record?.name ?? ""
        self.month = record?.month ?? 1
        self.day = record?.day ?? 1
        self.birthYearText = record?.birthYear.map(String.init) ?? ""
        self.remindersDisabled = record?.remindersDisabled ?? false
    }

    var isValid: Bool {
        validationMessage(forName: name, month: month, day: day, birthYearText: birthYearText) == nil
    }

    func save(using persist: (BirthdayDraft) throws -> Void) throws {
        guard let message = validationMessage(forName: name, month: month, day: day, birthYearText: birthYearText) else {
            let draft = BirthdayDraft(
                name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                month: month,
                day: day,
                birthYear: Int(birthYearText),
                remindersDisabled: remindersDisabled
            )
            try persist(draft)
            validationMessage = nil
            return
        }

        validationMessage = message
        throw BirthdayEditorError.validationFailed(message)
    }

    func update(record: BirthdayRecord, with draft: BirthdayDraft, now: Date = .now) {
        record.name = draft.name
        record.month = draft.month
        record.day = draft.day
        record.birthYear = draft.birthYear
        record.remindersDisabled = draft.remindersDisabled
        record.updatedAt = now
    }

    func makeNewRecord(from draft: BirthdayDraft, now: Date = .now) -> BirthdayRecord {
        BirthdayRecord(
            name: draft.name,
            month: draft.month,
            day: draft.day,
            birthYear: draft.birthYear,
            remindersDisabled: draft.remindersDisabled,
            createdAt: now,
            updatedAt: now
        )
    }

    private func validationMessage(forName name: String, month: Int, day: Int, birthYearText: String) -> String? {
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "Name is required."
        }

        guard isValidMonthDay(month: month, day: day) else {
            return "Choose a valid month and day."
        }

        if !birthYearText.isEmpty, Int(birthYearText) == nil {
            return "Birth year must be a number."
        }

        return nil
    }

    private func isValidMonthDay(month: Int, day: Int) -> Bool {
        var components = DateComponents()
        components.calendar = calendar
        components.timeZone = calendar.timeZone
        components.year = 2024
        components.month = month
        components.day = day

        return calendar.date(from: components) != nil
    }
}

struct BirthdayDraft: Equatable {
    let name: String
    let month: Int
    let day: Int
    let birthYear: Int?
    let remindersDisabled: Bool
}

enum BirthdayEditorError: LocalizedError {
    case validationFailed(String)

    var errorDescription: String? {
        switch self {
        case .validationFailed(let message):
            return message
        }
    }
}
