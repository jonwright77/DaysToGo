//
//  ReminderDetailViewModel.swift
//  DaysToGo
//
//  Created by Jon Wright on 01/11/2025.
//

import Foundation
import SwiftUI
import EventKit
import CloudKit
import Combine
import DaysToGoKit

// MARK: - ViewModel

@MainActor
class ReminderDetailViewModel: ObservableObject {
    @Published var reminder: Reminder
    @Published var reflectionPhotos: [UIImage] = []
    @Published var calendarEvents: [CalendarEventViewModel] = []
    @Published var historicalEvents: [HistoricalEvent] = []
    @Published var locationPoints: [LocationPoint] = []
    @Published var isLoadingPhotos = false
    @Published var isLoadingEvents = false
    @Published var isLoadingHistory = false
    @Published var isLoadingLocations = false
    @Published var alertError: AppError?

    private let reminderStore: any ReminderStoring
    private let photoService: any PhotoFetching
    private let calendarService: any CalendarFetching
    private let historyService: any HistoricalEventFetching
    private let locationService: any LocationFetching

    // Cache keys to avoid redundant API calls
    private var cachedReflectionDate: Date?
    private var cachedCalendarIDs: Set<String>?

    /// Initializes the view model with explicit service dependencies.
    /// - Parameters:
    ///   - reminder: The reminder to display.
    ///   - reminderStore: The store managing reminders.
    ///   - photoService: The service for fetching photos.
    ///   - calendarService: The service for fetching calendar events.
    ///   - historyService: The service for fetching historical events.
    ///   - locationService: The service for fetching location data.
    init(
        reminder: Reminder,
        reminderStore: any ReminderStoring,
        photoService: any PhotoFetching,
        calendarService: any CalendarFetching,
        historyService: any HistoricalEventFetching,
        locationService: any LocationFetching
    ) {
        self.reminder = reminder
        self.reminderStore = reminderStore
        self.photoService = photoService
        self.calendarService = calendarService
        self.historyService = historyService
        self.locationService = locationService
    }

    /// Convenience initializer using the shared service container.
    /// - Parameters:
    ///   - reminder: The reminder to display.
    ///   - container: The service container. Defaults to the shared instance.
    convenience init(
        reminder: Reminder,
        container: ServiceContainer? = nil
    ) {
        let services = container ?? .shared
        self.init(
            reminder: reminder,
            reminderStore: services.reminderStore,
            photoService: services.photoService,
            calendarService: services.calendarService,
            historyService: services.historyService,
            locationService: services.locationService
        )
    }

    /// Convenience initializer with a specific reminder store.
    /// Uses the shared service container for photo, calendar, history, and location services.
    /// - Parameters:
    ///   - reminder: The reminder to display.
    ///   - reminderStore: The store managing reminders.
    convenience init(
        reminder: Reminder,
        reminderStore: any ReminderStoring
    ) {
        self.init(
            reminder: reminder,
            reminderStore: reminderStore,
            photoService: ServiceContainer.shared.photoService,
            calendarService: ServiceContainer.shared.calendarService,
            historyService: ServiceContainer.shared.historyService,
            locationService: ServiceContainer.shared.locationService
        )
    }

    func loadPhotosAndCalendarEvents(calendarPrefs: CalendarPreferences) {
        guard let reflectionDate = reminder.reflectionDate else { return }

        let calendarIDSet = calendarPrefs.enabledCalendarIDs

        // Check if we need to reload data
        let shouldReloadPhotos = cachedReflectionDate != reflectionDate
        let shouldReloadEvents = cachedReflectionDate != reflectionDate || cachedCalendarIDs != calendarIDSet
        let shouldReloadHistory = cachedReflectionDate != reflectionDate
        let shouldReloadLocations = cachedReflectionDate != reflectionDate

        // Update cache keys
        cachedReflectionDate = reflectionDate
        cachedCalendarIDs = calendarIDSet

        if shouldReloadPhotos {
            Task {
                isLoadingPhotos = true
                defer { isLoadingPhotos = false }
                do {
                    reflectionPhotos = try await photoService.fetchPhotos(from: reflectionDate, maxCount: 4)
                } catch let error as AppError {
                    if self.alertError == nil {
                        self.alertError = error
                    }
                } catch {
                    if self.alertError == nil {
                        self.alertError = .underlying(error)
                    }
                }
            }
        }

        if shouldReloadEvents {
            Task {
                isLoadingEvents = true
                defer { isLoadingEvents = false }
                do {
                    let allCalendars = try await calendarService.fetchCalendars()
                    let enabledCalendars = allCalendars.filter {
                        calendarIDSet.contains($0.calendarIdentifier)
                    }
                    let events = try await calendarService.fetchEvents(from: reflectionDate, in: enabledCalendars)
                    calendarEvents = events.map { CalendarEventViewModel(event: $0) }
                } catch let error as AppError {
                    if self.alertError == nil {
                        self.alertError = error
                    }
                } catch {
                    if self.alertError == nil {
                        self.alertError = .underlying(error)
                    }
                }
            }
        }

        if shouldReloadHistory {
            Task {
                isLoadingHistory = true
                defer { isLoadingHistory = false }
                do {
                    var events = try await historyService.fetchEvents(from: reflectionDate, maxCount: 10)
                    // Enhance with AI summaries (iOS 18+ only, no-op on older versions)
                    events = await historyService.enhanceWithAI(events)
                    historicalEvents = events
                } catch let error as AppError {
                    if self.alertError == nil {
                        self.alertError = error
                    }
                } catch {
                    // Silently fail for historical events - not critical
                    AppLogger.general.error("Failed to fetch historical events: \(error.localizedDescription)")
                }
            }
        }

        if shouldReloadLocations {
            Task {
                isLoadingLocations = true
                defer { isLoadingLocations = false }
                do {
                    let locations = try await locationService.fetchLocations(from: reflectionDate, maxCount: 50)
                    self.locationPoints = locations
                    AppLogger.general.info("Fetched \(locations.count) location points for reflection date")
                } catch {
                    // Silently fail for locations - not critical, may not have data yet
                    AppLogger.general.error("Failed to fetch locations: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func deleteReminder() {
        reminderStore.deleteReminder(withId: reminder.id)
    }
    
    func updateReminder(_ updatedReminder: Reminder) {
        reminderStore.updateReminder(updatedReminder)
        self.reminder = updatedReminder
    }
}
