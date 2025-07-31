//
//  ReminderDetailView.swift
//  DaysToGo
//
//  Created by Jon Wright on 23/07/2025.
//

import SwiftUI
import Photos
import EventKit

// MARK: - Lightweight ViewModel to avoid duplication issues
struct CalendarEventViewModel: Identifiable, Hashable {
    let id: String
    let title: String
    let time: String

    init(event: EKEvent) {
        self.id = event.eventIdentifier
        self.title = event.title
        self.time = event.startDate.formatted(date: .omitted, time: .shortened)
    }
}

struct ReminderDetailView: View {
    @Environment(\.dismiss) var dismiss
    @State var reminder: Reminder
    @ObservedObject var store: ReminderStore
    @State private var showingEdit = false

    @State private var reflectionPhotos: [UIImage] = []
    @State private var calendarEvents: [CalendarEventViewModel] = []
    @State private var didAnimate: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 🔹 Title Header
                Text(reminder.title)
                    .font(.title)
                    .bold()

                // ✅ Section 1: Days Left Summary
                VStack(alignment: .leading, spacing: 8) {
                    Text("Summary")
                        .font(.headline)
                        .padding(.bottom, 2)

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
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
                .opacity(didAnimate ? 1 : 0)
                .offset(y: didAnimate ? 0 : 20)
                .animation(.easeOut(duration: 0.4).delay(0.1), value: didAnimate)

                // 🖼️ Section 2: Photos
                VStack(alignment: .leading, spacing: 8) {
                    Text("Photos")
                        .font(.headline)

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
                    } else if let reflectionDate = reminder.reflectionDate {
                        Text("No Photos on \(reflectionDate.formatted(date: .long, time: .omitted))")
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
                .opacity(didAnimate ? 1 : 0)
                .offset(y: didAnimate ? 0 : 20)
                .animation(.easeOut(duration: 0.4).delay(0.3), value: didAnimate)

                // 📅 Section 3: Calendar Events
                VStack(alignment: .leading, spacing: 8) {
                    Text("Calendar Events")
                        .font(.headline)

                    if !calendarEvents.isEmpty {
                        ForEach(calendarEvents) { event in
                            VStack(alignment: .leading, spacing: 4) {
                                Text(event.title)
                                    .font(.headline)
                                Text(event.time)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(8)
                            .background(Color(.systemGray5))
                            .cornerRadius(8)
                        }
                    } else if let reflectionDate = reminder.reflectionDate {
                        Text("No Calendar Events for \(reflectionDate.formatted(date: .long, time: .omitted))")
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.systemGray6)))
                .opacity(didAnimate ? 1 : 0)
                .offset(y: didAnimate ? 0 : 20)
                .animation(.easeOut(duration: 0.4).delay(0.5), value: didAnimate)

                Spacer()

                // ✏️ Edit / Delete Buttons
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
        .onAppear {
            if let reflectionDate = reminder.reflectionDate {
                PhotoFetcher.fetchPhotos(from: reflectionDate) { images in
                    self.reflectionPhotos = images
                }

                fetchCalendarEvents(on: reflectionDate) { eventVMs in
                    self.calendarEvents = eventVMs
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation {
                    didAnimate = true
                }
            }
        }
    }

    // MARK: - Fetch Calendar Events
    private func fetchCalendarEvents(on date: Date, completion: @escaping ([CalendarEventViewModel]) -> Void) {
        let store = EKEventStore()
        store.requestAccess(to: .event) { granted, error in
            guard granted, error == nil else {
                completion([])
                return
            }

            let startOfDay = Calendar.current.startOfDay(for: date)
            let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!

            let predicate = store.predicateForEvents(withStart: startOfDay, end: endOfDay, calendars: nil)
            let events = store.events(matching: predicate)

            let viewModels = events.map { CalendarEventViewModel(event: $0) }
            completion(viewModels)
        }
    }
}
