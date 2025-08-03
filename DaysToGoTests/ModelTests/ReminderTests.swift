//
//  ReminderTests.swift
//  DaysToGoTests
//
//  Created by Jon Wright on 01/11/2025.
//

import XCTest
@testable import DaysToGo

class ReminderTests: XCTestCase {

    func testDaysRemaining_FutureDate() {
        // Given
        let today = Date()
        let futureDate = Calendar.current.date(byAdding: .day, value: 10, to: today)!
        let reminder = Reminder(id: UUID(), title: "Test", date: futureDate)
        
        // When
        let daysRemaining = reminder.daysRemaining
        
        // Then
        XCTAssertEqual(daysRemaining, 10, "Days remaining should be 10 for a date 10 days in the future.")
    }

    func testDaysRemaining_PastDate() {
        // Given
        let today = Date()
        let pastDate = Calendar.current.date(byAdding: .day, value: -5, to: today)!
        let reminder = Reminder(id: UUID(), title: "Test", date: pastDate)
        
        // When
        let daysRemaining = reminder.daysRemaining
        
        // Then
        XCTAssertEqual(daysRemaining, -5, "Days remaining should be -5 for a date 5 days in the past.")
    }

    func testDaysRemaining_Today() {
        // Given
        let reminder = Reminder(id: UUID(), title: "Test", date: Date())
        
        // When
        let daysRemaining = reminder.daysRemaining
        
        // Then
        XCTAssertEqual(daysRemaining, 0, "Days remaining should be 0 for today.")
    }

    func testReflectionDate() {
        // Given
        let today = Calendar.current.startOfDay(for: Date())
        let futureDate = Calendar.current.date(byAdding: .day, value: 20, to: today)!
        let reminder = Reminder(id: UUID(), title: "Test", date: futureDate)
        
        // When
        let reflectionDate = reminder.reflectionDate
        
        // Then
        let expectedReflectionDate = Calendar.current.date(byAdding: .day, value: -20, to: today)
        XCTAssertEqual(reflectionDate, expectedReflectionDate, "Reflection date should be 20 days in the past.")
    }
}
