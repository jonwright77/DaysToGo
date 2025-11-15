//
//  ReminderStore.swift
//  DaysToGo
//
//  Created by Jon Wright on 23/07/2025.
//

import Foundation
import CloudKit
import Combine
import DaysToGoKit
import OSLog

/// Sync state for the reminder store.
enum SyncState: Equatable {
    case synced
    case syncing
    case offline
    case error(String)

    static func == (lhs: SyncState, rhs: SyncState) -> Bool {
        switch (lhs, rhs) {
        case (.synced, .synced), (.syncing, .syncing), (.offline, .offline):
            return true
        case (.error(let lhs), .error(let rhs)):
            return lhs == rhs
        default:
            return false
        }
    }
}

@MainActor
class ReminderStore: ReminderStoring, ObservableObject {
    @Published var reminders: [Reminder] = [] {
        didSet {
            saveRemindersToFile()
            notifyChanges()
        }
    }

    @Published var syncState: SyncState = .synced
    
    private let container = CKContainer.default()
    private var database: CKDatabase { container.publicCloudDatabase }
    private let fileURL: URL

    nonisolated init() {
        guard let documentsDirectory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppConstants.appGroupID) else {
            fatalError("Could not access shared app group container. Make sure the App Group is configured correctly.")
        }
        self.fileURL = documentsDirectory.appendingPathComponent(AppConstants.remindersFileName)

        Task { @MainActor in
            self.loadRemindersFromFile()

            NotificationCenter.default.addObserver(self, selector: #selector(self.handleRemoteNotification(_:)), name: .cloudKitNotification, object: nil)

            await self.fetchReminders()
            await self.subscribeToChanges()
        }
    }

    // MARK: - Local File Persistence
    private func loadRemindersFromFile() {
        guard let data = try? Data(contentsOf: fileURL), 
              let decoded = try? JSONDecoder().decode([Reminder].self, from: data) else {
            return
        }
        self.reminders = decoded
    }
    
    private func saveRemindersToFile() {
        do {
            let data = try JSONEncoder().encode(reminders)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            AppLogger.cloudKit.error("Error saving reminders to file: \(error.localizedDescription)")
        }
    }

    /// Notifies observers that reminders have changed.
    /// Posts a notification that triggers widget refresh.
    private func notifyChanges() {
        NotificationCenter.default.post(name: .remindersDidChange, object: nil)
    }

    // MARK: - CloudKit Operations
    func fetchReminders() async {
        syncState = .syncing
        let query = CKQuery(recordType: Reminder.recordType, predicate: NSPredicate(value: true))
        do {
            let result = try await database.records(matching: query)
            let records = result.matchResults.compactMap { try? $0.1.get() }
            let cloudReminders = records.compactMap(Reminder.init)

            // Merge local and cloud data
            mergeReminders(cloudReminders: cloudReminders)
            syncState = .synced
        } catch let error as CKError {
            if error.code == .networkUnavailable || error.code == .networkFailure {
                syncState = .offline
                AppLogger.cloudKit.warning("Network unavailable, working offline")
            } else {
                syncState = .error(error.localizedDescription)
                AppLogger.cloudKit.error("Error fetching reminders: \(error.localizedDescription)")
            }
        } catch {
            syncState = .error(error.localizedDescription)
            AppLogger.cloudKit.error("Error fetching reminders: \(error.localizedDescription)")
        }
    }

    /// Merges cloud reminders with local reminders using conflict resolution.
    /// - Parameter cloudReminders: Reminders fetched from CloudKit.
    private func mergeReminders(cloudReminders: [Reminder]) {
        var mergedReminders: [UUID: Reminder] = [:]

        // Add all local reminders to the merge dictionary
        for localReminder in reminders {
            mergedReminders[localReminder.id] = localReminder
        }

        // Process cloud reminders
        for cloudReminder in cloudReminders {
            if let localReminder = mergedReminders[cloudReminder.id] {
                // Conflict: both local and cloud have this reminder
                // Choose the one with the latest modification date
                if cloudReminder.modifiedAt > localReminder.modifiedAt {
                    mergedReminders[cloudReminder.id] = cloudReminder
                    AppLogger.cloudKit.info("Resolved conflict for reminder \(cloudReminder.id): using cloud version")
                } else {
                    // Keep local version, but sync it to cloud
                    Task {
                        do {
                            _ = try await database.save(localReminder.record)
                            AppLogger.cloudKit.info("Synced local reminder \(localReminder.id) to cloud")
                        } catch {
                            AppLogger.cloudKit.error("Failed to sync local reminder: \(error.localizedDescription)")
                        }
                    }
                }
            } else {
                // New reminder from cloud
                mergedReminders[cloudReminder.id] = cloudReminder
                AppLogger.cloudKit.info("Added new reminder from cloud: \(cloudReminder.id)")
            }
        }

        // Upload any local-only reminders to CloudKit
        let cloudIDs = Set(cloudReminders.map { $0.id })
        let localOnlyReminders = reminders.filter { !cloudIDs.contains($0.id) }

        for localReminder in localOnlyReminders {
            Task {
                do {
                    _ = try await database.save(localReminder.record)
                    AppLogger.cloudKit.info("Uploaded local-only reminder \(localReminder.id) to cloud")
                } catch {
                    AppLogger.cloudKit.error("Failed to upload local reminder: \(error.localizedDescription)")
                }
            }
        }

        // Update reminders array with merged data
        self.reminders = Array(mergedReminders.values).sorted { $0.date < $1.date }
        AppLogger.cloudKit.info("Merge complete: \(self.reminders.count) total reminders")
    }
    
    func addReminder(_ reminder: Reminder) {
        reminders.append(reminder)
        Task {
            do {
                _ = try await database.save(reminder.record)
            } catch {
                AppLogger.cloudKit.error("Error saving reminder to CloudKit: \(error.localizedDescription)")
            }
        }
    }
    
    func updateReminder(_ reminder: Reminder) {
        guard let index = reminders.firstIndex(where: { $0.id == reminder.id }) else { return }

        // Update modification timestamp
        var updatedReminder = reminder
        updatedReminder.modifiedAt = Date()
        reminders[index] = updatedReminder

        Task {
            do {
                _ = try await database.save(updatedReminder.record)
            } catch {
                AppLogger.cloudKit.error("Error updating reminder in CloudKit: \(error.localizedDescription)")
            }
        }
    }
    
    func deleteReminder(withId id: UUID) {
        guard let reminder = reminders.first(where: { $0.id == id }), let recordID = reminder.recordID else {
            // If no recordID, it might not have been synced yet. Just delete locally.
            reminders.removeAll { $0.id == id }
            return
        }

        reminders.removeAll { $0.id == id }

        Task {
            do {
                _ = try await database.deleteRecord(withID: recordID)
            } catch {
                AppLogger.cloudKit.error("Error deleting reminder from CloudKit: \(error.localizedDescription)")
            }
        }
    }

    /// Refreshes reminders from CloudKit.
    /// This is used for pull-to-refresh functionality.
    func refresh() async {
        await fetchReminders()
    }

    // MARK: - Subscription
    
    private func subscribeToChanges() async {
        let subscriptionID = "reminders_changed"
        
        // Check if subscription already exists
        if let subscriptions = try? await database.allSubscriptions(), subscriptions.contains(where: { $0.subscriptionID == subscriptionID }) {
            return
        }
        
        let subscription = CKQuerySubscription(recordType: Reminder.recordType, predicate: NSPredicate(value: true), subscriptionID: subscriptionID, options: [.firesOnRecordCreation, .firesOnRecordUpdate, .firesOnRecordDeletion])
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.shouldSendContentAvailable = true
        subscription.notificationInfo = notificationInfo
        
        do {
            _ = try await database.save(subscription)
        } catch {
            AppLogger.cloudKit.error("Error saving subscription: \(error.localizedDescription)")
        }
    }
    
    @objc func handleRemoteNotification(_ notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        
        if let _ = CKQueryNotification(fromRemoteNotificationDictionary: userInfo) {
            Task {
                await fetchReminders()
            }
        }
    }
}
