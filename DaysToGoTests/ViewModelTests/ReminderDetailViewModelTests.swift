//
//  ReminderDetailViewModelTests.swift
//  DaysToGoTests
//
//  Created by Jon Wright on 01/11/2025.
//

import XCTest
@testable import DaysToGo

@MainActor
class ReminderDetailViewModelTests: XCTestCase {

    var mockReminderStore: MockReminderStore!
    var mockPhotoService: MockPhotoService!
    var mockCalendarService: MockCalendarService!
    var viewModel: ReminderDetailViewModel!
    var testReminder: Reminder!

    override func setUp() {
        super.setUp()
        testReminder = Reminder(id: UUID(), title: "Test Reminder", date: Date())
        mockReminderStore = MockReminderStore(reminders: [testReminder])
        mockPhotoService = MockPhotoService()
        mockCalendarService = MockCalendarService()
        
        viewModel = ReminderDetailViewModel(
            reminder: testReminder,
            reminderStore: mockReminderStore,
            photoService: mockPhotoService,
            calendarService: mockCalendarService
        )
    }

    func test_loadPhotosAndEvents_success() async {
        // Given
        mockPhotoService.photosToReturn = [UIImage(), UIImage()]
        let calendarPrefs = CalendarPreferences()
        
        // When
        viewModel.loadPhotosAndCalendarEvents(calendarPrefs: calendarPrefs)
        await Task.yield() // Allow async tasks to run
        
        // Then
        XCTAssertEqual(viewModel.reflectionPhotos.count, 2)
        XCTAssertNil(viewModel.alertError)
    }

    func test_loadPhotos_failure() async {
        // Given
        mockPhotoService.shouldThrowError = true
        let calendarPrefs = CalendarPreferences()

        // When
        viewModel.loadPhotosAndCalendarEvents(calendarPrefs: calendarPrefs)
        await Task.yield()

        // Then
        XCTAssertNotNil(viewModel.alertError)
        XCTAssertTrue(viewModel.reflectionPhotos.isEmpty)
    }

    func test_deleteReminder() {
        // When
        viewModel.deleteReminder()
        
        // Then
        XCTAssertTrue(mockReminderStore.reminders.isEmpty)
    }

    func test_updateReminder() {
        // Given
        var updatedReminder = testReminder!
        updatedReminder.title = "Updated Title"
        
        // When
        viewModel.updateReminder(updatedReminder)
        
        // Then
        XCTAssertEqual(viewModel.reminder.title, "Updated Title")
        XCTAssertEqual(mockReminderStore.reminders.first?.title, "Updated Title")
    }
}
