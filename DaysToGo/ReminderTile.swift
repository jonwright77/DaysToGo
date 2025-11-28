//
//  ReminderTile.swift
//  DaysToGo
//
//  Created by Jon Wright on 23/07/2025.
//

import SwiftUI
import DaysToGoKit

// MARK: - Reminder Tile View

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
                .font(.title2)
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            Text(reminder.date, style: .date)
                .font(.headline)
                .foregroundColor(.black)

            Text("\(reminder.daysRemaining) day\(reminder.daysRemaining == 1 ? "" : "s") left")
                .font(.title2)
                .bold()
                .foregroundColor(.black)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 120)
        .background(colorFromString(reminder.backgroundColor) ?? Color(.systemGray6))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(borderColor, lineWidth: borderColor == .clear ? 0 : 6)
        )
        .cornerRadius(12)
        .shadow(radius: 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(reminder.title), \(reminder.date.formatted(date: .long, time: .omitted)), \(reminder.daysRemaining) days left")
    }
}