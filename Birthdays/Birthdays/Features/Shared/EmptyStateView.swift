//
//  EmptyStateView.swift
//  Birthdays
//
//  Created by Codex on 3/11/26.
//

import SwiftUI

struct EmptyStateView: View {
    let title: String
    let message: String
    let buttonTitle: String
    let action: () -> Void

    var body: some View {
        VStack(spacing: 18) {
            Image(systemName: "birthday.cake")
                .font(.system(size: 48))
                .foregroundStyle(.blue)

            Text(title)
                .font(.title3.bold())

            Text(message)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button(buttonTitle, action: action)
                .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(24)
    }
}

#Preview {
    EmptyStateView(
        title: "No birthdays yet",
        message: "Start by adding the first birthday you want to track.",
        buttonTitle: "Add Birthday",
        action: {}
    )
}
