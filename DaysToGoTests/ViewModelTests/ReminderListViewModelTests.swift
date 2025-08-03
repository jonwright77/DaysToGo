//
//  ReminderListViewModelTests.swift
//  DaysToGoTests
//
//  Created by Jon Wright on 01/11/2025.
//

import XCTest
@testable import DaysToGo

@MainActor
class ReminderListViewModelTests: XCTestCase {

    var mockStore: MockReminderStore!
    var viewModel: ReminderListViewModel!

    override func setUp() {
        super.setUp()
        let reminders = [
            Reminder(id: UUID(), title: "Test 1", date: Date()),
            Reminder(id: UUID(), title: "Test 2", date: Date())
        ]
        mockStore = MockReminderStore(reminders: reminders)
        viewModel = ReminderListViewModel(reminderStore: mockStore)
    }

    func test_initialRemindersAreLoaded() {
        XCTAssertEqual(viewModel.reminders.count, 2)
    }

    func test_addReminder() {
        // Given
        let newReminder = Reminder(id: UUID(), title: "New Reminder", date: Date())
        
        // When
        viewModel.addReminder(newReminder)
        mockStore.objectWillChange.send()
        
        // Then
        XCTAssertEqual(viewModel.reminders.count, 3)
        XCTAssertTrue(viewModel.reminders.contains(where: { $0.title == "New Reminder" }))
    }
}
