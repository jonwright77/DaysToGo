//
//  ReminderTile.swift
//  DaysToGo
//
//  Created by Jon Wright on 23/07/2025.
//


import SwiftUI

struct ReminderTile: View {
    let reminder: Reminder

    var borderColor: Color {
        switch reminder.daysRemaining {
        case ..<0:
            return .red
        case 0:
            return .yellow
        case 1...7:
            return .green
        default:
            return .clear
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            Text(reminder.title)
                .font(.headline)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            Text(reminder.date, style: .date)
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text("\(reminder.daysRemaining) day\(reminder.daysRemaining == 1 ? "" : "s") left")
                .font(.title2)
                .bold()
                .foregroundColor(reminder.daysRemaining < 0 ? .red : .primary)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 120)
        .background(Color(.systemGray6))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(borderColor, lineWidth: borderColor == .clear ? 0 : 3)
        )
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

