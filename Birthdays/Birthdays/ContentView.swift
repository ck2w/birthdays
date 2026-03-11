//
//  ContentView.swift
//  Birthdays
//
//  Created by Ken Chen on 3/11/26.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                Text("Birthdays")
                    .font(.largeTitle.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text("The birthday list will live here next.")
                    .font(.headline)

                Text("Next up: models, sorting, reminders, and the list UI.")
                    .foregroundStyle(.secondary)

                Spacer()
            }
            .padding(24)
            .navigationTitle("Birthdays")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    ContentView()
}
