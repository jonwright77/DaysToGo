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
            Section(header: Text("Title")) {
                TextField("Enter reminder title", text: $title)
            }

            Section(header: Text("Date")) {
                DatePicker("Select date", selection: $date, displayedComponents: .date)
            }

            Section(header: Text("Details")) {
                TextEditor(text: $description)
                    .frame(height: 100)
            }

            Section(header: Text("Colour")) {
                ColorPickerView(selectedColor: $selectedColor)
            }
        }
    }
}
