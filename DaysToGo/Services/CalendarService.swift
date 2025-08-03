//
//  CalendarService.swift
//  DaysToGo
//
//  Created by Jon Wright on 01/11/2025.
//

import Foundation
import EventKit
import DaysToGoKit

class CalendarService: CalendarFetching {
    private let eventStore = EKEventStore()

    func requestAuthorization() async throws {
        if #available(iOS 17.0, *) {
            let status = EKEventStore.authorizationStatus(for: .event)
            if status == .notDetermined {
                try await eventStore.requestFullAccessToEvents()
            }
            let newStatus = EKEventStore.authorizationStatus(for: .event)
            guard newStatus == .fullAccess else {
                throw AppError.permissionDenied(service: "Calendar")
            }
        } else {
            let hasAccess = try await eventStore.requestAccess(to: .event)
            if !hasAccess {
                throw AppError.permissionDenied(service: "Calendar")
            }
        }
    }

    func fetchCalendars() async throws -> [EKCalendar] {
        try await requestAuthorization()
        return eventStore.calendars(for: .event)
    }

    func fetchEvents(from date: Date, in calendars: [EKCalendar]) async throws -> [EKEvent] {
        try await requestAuthorization()
        
        guard !calendars.isEmpty else {
            return []
        }

        let startOfDay = Calendar.current.startOfDay(for: date)
        guard let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay) else {
            return []
        }

        let predicate = eventStore.predicateForEvents(withStart: startOfDay, end: endOfDay, calendars: calendars)
        return eventStore.events(matching: predicate)
    }
}
