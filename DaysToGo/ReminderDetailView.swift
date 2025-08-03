import SwiftUI
import Photos
import EventKit
import DaysToGoKit

struct ReminderDetailView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var calendarPrefs: CalendarPreferences

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

                // News Headlines Section
                if viewModel.isLoadingNews {
                    ProgressView()
                        .padding()
                } else if !viewModel.newsHeadlines.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("📰 News Headlines")
                            .font(.headline)
                            .padding(.horizontal)

                        ForEach(viewModel.newsHeadlines) { headline in
                            VStack(alignment: .leading, spacing: 6) {
                                Text(headline.title)
                                    .font(.subheadline)
                                    .fontWeight(.medium)

                                Text(headline.source)
                                    .font(.caption)
                                    .foregroundColor(.secondary)

                                // Show AI summary if available (iOS 18+)
                                if let aiSummary = headline.aiSummary {
                                    Text(aiSummary)
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                        .italic()
                                }

                                // Show link if available
                                if let url = headline.url {
                                    Link("Read more →", destination: url)
                                        .font(.caption)
                                        .foregroundColor(.accentColor)
                                }
                            }
                            .padding(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                            .cornerRadius(8)
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel("\(headline.title) from \(headline.source)")
                        }
                    }
                    .padding(.horizontal)
                } else if let reflectionDate = viewModel.reminder.reflectionDate {
                    VStack {
                        Image(systemName: "newspaper")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        Text("No News Headlines for \(reflectionDate.formatted(date: .long, time: .omitted))")
                            .foregroundColor(.secondary)
                    }
                    .padding()
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
