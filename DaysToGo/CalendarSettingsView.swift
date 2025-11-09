import SwiftUI
import EventKit
import DaysToGoKit

struct CalendarSettingsView: View {
    @ObservedObject var calendarPrefs: CalendarPreferences
    @State private var calendars: [EKCalendar] = []
    @State private var alertError: AppError?

    private let calendarService: any CalendarFetching

    init(
        calendarPrefs: CalendarPreferences,
        calendarService: (any CalendarFetching)? = nil
    ) {
        self.calendarPrefs = calendarPrefs
        self.calendarService = calendarService ?? ServiceContainer.shared.calendarService
    }

    var body: some View {
        List {
            if calendars.isEmpty {
                Text("No calendars found.")
                    .foregroundColor(.secondary)
            } else {
                ForEach(calendars, id: \.calendarIdentifier) { calendar in
                    Toggle(calendar.title, isOn: Binding(
                        get: { calendarPrefs.isEnabled(calendar) },
                        set: { _ in calendarPrefs.toggle(calendar) }
                    ))
                    .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                }
            }
        }
        .navigationTitle("Select Calendars")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            Task {
                await loadCalendars()
            }
        }
        .alert(isPresented: $alertError.isPresent, error: alertError) { error in
            Button("OK") {
                alertError = nil
            }
            if error.shouldShowSettingsButton {
                Button("Open Settings") {
                    alertError = nil
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
            }
        } message: { error in
            if let suggestion = error.recoverySuggestion {
                Text(suggestion)
            }
        }
    }

    private func loadCalendars() async {
        do {
            calendars = try await calendarService.fetchCalendars()
        } catch let error as AppError {
            self.alertError = error
        } catch {
            self.alertError = .underlying(error)
        }
    }
}
