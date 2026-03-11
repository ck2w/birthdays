//
//  BirthdayListViewModel.swift
//  Birthdays
//
//  Created by Codex on 3/11/26.
//

import Foundation

struct BirthdayListRowModel: Identifiable, Equatable {
    let id: UUID
    let name: String
    let subtitle: String
    let daysRemaining: Int

    var daysText: String {
        "\(daysRemaining)\n\(daysRemaining == 1 ? "day" : "days")"
    }
}

struct BirthdayListSection: Identifiable, Equatable {
    let id: String
    let title: String
    let rows: [BirthdayListRowModel]
}

struct BirthdayListViewModel {
    private let calculator: BirthdayCalculator
    private let sorter: BirthdaySorter

    init(
        calculator: BirthdayCalculator = BirthdayCalculator(),
        sorter: BirthdaySorter? = nil
    ) {
        self.calculator = calculator
        self.sorter = sorter ?? BirthdaySorter(calculator: calculator)
    }

    func makeSections(
        records: [BirthdayRecord],
        sortOption: BirthdaySortOption,
        today: Date,
        fallback: Feb29Fallback
    ) -> [BirthdayListSection] {
        let sortedRecords = sorter.sort(records, by: sortOption, today: today, fallback: fallback)
        let formatter = monthFormatter

        let grouped = Dictionary(grouping: sortedRecords) { record in
            guard let nextBirthday = calculator.nextBirthdayDate(for: record, today: today, fallback: fallback) else {
                return "Unknown"
            }

            return formatter.string(from: nextBirthday)
        }

        let orderedTitles = sortedRecords.reduce(into: [String]()) { titles, record in
            guard let nextBirthday = calculator.nextBirthdayDate(for: record, today: today, fallback: fallback) else {
                return
            }

            let title = formatter.string(from: nextBirthday)
            if titles.last != title {
                titles.append(title)
            }
        }

        return orderedTitles.map { title in
            BirthdayListSection(
                id: title,
                title: title,
                rows: (grouped[title] ?? []).compactMap { makeRow(for: $0, today: today, fallback: fallback) }
            )
        }
    }

    private func makeRow(for record: BirthdayRecord, today: Date, fallback: Feb29Fallback) -> BirthdayListRowModel? {
        guard let nextBirthday = calculator.nextBirthdayDate(for: record, today: today, fallback: fallback),
              let daysRemaining = calculator.daysUntilBirthday(for: record, today: today, fallback: fallback)
        else {
            return nil
        }

        let subtitle: String
        if let age = calculator.upcomingAge(for: record, today: today, fallback: fallback) {
            subtitle = "Turns \(age) on \(dateFormatter.string(from: nextBirthday))"
        } else {
            subtitle = "Birthday on \(dateFormatter.string(from: nextBirthday))"
        }

        return BirthdayListRowModel(
            id: record.id,
            name: record.name,
            subtitle: subtitle,
            daysRemaining: daysRemaining
        )
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d"
        return formatter
    }

    private var monthFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter
    }
}
