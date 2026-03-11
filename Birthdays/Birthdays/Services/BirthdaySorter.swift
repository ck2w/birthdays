//
//  BirthdaySorter.swift
//  Birthdays
//
//  Created by Codex on 3/11/26.
//

import Foundation

enum BirthdaySortOption: String, CaseIterable, Identifiable {
    case date
    case firstName
    case lastName

    var id: Self { self }
}

struct BirthdaySorter {
    let calculator: BirthdayCalculator

    init(calculator: BirthdayCalculator = BirthdayCalculator()) {
        self.calculator = calculator
    }

    func sort(
        _ records: [BirthdayRecord],
        by option: BirthdaySortOption,
        today: Date,
        fallback: Feb29Fallback
    ) -> [BirthdayRecord] {
        switch option {
        case .date:
            return records.sorted { lhs, rhs in
                let lhsDate = calculator.nextBirthdayDate(for: lhs, today: today, fallback: fallback) ?? .distantFuture
                let rhsDate = calculator.nextBirthdayDate(for: rhs, today: today, fallback: fallback) ?? .distantFuture

                if lhsDate == rhsDate {
                    return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
                }

                return lhsDate < rhsDate
            }
        case .firstName:
            return records.sorted {
                $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
            }
        case .lastName:
            return records.sorted { lhs, rhs in
                let lhsLastName = normalizedLastName(from: lhs.name)
                let rhsLastName = normalizedLastName(from: rhs.name)

                let comparison = lhsLastName.localizedCaseInsensitiveCompare(rhsLastName)
                if comparison == .orderedSame {
                    return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
                }

                return comparison == .orderedAscending
            }
        }
    }

    private func normalizedLastName(from fullName: String) -> String {
        fullName
            .split(whereSeparator: \.isWhitespace)
            .last
            .map(String.init) ?? fullName
    }
}
