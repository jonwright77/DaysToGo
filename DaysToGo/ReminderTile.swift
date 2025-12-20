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
    var showUrgencyBorder: Bool = true

    var borderColor: Color {
        guard showUrgencyBorder else {
            return .clear
        }

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

    var daysText: String {
        if reminder.daysRemaining == 0 {
            return "Today"
        } else if reminder.daysRemaining < 0 {
            let daysAgo = abs(reminder.daysRemaining)
            return "\(daysAgo) day\(daysAgo == 1 ? "" : "s") ago"
        } else {
            return "\(reminder.daysRemaining) day\(reminder.daysRemaining == 1 ? "" : "s") left"
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            Text(reminder.title)
                .font(.title2)
                .foregroundColor(.black)
                .multilineTextAlignment(.center)
                .lineLimit(2)

            Text(reminder.date.formatted(.dateTime.weekday(.wide).day().month(.wide).year()))
                .font(.headline)
                .foregroundColor(.black)

            Text(daysText)
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
        .accessibilityLabel("\(reminder.title), \(reminder.date.formatted(date: .long, time: .omitted)), \(daysText)")
    }
}