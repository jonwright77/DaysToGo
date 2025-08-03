import Foundation
import EventKit

struct CalendarEventViewModel: Identifiable, Hashable {
    let id: String
    let title: String
    let time: String
    let calendarName: String

    init(event: EKEvent) {
        self.id = event.eventIdentifier
        self.title = event.title
        self.time = event.startDate.formatted(date: .omitted, time: .shortened)
        self.calendarName = event.calendar.title
    }
}
