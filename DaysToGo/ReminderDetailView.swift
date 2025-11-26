import SwiftUI
import Photos
import EventKit
import MapKit
import DaysToGoKit

struct ReminderDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var calendarPrefs: CalendarPreferences
    @EnvironmentObject var displayPrefs: ReminderDisplayPreferences

    @StateObject private var viewModel: ReminderDetailViewModel

    @State private var showingEdit = false
    @State private var selectedImage: UIImage?

    init(reminder: Reminder, store: ReminderStore) {
        _viewModel = StateObject(wrappedValue: ReminderDetailViewModel(reminder: reminder, reminderStore: store))
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Text(viewModel.reminder.title)
                    .font(.title)
                    .bold()

                if let reflectionDate = viewModel.reminder.reflectionDate {
                    HStack {
                        Text(reflectionDate.formatted(date: .long, time: .omitted))
                        Spacer()
                        Text("\(viewModel.reminder.daysRemaining) Day\(viewModel.reminder.daysRemaining == 1 ? "" : "s")")
                            .fontWeight(.medium)
                        Spacer()
                        Text(viewModel.reminder.date.formatted(date: .long, time: .omitted))
                    }
                    .font(.body)
                    .padding(.horizontal)
                }

                Divider()

                if let description = viewModel.reminder.description, !description.isEmpty {
                    VStack(alignment: .leading) {
                        Text("Description")
                            .font(.headline)
                        Text(description)
                            .font(.body)
                    }
                    .padding(.horizontal)
                }

                // Photos Section
                if displayPrefs.showPhotos {
                    Divider()

                    if viewModel.isLoadingPhotos {
                        ProgressView()
                            .padding()
                    } else if !viewModel.reflectionPhotos.isEmpty {
                        LazyVGrid(columns: [GridItem(), GridItem()], spacing: 8) {
                            ForEach(viewModel.reflectionPhotos, id: \.self) { image in
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 160, height: 160)
                                    .clipped()
                                    .cornerRadius(8)
                                    .onTapGesture {
                                        selectedImage = image
                                    }
                                    .accessibilityElement(children: .ignore)
                                    .accessibilityLabel("Reflection photo")
                            }
                        }
                        .padding(.top)
                    } else if let reflectionDate = viewModel.reminder.reflectionDate {
                        VStack {
                            Image(systemName: "photo.on.rectangle.angled")
                                .font(.largeTitle)
                                .foregroundColor(.secondary)
                            Text("No Photos on \(reflectionDate.formatted(date: .long, time: .omitted))")
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    }

                    Divider()
                }

                // Calendar Events Section
                if displayPrefs.showCalendar {
                    if viewModel.isLoadingEvents {
                        ProgressView()
                            .padding()
                    } else if !viewModel.calendarEvents.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(viewModel.calendarEvents) { event in
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
                                .accessibilityElement(children: .combine)
                                .accessibilityLabel("\(event.title) at \(event.time) from \(event.calendarName) calendar")
                            }
                        }
                        .padding(.horizontal)
                    } else if let reflectionDate = viewModel.reminder.reflectionDate {
                        VStack {
                            Image(systemName: "calendar.badge.exclamationmark")
                                .font(.largeTitle)
                                .foregroundColor(.secondary)
                            Text("No Calendar Events for \(reflectionDate.formatted(date: .long, time: .omitted))")
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    }

                    Divider()
                }

                // Historical Events Section
                if displayPrefs.showOnThisDay {
                    if viewModel.isLoadingHistory {
                        ProgressView()
                            .padding()
                    } else if !viewModel.historicalEvents.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("📅 On This Day in History")
                                .font(.headline)
                                .padding(.horizontal)

                            ForEach(viewModel.historicalEvents) { event in
                                VStack(alignment: .leading, spacing: 6) {
                                    HStack {
                                        Text(String(event.year))
                                            .font(.title3)
                                            .fontWeight(.bold)
                                            .foregroundColor(.accentColor)

                                        Image(systemName: event.eventType.icon)
                                            .foregroundColor(.secondary)
                                            .font(.caption)
                                    }

                                    Text(event.text)
                                        .font(.subheadline)

                                    // Show AI summary if available (iOS 18+)
                                    if let aiSummary = event.aiSummary {
                                        Text(aiSummary)
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                            .italic()
                                            .padding(.top, 2)
                                    }

                                    // Show Wikipedia link if available
                                    if let url = event.url {
                                        Link("Read on Wikipedia →", destination: url)
                                            .font(.caption)
                                            .foregroundColor(.accentColor)
                                    }
                                }
                                .padding(10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                                .accessibilityElement(children: .combine)
                                .accessibilityLabel("\(event.year): \(event.text)")
                            }
                        }
                        .padding(.horizontal)
                    } else if let reflectionDate = viewModel.reminder.reflectionDate {
                        VStack {
                            Image(systemName: "calendar.badge.clock")
                                .font(.largeTitle)
                                .foregroundColor(.secondary)
                            Text("No Historical Events for \(reflectionDate.formatted(date: .long, time: .omitted))")
                                .foregroundColor(.secondary)
                        }
                        .padding()
                    }

                    Divider()
                }

                // Location Map Section
                if displayPrefs.showLocation {
                    if viewModel.isLoadingLocations {
                        ProgressView()
                            .padding()
                    } else if !viewModel.locationPoints.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("📍 Your Movements")
                                .font(.headline)
                                .padding(.horizontal)

                            LocationMapView(locationPoints: viewModel.locationPoints)
                                .frame(height: 250)
                                .cornerRadius(12)
                                .padding(.horizontal)

                            Text("\(viewModel.locationPoints.count) location\(viewModel.locationPoints.count == 1 ? "" : "s") recorded")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                        }
                    } else if let reflectionDate = viewModel.reminder.reflectionDate {
                        VStack {
                            Image(systemName: "map")
                                .font(.largeTitle)
                                .foregroundColor(.secondary)
                            Text("No Location Data for \(reflectionDate.formatted(date: .long, time: .omitted))")
                                .foregroundColor(.secondary)
                            Text("Location tracking builds history over time")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                    }
                }

                Spacer()

                HStack(spacing: 30) {
                    Button("Edit") {
                        showingEdit = true
                    }
                    .buttonStyle(.bordered)
                    .accessibilityLabel("Edit reminder")

                    Button("Delete") {
                        viewModel.deleteReminder()
                        dismiss()
                    }
                    .foregroundColor(.red)
                    .accessibilityLabel("Delete reminder")
                }
            }
            .padding()
        }
        .navigationTitle("Reminder Details")
        .sheet(isPresented: Binding(
            get: { selectedImage != nil },
            set: { newValue in
                if !newValue {
                    selectedImage = nil
                }
            }
        )) {
            if let image = selectedImage {
                ZStack {
                    Color.black.ignoresSafeArea()
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .background(Color.black)
                        .onTapGesture {
                            selectedImage = nil
                        }
                }
            }
        }
        .sheet(isPresented: $showingEdit) {
            EditReminderView(reminder: $viewModel.reminder) { updated in
                viewModel.updateReminder(updated)
            }
        }
        .onAppear {
            viewModel.loadPhotosAndCalendarEvents(calendarPrefs: calendarPrefs)
        }
        .onChange(of: calendarPrefs.enabledCalendarIDs) {
            viewModel.loadPhotosAndCalendarEvents(calendarPrefs: calendarPrefs)
        }
        .alert(isPresented: $viewModel.alertError.isPresent, error: viewModel.alertError) { error in
            Button("OK") {
                viewModel.alertError = nil
            }
            if error.shouldShowSettingsButton {
                Button("Open Settings") {
                    viewModel.alertError = nil
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
}
