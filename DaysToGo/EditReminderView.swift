//
//  EditReminderView.swift
//  DaysToGo
//
//  Created by Jon Wright on 23/07/2025.
//


import SwiftUI

struct EditReminderView: View {
    @Environment(\.dismiss) var dismiss

    @Binding var reminder: Reminder
    @State private var updatedTitle: String
    @State private var updatedDate: Date

    var onSave: (Reminder) -> Void

    init(reminder: Binding<Reminder>, onSave: @escaping (Reminder) -> Void) {
        self._reminder = reminder
        self._updatedTitle = State(initialValue: reminder.wrappedValue.title)
        self._updatedDate = State(initialValue: reminder.wrappedValue.date)
        self.onSave = onSave
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Edit Reminder")) {
                    TextField("Title", text: $updatedTitle)
                    DatePicker("Date", selection: $updatedDate, displayedComponents: .date)
                }
            }
            .navigationTitle("Edit Reminder")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        reminder.title = updatedTitle
                        reminder.date = updatedDate
                        onSave(reminder)
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
