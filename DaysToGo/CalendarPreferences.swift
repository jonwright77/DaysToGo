//
//  CalendarPreferences.swift
//  DaysToGo
//
//  Created by Jon Wright on 31/07/2025.
//


import Foundation
import EventKit

class CalendarPreferences: ObservableObject {
    @Published var enabledCalendarIDs: Set<String> {
        didSet {
            UserDefaults.standard.set(Array(enabledCalendarIDs), forKey: "enabledCalendars")
        }
    }

    init() {
        let saved = UserDefaults.standard.stringArray(forKey: "enabledCalendars") ?? []
        self.enabledCalendarIDs = Set(saved)
    }

    func isEnabled(_ calendar: EKCalendar) -> Bool {
        enabledCalendarIDs.contains(calendar.calendarIdentifier)
    }

    func toggle(_ calendar: EKCalendar) {
        if enabledCalendarIDs.contains(calendar.calendarIdentifier) {
            enabledCalendarIDs.remove(calendar.calendarIdentifier)
        } else {
            enabledCalendarIDs.insert(calendar.calendarIdentifier)
        }
    }
}
