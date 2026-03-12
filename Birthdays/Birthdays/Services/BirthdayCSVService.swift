//
//  BirthdayCSVService.swift
//  Birthdays
//
//  Created by Codex on 3/11/26.
//

import Foundation

struct BirthdayCSVRecord: Equatable {
    let name: String
    let month: Int
    let day: Int
    let birthYear: Int?
    let remark: String
}

struct BirthdayCSVImportResult: Equatable {
    let records: [BirthdayCSVRecord]
    let skippedRowCount: Int
}

enum BirthdayCSVError: LocalizedError {
    case emptyFile
    case missingRequiredColumns
    case unreadableBirthdayFormat(String)

    var errorDescription: String? {
        switch self {
        case .emptyFile:
            return "The CSV file is empty."
        case .missingRequiredColumns:
            return "The CSV file must include name and birthday columns."
        case .unreadableBirthdayFormat(let value):
            return "Unsupported birthday format: \(value)"
        }
    }
}

struct BirthdayCSVService {
    private let calendar: Calendar

    init(calendar: Calendar = .current) {
        self.calendar = calendar
    }

    func export(records: [BirthdayRecord]) -> String {
        let header = ["name", "birthday", "remarks"]
        let sortedRecords = records.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
        let lines = sortedRecords.map { record in
            [
                escape(record.name),
                escape(formattedBirthday(for: record)),
                escape(record.remark)
            ].joined(separator: ",")
        }

        return ([header.joined(separator: ",")] + lines).joined(separator: "\n")
    }

    func `import`(from text: String) throws -> BirthdayCSVImportResult {
        let rows = parseCSVRows(text)
            .map { $0.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) } }
            .filter { !$0.allSatisfy(\.isEmpty) }

        guard let header = rows.first else {
            throw BirthdayCSVError.emptyFile
        }

        let normalizedHeader = header.map { $0.lowercased() }
        guard
            let nameIndex = normalizedHeader.firstIndex(of: "name"),
            let birthdayIndex = normalizedHeader.firstIndex(of: "birthday")
        else {
            throw BirthdayCSVError.missingRequiredColumns
        }

        let remarkIndex = normalizedHeader.firstIndex(where: { $0 == "remark" || $0 == "remarks" })

        var importedRecords: [BirthdayCSVRecord] = []
        var skippedRowCount = 0

        for row in rows.dropFirst() {
            let name = field(at: nameIndex, in: row)
            let birthday = field(at: birthdayIndex, in: row)
            let remark = field(at: remarkIndex, in: row)

            guard !name.isEmpty, !birthday.isEmpty else {
                skippedRowCount += 1
                continue
            }

            do {
                let components = try parseBirthday(birthday)
                importedRecords.append(
                    BirthdayCSVRecord(
                        name: name,
                        month: components.month,
                        day: components.day,
                        birthYear: components.birthYear,
                        remark: remark
                    )
                )
            } catch {
                skippedRowCount += 1
            }
        }

        return BirthdayCSVImportResult(records: importedRecords, skippedRowCount: skippedRowCount)
    }

    private func formattedBirthday(for record: BirthdayRecord) -> String {
        let month = String(format: "%02d", record.month)
        let day = String(format: "%02d", record.day)

        if let birthYear = record.birthYear {
            return "\(birthYear)-\(month)-\(day)"
        }

        return "--\(month)-\(day)"
    }

    private func parseBirthday(_ value: String) throws -> (birthYear: Int?, month: Int, day: Int) {
        if value.hasPrefix("--") {
            let trimmed = String(value.dropFirst(2))
            let components = trimmed.split(separator: "-")
            guard components.count == 2,
                  let month = Int(components[0]),
                  let day = Int(components[1]),
                  isValidDate(year: 2024, month: month, day: day)
            else {
                throw BirthdayCSVError.unreadableBirthdayFormat(value)
            }

            return (nil, month, day)
        }

        let components = value.split(separator: "-")
        guard components.count == 3,
              let year = Int(components[0]),
              let month = Int(components[1]),
              let day = Int(components[2]),
              isValidDate(year: year, month: month, day: day)
        else {
            throw BirthdayCSVError.unreadableBirthdayFormat(value)
        }

        return (year, month, day)
    }

    private func isValidDate(year: Int, month: Int, day: Int) -> Bool {
        var components = DateComponents()
        components.calendar = calendar
        components.timeZone = calendar.timeZone
        components.year = year
        components.month = month
        components.day = day

        return calendar.date(from: components) != nil
    }

    private func field(at index: Int?, in row: [String]) -> String {
        guard let index, row.indices.contains(index) else {
            return ""
        }

        return row[index]
    }

    private func escape(_ value: String) -> String {
        if value.contains(",") || value.contains("\"") || value.contains("\n") {
            let escapedQuotes = value.replacingOccurrences(of: "\"", with: "\"\"")
            return "\"\(escapedQuotes)\""
        }

        return value
    }

    private func parseCSVRows(_ text: String) -> [[String]] {
        var rows: [[String]] = []
        var currentRow: [String] = []
        var currentField = ""
        var isInsideQuotes = false
        let characters = Array(text)
        var index = 0

        while index < characters.count {
            let character = characters[index]

            if isInsideQuotes {
                if character == "\"" {
                    let nextIndex = index + 1
                    if nextIndex < characters.count, characters[nextIndex] == "\"" {
                        currentField.append("\"")
                        index += 1
                    } else {
                        isInsideQuotes = false
                    }
                } else {
                    currentField.append(character)
                }
            } else {
                switch character {
                case "\"":
                    isInsideQuotes = true
                case ",":
                    currentRow.append(currentField)
                    currentField = ""
                case "\n":
                    currentRow.append(currentField)
                    rows.append(currentRow)
                    currentRow = []
                    currentField = ""
                case "\r":
                    break
                default:
                    currentField.append(character)
                }
            }

            index += 1
        }

        if !currentField.isEmpty || !currentRow.isEmpty {
            currentRow.append(currentField)
            rows.append(currentRow)
        }

        return rows
    }
}
