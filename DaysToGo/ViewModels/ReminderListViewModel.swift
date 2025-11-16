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

    private let reminderStore: any ReminderStoring
    private var cancellables = Set<AnyCancellable>()
    
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

    /// Refreshes reminders from CloudKit.
    /// Call this method for pull-to-refresh functionality.
    func refresh() async {
        await reminderStore.refresh()
        // Update refresh date to trigger view updates for computed properties like daysRemaining
        lastRefreshDate = Date()
    }
}
