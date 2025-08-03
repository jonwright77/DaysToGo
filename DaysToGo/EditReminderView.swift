//
//  EditReminderView.swift
//  DaysToGo
//
//  Created by Jon Wright on 23/07/2025.
//


import SwiftUI
import DaysToGoKit

struct EditReminderView: View {
    @Environment(\.dismiss) var dismiss

    @Binding var reminder: Reminder
    @State private var updatedTitle: String
    @State private var updatedDate: Date
    @State private var updatedDescription: String
    @State private var updatedSelectedColor: PastelColor

    var onSave: (Reminder) -> Void

    init(reminder: Binding<Reminder>, onSave: @escaping (Reminder) -> Void) {
        self._reminder = reminder
        self._updatedTitle = State(initialValue: reminder.wrappedValue.title)
        self._updatedDate = State(initialValue: reminder.wrappedValue.date)
        self._updatedDescription = State(initialValue: reminder.wrappedValue.description ?? "")
        self._updatedSelectedColor = State(initialValue: PastelColor(rawValue: reminder.wrappedValue.backgroundColor ?? "Pastel Gray") ?? .pastelGray)
        self.onSave = onSave
    }

    var body: some View {
        NavigationStack {
            ReminderFormView(
                title: $updatedTitle,
                date: $updatedDate,
                description: $updatedDescription,
                selectedColor: $updatedSelectedColor
            )
            .navigationTitle("Edit Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        reminder.title = updatedTitle
                        reminder.date = updatedDate
                        reminder.description = updatedDescription
                        reminder.backgroundColor = updatedSelectedColor.rawValue
                        onSave(reminder)
                        dismiss()
                    }
                    .accessibilityLabel("Save changes to reminder")
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .accessibilityLabel("Cancel editing reminder")
                }
            }
        }
    }
}
