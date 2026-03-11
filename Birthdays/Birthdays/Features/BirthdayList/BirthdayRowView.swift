//
//  BirthdayRowView.swift
//  Birthdays
//
//  Created by Codex on 3/11/26.
//

import SwiftUI

struct BirthdayRowView: View {
    let row: BirthdayListRowModel

    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.blue.opacity(0.9))
                .frame(width: 52, height: 52)
                .overlay(
                    Image(systemName: "birthday.cake.fill")
                        .font(.system(size: 22))
                        .foregroundStyle(.white)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(row.name)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(row.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            Spacer(minLength: 16)

            Text(row.daysText)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundStyle(.blue)
                .multilineTextAlignment(.center)
                .frame(width: 48)
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

#Preview {
    BirthdayRowView(
        row: BirthdayListRowModel(
            id: UUID(),
            name: "Alex",
            subtitle: "Turns 34 on March 14",
            daysRemaining: 4
        )
    )
    .padding()
}
