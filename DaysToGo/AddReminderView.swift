//
//  AddReminderView.swift
//  DaysToGo
//
//  Created by Jon Wright on 23/07/2025.
//


import SwiftUI

struct AddReminderView: View {
    @Environment(\.dismiss) var dismiss

    @State private var title: String = ""
    @State private var date: Date = Date()
    
    var onSave: (Reminder) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Reminder")) {
                    TextField("Title", text: $title)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
            }
            .navigationTitle("New Reminder")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let newReminder = Reminder(id: UUID(), title: title, date: date)
                        onSave(newReminder)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
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
