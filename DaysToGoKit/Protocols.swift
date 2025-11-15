//
//  Protocols.swift
//  DaysToGoKit
//
//  Created by Claude on 07/11/2025.
//

import Foundation
import Combine
import UIKit
import EventKit

// MARK: - Storage Protocol

/// Protocol for managing reminder storage and persistence.
/// All conforming types must be MainActor-isolated as they manage UI-bound state.
@MainActor
public protocol ReminderStoring: ObservableObject {
    /// The current list of reminders.
    var reminders: [Reminder] { get }

    /// Adds a new reminder to the store.
    /// - Parameter reminder: The reminder to add.
    func addReminder(_ reminder: Reminder)

    /// Updates an existing reminder in the store.
    /// - Parameter reminder: The reminder with updated values.
    func updateReminder(_ reminder: Reminder)

    /// Deletes a reminder from the store.
    /// - Parameter id: The unique identifier of the reminder to delete.
    func deleteReminder(withId id: UUID)

    /// Refreshes reminders from the remote data source (CloudKit).
    /// Use this for pull-to-refresh functionality.
    func refresh() async
}

// MARK: - Photo Service Protocol

/// Protocol for fetching photos from the device's photo library.
public protocol PhotoFetching {
    /// Requests authorization to access the photo library.
    /// - Throws: `AppError.permissionDenied` if authorization is denied.
    func requestAuthorization() async throws

    /// Fetches photos taken on a specific date.
    /// - Parameters:
    ///   - date: The date to fetch photos from.
    ///   - maxCount: Maximum number of photos to return.
    /// - Returns: An array of UIImage objects.
    /// - Throws: `AppError` if the operation fails.
    func fetchPhotos(from date: Date, maxCount: Int) async throws -> [UIImage]
}

// MARK: - Calendar Service Protocol

/// Protocol for fetching calendar data from the device.
public protocol CalendarFetching {
    /// Requests authorization to access calendar data.
    /// - Throws: `AppError.permissionDenied` if authorization is denied.
    func requestAuthorization() async throws

    /// Fetches all available calendars.
    /// - Returns: An array of EKCalendar objects.
    /// - Throws: `AppError` if the operation fails.
    func fetchCalendars() async throws -> [EKCalendar]

    /// Fetches events for a specific date from specified calendars.
    /// - Parameters:
    ///   - date: The date to fetch events for.
    ///   - calendars: The calendars to search within.
    /// - Returns: An array of EKEvent objects.
    /// - Throws: `AppError` if the operation fails.
    func fetchEvents(from date: Date, in calendars: [EKCalendar]) async throws -> [EKEvent]
}

// MARK: - Historical Event Service Protocol

/// Protocol for fetching historical events from Wikipedia's "On This Day" feature.
public protocol HistoricalEventFetching {
    /// Fetches historical events from a specific date.
    /// - Parameters:
    ///   - date: The date to fetch historical events from.
    ///   - maxCount: Maximum number of events to return (default: 10).
    /// - Returns: An array of HistoricalEvent objects.
    /// - Throws: `AppError` if the operation fails (network, API error, etc.).
    func fetchEvents(from date: Date, maxCount: Int) async throws -> [HistoricalEvent]

    /// Enhances events with AI-generated summaries (iOS 18+ only).
    /// - Parameter events: The events to enhance.
    /// - Returns: Events with AI summaries added (where available).
    /// - Note: On devices without Apple Intelligence, returns events unchanged.
    func enhanceWithAI(_ events: [HistoricalEvent]) async -> [HistoricalEvent]
}
