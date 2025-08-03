//
//  DaysToGoApp.swift
//  DaysToGo
//
//  Created by Jon Wright on 21/07/2025.
//

import SwiftUI

@main
struct DaysToGoApp: App {
    @StateObject var calendarPrefs = CalendarPreferences()

    var body: some Scene {
        WindowGroup {
            ReminderListView()
                .environmentObject(calendarPrefs)  // ✅ Inject into environment
        }
    }
}

