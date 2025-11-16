//
//  ServiceContainer.swift
//  DaysToGo
//
//  Created by Claude on 07/11/2025.
//

import Foundation
import DaysToGoKit

/// Centralized dependency injection container for managing service instances.
///
/// The ServiceContainer follows the Dependency Injection pattern, providing a single
/// source of truth for all service dependencies throughout the application.
///
/// Usage:
/// ```swift
/// // Access shared instance in production
/// let services = ServiceContainer.shared
///
/// // Create custom instance for testing
/// let testServices = ServiceContainer(
///     photoService: MockPhotoService(),
///     calendarService: MockCalendarService(),
///     reminderStore: MockReminderStore()
/// )
/// ```
@MainActor
class ServiceContainer {
    /// Shared singleton instance for production use.
    static let shared = ServiceContainer()

    /// Service for photo library operations.
    let photoService: any PhotoFetching

    /// Service for calendar and event operations.
    let calendarService: any CalendarFetching

    /// Service for reminder storage and synchronization.
    let reminderStore: any ReminderStoring

    /// Service for fetching historical events from Wikipedia.
    let historyService: any HistoricalEventFetching

    /// Service for tracking and fetching location data.
    let locationService: any LocationFetching

    /// Initializes a new service container with specified or default services.
    /// - Parameters:
    ///   - photoService: The photo service to use. Defaults to `PhotoService()`.
    ///   - calendarService: The calendar service to use. Defaults to `CalendarService()`.
    ///   - reminderStore: The reminder store to use. Defaults to `ReminderStore()`.
    ///   - historyService: The historical event service to use. Defaults to `WikipediaService()`.
    ///   - locationService: The location service to use. Defaults to `LocationService()`.
    init(
        photoService: any PhotoFetching = PhotoService(),
        calendarService: any CalendarFetching = CalendarService(),
        reminderStore: any ReminderStoring = ReminderStore(),
        historyService: any HistoricalEventFetching = WikipediaService(),
        locationService: any LocationFetching = LocationService()
    ) {
        self.photoService = photoService
        self.calendarService = calendarService
        self.reminderStore = reminderStore
        self.historyService = historyService
        self.locationService = locationService
    }
}
