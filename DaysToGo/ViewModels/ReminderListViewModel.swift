//
//  ReminderListViewModel.swift
//  DaysToGo
//
//  Created by Jon Wright on 01/11/2025.
//

import Foundation
import Combine
import DaysToGoKit

@MainActor
class ReminderListViewModel: ObservableObject {
    @Published var reminders: [Reminder] = []
    @Published var lastRefreshDate: Date = Date()
    @Published var selectedView: ReminderViewMode = .reminders

    enum ReminderViewMode {
        case reminders  // Future and today
        case history    // Past
    }

    private let reminderStore: any ReminderStoring
    private var cancellables = Set<AnyCancellable>()

    /// Reminders for today and future dates (daysRemaining >= 0)
    var futureReminders: [Reminder] {
        reminders.filter { $0.daysRemaining >= 0 }.sorted { $0.date < $1.date }
    }

    /// Reminders for past dates (daysRemaining < 0)
    var pastReminders: [Reminder] {
        reminders.filter { $0.daysRemaining < 0 }.sorted { $0.date > $1.date }
    }

    /// Returns the appropriate list based on selected view
    var displayedReminders: [Reminder] {
        switch selectedView {
        case .reminders:
            return futureReminders
        case .history:
            return pastReminders
        }
    }

    init(reminderStore: any ReminderStoring) {
        self.reminderStore = reminderStore
        self.reminders = reminderStore.reminders
        subscribeToStoreChanges(store: reminderStore)
    }
    
    private func subscribeToStoreChanges<S: ReminderStoring>(store: S) {
        store.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.reminders = self?.reminderStore.reminders ?? []
            }
            .store(in: &cancellables)
    }
    
    func addReminder(_ reminder: Reminder) {
        reminderStore.addReminder(reminder)
    }

    func deleteReminder(_ reminder: Reminder) {
        reminderStore.deleteReminder(withId: reminder.id)
    }

    /// Refreshes reminders from CloudKit.
    /// Call this method for pull-to-refresh functionality.
    func refresh() async {
        await reminderStore.refresh()
        // Update refresh date to trigger view updates for computed properties like daysRemaining
        lastRefreshDate = Date()
    }
}
