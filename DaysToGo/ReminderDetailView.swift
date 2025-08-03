import SwiftUI
import Photos
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

struct CalendarStatus: Identifiable {
    let id: String
    let title: String
    let isEnabled: Bool
}

struct ReminderDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var calendarPrefs: CalendarPreferences

    @State var reminder: Reminder
    @ObservedObject var store: ReminderStore

    @State private var showingEdit = false
    @State private var reflectionPhotos: [UIImage] = []
    @State private var calendarEvents: [CalendarEventViewModel] = []
    @State private var calendarStatuses: [CalendarStatus] = []

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Title
                Text(reminder.title)
                    .font(.title)
                    .bold()

                // Date Range
                if let reflectionDate = reminder.reflectionDate {
                    HStack {
                        Text(reflectionDate.formatted(date: .long, time: .omitted))
                        Spacer()
                        Text("\(reminder.daysRemaining) Day\(reminder.daysRemaining == 1 ? "" : "s")")
                            .fontWeight(.medium)
                        Spacer()
                        Text(reminder.date.formatted(date: .long, time: .omitted))
                    }
                    .font(.body)
                    .padding(.horizontal)
                }

                Divider()

                // Reflection Photos
                if !reflectionPhotos.isEmpty {
                    LazyVGrid(columns: [GridItem(), GridItem()], spacing: 8) {
                        ForEach(reflectionPhotos, id: \.self) { image in
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 160, height: 160)
                                .clipped()
                                .cornerRadius(8)
                        }
                    }
                    .padding(.top)
                } else if let reflectionDate = reminder.reflectionDate {
                    Text("No Photos on \(reflectionDate.formatted(date: .long, time: .omitted))")
                        .foregroundColor(.secondary)
                        .padding(.top)
                }

                Divider()

                // Calendar Events
                if !calendarEvents.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(calendarEvents) { event in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(event.title)
                                    .font(.headline)
                                Text(event.time)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text(event.calendarName)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                } else if let reflectionDate = reminder.reflectionDate {
                    Text("No Calendar Events for \(reflectionDate.formatted(date: .long, time: .omitted))")
                        .foregroundColor(.secondary)
                        .padding(.top)
                }

                Spacer()

                // Actions
                HStack(spacing: 30) {
                    Button("Edit") {
                        showingEdit = true
                    }
                    .buttonStyle(.bordered)

                    Button("Delete") {
                        if let index = store.reminders.firstIndex(where: { $0.id == reminder.id }) {
                            store.reminders.remove(at: index)
                            dismiss()
                        }
                    }
                    .foregroundColor(.red)
                }
            }
            .padding()
        }
        .navigationTitle("Reminder Details")
        .sheet(isPresented: $showingEdit) {
            EditReminderView(reminder: $reminder) { updated in
                if let index = store.reminders.firstIndex(where: { $0.id == reminder.id }) {
                    store.reminders[index] = updated
                    reminder = updated
                }
            }
        }
        .onAppear(perform: loadPhotosAndCalendarEvents)
        .onChange(of: calendarPrefs.enabledCalendarIDs, perform: { _ in
            loadPhotosAndCalendarEvents()
        })
    }

    private func loadPhotosAndCalendarEvents() {
        guard let reflectionDate = reminder.reflectionDate else { return }

        // Load photos
        PhotoFetcher.fetchPhotos(from: reflectionDate) { images in
            reflectionPhotos = images
        }

        let eventStore = EKEventStore()
        let allCalendars = eventStore.calendars(for: .event)

        // Save calendar states
        calendarStatuses = allCalendars.map {
            CalendarStatus(
                id: $0.calendarIdentifier,
                title: $0.title,
                isEnabled: calendarPrefs.enabledCalendarIDs.contains($0.calendarIdentifier)
            )
        }

        // Filter enabled
        let enabledCalendars = allCalendars.filter {
            calendarPrefs.enabledCalendarIDs.contains($0.calendarIdentifier)
        }

        guard !enabledCalendars.isEmpty else {
            calendarEvents = []
            return
        }

        let startOfDay = Calendar.current.startOfDay(for: reflectionDate)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!

        let predicate = eventStore.predicateForEvents(withStart: startOfDay, end: endOfDay, calendars: enabledCalendars)
        let events = eventStore.events(matching: predicate)
        calendarEvents = events.map { CalendarEventViewModel(event: $0) }
    }
}
