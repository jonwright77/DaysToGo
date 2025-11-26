//
//  ReminderDisplaySettingsView.swift
//  DaysToGo
//
//  Created by Claude on 26/11/2025.
//

import SwiftUI

struct ReminderDisplaySettingsView: View {
    @ObservedObject var displayPrefs: ReminderDisplayPreferences

    var body: some View {
        List {
            Section {
                Toggle("Photos", isOn: $displayPrefs.showPhotos)
                    .toggleStyle(SwitchToggleStyle(tint: .accentColor))

                Toggle("Calendar Events", isOn: $displayPrefs.showCalendar)
                    .toggleStyle(SwitchToggleStyle(tint: .accentColor))

                Toggle("On This Day", isOn: $displayPrefs.showOnThisDay)
                    .toggleStyle(SwitchToggleStyle(tint: .accentColor))

                Toggle("Location", isOn: $displayPrefs.showLocation)
                    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
            } header: {
                Text("Visible Data Types")
            } footer: {
                Text("Choose which types of information to display in reminder details. Disabled types will not appear at all.")
            }
        }
        .navigationTitle("Display Options")
        .navigationBarTitleDisplayMode(.inline)
    }
}
