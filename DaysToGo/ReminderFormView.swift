//
//  ReminderFormView.swift
//  DaysToGo
//
//  Created by Claude on 07/11/2025.
//

import SwiftUI
import DaysToGoKit

/// Reusable form component for reminder fields.
///
/// This view provides a consistent form layout for both creating new reminders
/// and editing existing ones. It includes fields for title, date, description,
/// and color selection.
struct ReminderFormView: View {
    @Binding var title: String
    @Binding var date: Date
    @Binding var description: String
    @Binding var selectedColor: PastelColor

    var body: some View {
        Form {
            Section(header: Text("Reminder")) {
                TextField("Title", text: $title)
                DatePicker("Date", selection: $date, displayedComponents: .date)
            }

            Section(header: Text("Details")) {
                TextEditor(text: $description)
                    .frame(height: 100)

                ColorPickerView(selectedColor: $selectedColor)
            }
        }
    }
}
