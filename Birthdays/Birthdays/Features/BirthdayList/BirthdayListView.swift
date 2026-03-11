//
//  BirthdayListView.swift
//  Birthdays
//
//  Created by Codex on 3/11/26.
//

import SwiftData
import SwiftUI

struct BirthdayListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var birthdays: [BirthdayRecord]
    @Query private var appSettings: [AppSettings]
    @State private var sortOption: BirthdaySortOption = .date
    @State private var activeSheet: BirthdaySheet?
    @State private var showingSettings = false

    private let viewModel = BirthdayListViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if sections.isEmpty {
                    EmptyStateView(
                        title: "No birthdays yet",
                        message: "Add the first birthday you want to track. Upcoming birthdays will appear here.",
                        buttonTitle: "Add Birthday",
                        action: { activeSheet = .create }
                    )
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 18) {
                            ForEach(sections) { section in
                                VStack(alignment: .leading, spacing: 10) {
                                    Text(section.title)
                                        .font(.title3.weight(.semibold))
                                        .foregroundStyle(.secondary)

                                    ForEach(section.rows) { row in
                                        Button {
                                            if let record = birthdays.first(where: { $0.id == row.id }) {
                                                activeSheet = .edit(record)
                                            }
                                        } label: {
                                            BirthdayRowView(row: row)
                                        }
                                        .buttonStyle(.plain)
                                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                            Button("Delete", role: .destructive) {
                                                Task {
                                                    await deleteBirthday(withID: row.id)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 18)
                    }
                    .background(Color(.systemGroupedBackground))
                }
            }
            .navigationTitle("Birthdays")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "line.3.horizontal")
                    }
                    .accessibilityLabel("Menu")
                }

                ToolbarItemGroup(placement: .topBarTrailing) {
                    SortMenuView(selection: $sortOption)

                    Button(action: { activeSheet = .create }) {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add birthday")
                }
            }
        }
        .sheet(item: $activeSheet) { sheet in
            switch sheet {
            case .create:
                BirthdayEditorView()
            case .edit(let record):
                BirthdayEditorView(record: record)
            }
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
        .task {
            do {
                let settings = try AppSettingsStore(modelContext: modelContext).fetchOrCreate()
                try await ReminderScheduler().syncAll(records: birthdays, settings: settings)
            } catch {
                assertionFailure("Failed to load app settings: \(error)")
            }
        }
    }

    private var sections: [BirthdayListSection] {
        viewModel.makeSections(
            records: birthdays,
            sortOption: sortOption,
            today: .now,
            fallback: currentFallback
        )
    }

    private var currentFallback: Feb29Fallback {
        appSettings.first?.feb29Fallback ?? .feb28
    }

    private func deleteBirthday(withID id: UUID) async {
        guard let record = birthdays.first(where: { $0.id == id }) else {
            return
        }

        do {
            modelContext.delete(record)
            try modelContext.save()

            let settings = try AppSettingsStore(modelContext: modelContext).fetchOrCreate()
            let records = try modelContext.fetch(FetchDescriptor<BirthdayRecord>())
            try await ReminderScheduler().syncAll(records: records, settings: settings)
        } catch {
            assertionFailure("Failed to delete birthday: \(error)")
        }
    }
}

enum BirthdaySheet: Identifiable {
    case create
    case edit(BirthdayRecord)

    var id: String {
        switch self {
        case .create:
            return "create"
        case .edit(let record):
            return "edit-\(record.id.uuidString)"
        }
    }
}

#Preview {
    BirthdayListView()
        .modelContainer(for: [BirthdayRecord.self, AppSettings.self], inMemory: true)
}
