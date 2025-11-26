//
//  ReminderDisplayPreferences.swift
//  DaysToGo
//
//  Created by Claude on 26/11/2025.
//

import Foundation

/// Manages user preferences for which data types to display in reminder detail views
class ReminderDisplayPreferences: ObservableObject {
    @Published var showPhotos: Bool {
        didSet {
            UserDefaults.standard.set(showPhotos, forKey: "showPhotos")
        }
    }

    @Published var showCalendar: Bool {
        didSet {
            UserDefaults.standard.set(showCalendar, forKey: "showCalendar")
        }
    }

    @Published var showOnThisDay: Bool {
        didSet {
            UserDefaults.standard.set(showOnThisDay, forKey: "showOnThisDay")
        }
    }

    @Published var showLocation: Bool {
        didSet {
            UserDefaults.standard.set(showLocation, forKey: "showLocation")
        }
    }

    init() {
        // Default all to true (show everything by default)
        self.showPhotos = UserDefaults.standard.object(forKey: "showPhotos") as? Bool ?? true
        self.showCalendar = UserDefaults.standard.object(forKey: "showCalendar") as? Bool ?? true
        self.showOnThisDay = UserDefaults.standard.object(forKey: "showOnThisDay") as? Bool ?? true
        self.showLocation = UserDefaults.standard.object(forKey: "showLocation") as? Bool ?? true
    }
}
