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
    @Published var newsHeadlines: [NewsHeadline] = []
    @Published var isLoadingPhotos = false
    @Published var isLoadingEvents = false
    @Published var isLoadingNews = false
    @Published var alertError: AppError?

    private let reminderStore: any ReminderStoring
    private let photoService: any PhotoFetching
    private let calendarService: any CalendarFetching
    private let newsService: any NewsFetching

    // Cache keys to avoid redundant API calls
    private var cachedReflectionDate: Date?
    private var cachedCalendarIDs: Set<String>?

    /// Initializes the view model with explicit service dependencies.
    /// - Parameters:
    ///   - reminder: The reminder to display.
    ///   - reminderStore: The store managing reminders.
    ///   - photoService: The service for fetching photos.
    ///   - calendarService: The service for fetching calendar events.
    ///   - newsService: The service for fetching news headlines.
    init(
        reminder: Reminder,
        reminderStore: any ReminderStoring,
        photoService: any PhotoFetching,
        calendarService: any CalendarFetching,
        newsService: any NewsFetching
    ) {
        self.reminder = reminder
        self.reminderStore = reminderStore
        self.photoService = photoService
        self.calendarService = calendarService
        self.newsService = newsService
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
            newsService: services.newsService
        )
    }

    /// Convenience initializer with a specific reminder store.
    /// Uses the shared service container for photo, calendar, and news services.
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
            newsService: ServiceContainer.shared.newsService
        )
    }

    func loadPhotosAndCalendarEvents(calendarPrefs: CalendarPreferences) {
        guard let reflectionDate = reminder.reflectionDate else { return }

        let calendarIDSet = calendarPrefs.enabledCalendarIDs

        // Check if we need to reload data
        let shouldReloadPhotos = cachedReflectionDate != reflectionDate
        let shouldReloadEvents = cachedReflectionDate != reflectionDate || cachedCalendarIDs != calendarIDSet
        let shouldReloadNews = cachedReflectionDate != reflectionDate

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

        if shouldReloadNews {
            Task {
                isLoadingNews = true
                defer { isLoadingNews = false }
                do {
                    var headlines = try await newsService.fetchHeadlines(from: reflectionDate, maxCount: 5)
                    // Enhance with AI summaries (iOS 18+ only, no-op on older versions)
                    headlines = await newsService.enhanceWithAI(headlines)
                    newsHeadlines = headlines
                } catch let error as AppError {
                    if self.alertError == nil {
                        self.alertError = error
                    }
                } catch {
                    // Show error for debugging (can make silent later)
                    AppLogger.general.error("Failed to fetch news headlines: \(error.localizedDescription)")
                    if self.alertError == nil {
                        if let appError = error as? AppError {
                            self.alertError = appError
                        } else {
                            self.alertError = .underlying(error)
                        }
                    }
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
