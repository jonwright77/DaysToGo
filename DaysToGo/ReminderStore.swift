//
//  ReminderStore.swift
//  DaysToGo
//
//  Created by Jon Wright on 23/07/2025.
//


import Foundation

class ReminderStore: ObservableObject {
    @Published var reminders: [Reminder] = [] {
        didSet {
            saveReminders()
        }
    }
    
    private let storageKey = "saved_reminders"
    
    init() {
        loadReminders()
    }
    
    private func loadReminders() {
        if let data = UserDefaults.standard.data(forKey: storageKey) {
            if let decoded = try? JSONDecoder().decode([Reminder].self, from: data) {
                reminders = decoded
            }
        }
    }
    
    private func saveReminders() {
        if let encoded = try? JSONEncoder().encode(reminders) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
    
    func addReminder(_ reminder: Reminder) {
        reminders.append(reminder)
    }
}
