//
//  MockServices.swift
//  DaysToGoTests
//
//  Created by Jon Wright on 01/11/2025.
//

import Foundation
import EventKit
import SwiftUI
import DaysToGoKit
@testable import DaysToGo

@MainActor
class MockReminderStore: ReminderStoring {
    @Published var reminders: [Reminder]

    init(reminders: [Reminder] = []) {
        self.reminders = reminders
    }
    
    func addReminder(_ reminder: Reminder) {
        reminders.append(reminder)
    }
    
    func updateReminder(_ reminder: Reminder) {
        if let index = reminders.firstIndex(where: { $0.id == reminder.id }) {
            reminders[index] = reminder
        }
    }
    
    func deleteReminder(withId id: UUID) {
        reminders.removeAll { $0.id == id }
    }
}

class MockPhotoService: PhotoFetching {
    var shouldThrowError = false
    var photosToReturn: [UIImage] = []
    
    func requestAuthorization() async throws {
        if shouldThrowError {
            throw AppError.permissionDenied(service: "Photos")
        }
    }
    
    func fetchPhotos(from date: Date, maxCount: Int) async throws -> [UIImage] {
        if shouldThrowError {
            throw AppError.underlying(NSError(domain: "PhotoFetchError", code: 1))
        }
        return photosToReturn
    }
}

class MockCalendarService: CalendarFetching {
    var shouldThrowError = false
    var calendarsToReturn: [EKCalendar] = []
    var eventsToReturn: [EKEvent] = []

    func requestAuthorization() async throws {
        if shouldThrowError {
            throw AppError.permissionDenied(service: "Calendar")
        }
    }

    func fetchCalendars() async throws -> [EKCalendar] {
        if shouldThrowError {
            throw AppError.underlying(NSError(domain: "CalendarFetchError", code: 1))
        }
        return calendarsToReturn
    }

    func fetchEvents(from date: Date, in calendars: [EKCalendar]) async throws -> [EKEvent] {
        if shouldThrowError {
            throw AppError.underlying(NSError(domain: "EventFetchError", code: 1))
        }
        return eventsToReturn
    }
}

class MockHistoryService: HistoricalEventFetching {
    var shouldThrowError = false
    var eventsToReturn: [HistoricalEvent] = []

    func fetchEvents(from date: Date, maxCount: Int) async throws -> [HistoricalEvent] {
        if shouldThrowError {
            throw AppError.underlying(NSError(domain: "HistoryFetchError", code: 1))
        }
        return eventsToReturn
    }

    func enhanceWithAI(_ events: [HistoricalEvent]) async -> [HistoricalEvent] {
        // Mock AI enhancement - just add a simple summary
        return events.map { event in
            var enhanced = event
            enhanced.aiSummary = "In \(event.year), \(event.text.lowercased())"
            return enhanced
        }
    }
}
