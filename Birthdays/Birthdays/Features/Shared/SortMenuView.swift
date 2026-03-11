//
//  SortMenuView.swift
//  Birthdays
//
//  Created by Codex on 3/11/26.
//

import SwiftUI

struct SortMenuView: View {
    @Binding var selection: BirthdaySortOption

    var body: some View {
        Menu {
            Picker("Sort by", selection: $selection) {
                Text("Sort by Date").tag(BirthdaySortOption.date)
                Text("Sort by First Name").tag(BirthdaySortOption.firstName)
                Text("Sort by Last Name").tag(BirthdaySortOption.lastName)
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down.circle")
        }
        .accessibilityLabel("Sort birthdays")
    }
}
