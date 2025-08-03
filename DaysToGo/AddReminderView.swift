//
//  AddReminderView.swift
//  DaysToGo
//
//  Created by Jon Wright on 23/07/2025.
//


import SwiftUI
import DaysToGoKit

struct AddReminderView: View {
    @Environment(\.dismiss) var dismiss

    @State private var title: String = ""
    @State private var date: Date = Date()
    @State private var description: String = ""
    @State private var selectedColor: PastelColor = .pastelGray
    
    var onSave: (Reminder) -> Void
    
    var body: some View {
        NavigationStack {
            ReminderFormView(
                title: $title,
                date: $date,
                description: $description,
                selectedColor: $selectedColor
            )
            .navigationTitle("New Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let newReminder = Reminder(id: UUID(), title: title, date: date, description: description, backgroundColor: selectedColor.rawValue)
                        onSave(newReminder)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                    .accessibilityLabel("Save new reminder")
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .accessibilityLabel("Cancel adding reminder")
                }
            }
        }
    }
}
