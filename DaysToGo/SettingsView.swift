import SwiftUI
import EventKit

struct SettingsView: View {
    @ObservedObject var calendarPrefs: CalendarPreferences
    @State private var calendars: [EKCalendar] = []

    var body: some View {
        NavigationView {
            List {
                if calendars.isEmpty {
                    Text("No calendars found.")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(calendars, id: \.calendarIdentifier) { calendar in
                        Toggle(calendar.title, isOn: Binding(
                            get: { calendarPrefs.isEnabled(calendar) },
                            set: { newValue in
                                if newValue {
                                    calendarPrefs.enabledCalendarIDs.insert(calendar.calendarIdentifier)
                                } else {
                                    calendarPrefs.enabledCalendarIDs.remove(calendar.calendarIdentifier)
                                }
                            }
                        ))
                    }
                }
            }
            .navigationTitle("Select Calendars")
            .onAppear {
                Task {
                    await requestCalendarAccess()
                }
            }
        }
    }

    // MARK: - Access + Load
    private func requestCalendarAccess() async {
        let store = EKEventStore()

        if #available(iOS 17.0, *) {
            do {
                try await store.requestFullAccessToEvents()
                await MainActor.run {
                    calendars = store.calendars(for: .event)
                }
            } catch {
                // You can show a UI alert here if needed
                print("Calendar access denied: \(error)")
            }
        } else {
            store.requestAccess(to: .event) { granted, _ in
                if granted {
                    DispatchQueue.main.async {
                        calendars = store.calendars(for: .event)
                    }
                }
            }
        }
    }
}
