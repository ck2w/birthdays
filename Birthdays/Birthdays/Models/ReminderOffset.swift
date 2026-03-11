//
//  ReminderOffset.swift
//  Birthdays
//
//  Created by Codex on 3/11/26.
//

import Foundation

enum ReminderOffset: String, Codable, CaseIterable, Identifiable {
    case sameDay
    case oneDayBefore
    case twoDaysBefore
    case sevenDaysBefore

    var id: Self { self }

    var daysInAdvance: Int {
        switch self {
        case .sameDay:
            return 0
        case .oneDayBefore:
            return 1
        case .twoDaysBefore:
            return 2
        case .sevenDaysBefore:
            return 7
        }
    }
}
