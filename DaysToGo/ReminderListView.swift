import SwiftUI
import DaysToGoKit

struct ReminderListView: View {
    @EnvironmentObject var calendarPrefs: CalendarPreferences
    @EnvironmentObject var displayPrefs: ReminderDisplayPreferences

    @StateObject private var viewModel: ReminderListViewModel
    private let reminderStore: ReminderStore

    @State private var showingAddReminder = false
    @State private var showingSettings = false
    @State private var didAnimate = false

    init(reminderStore: ReminderStore) {
        self.reminderStore = reminderStore
        _viewModel = StateObject(wrappedValue: ReminderListViewModel(reminderStore: reminderStore))
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                VStack(alignment: .leading, spacing: 0) {
                    // Segmented Control
                    Picker("View Mode", selection: $viewModel.selectedView) {
                        Text("Reminders").tag(ReminderListViewModel.ReminderViewMode.reminders)
                        Text("History").tag(ReminderListViewModel.ReminderViewMode.history)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .padding(.top, 16)
                    .padding(.bottom, 12)

                    if viewModel.displayedReminders.isEmpty {
                        Spacer()
                        VStack(spacing: 16) {
                            Image(systemName: viewModel.selectedView == .reminders ? "calendar.badge.exclamationmark" : "clock.arrow.circlepath")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            Text(viewModel.selectedView == .reminders ? "No upcoming reminders" : "No past reminders")
                                .font(.title3)
                                .foregroundColor(.secondary)
                            Text(viewModel.selectedView == .reminders ? "Tap + to add a reminder" : "Past reminders will appear here")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(viewModel.displayedReminders) { reminder in
                                    NavigationLink(destination: ReminderDetailView(reminder: reminder, store: reminderStore)) {
                                        ReminderTile(reminder: reminder)
                                            .scaleEffect(didAnimate ? 1.0 : 0.95)
                                            .opacity(didAnimate ? 1.0 : 0)
                                            .animation(.easeOut(duration: 0.4), value: didAnimate)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding()
                            .id(viewModel.lastRefreshDate)
                        }
                        .refreshable {
                            await viewModel.refresh()
                        }
                    }
                }
            }
            .toolbar {
                // ⚙️ Settings Button (left)
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showingSettings = true
                    }) {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityLabel("Settings")
                }

                // ➕ Add Reminder (right)
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddReminder = true
                    }) {
                        Label("Add Reminder", systemImage: "plus")
                    }
                    .accessibilityLabel("Add new reminder")
                }
            }
            .sheet(isPresented: $showingAddReminder) {
                AddReminderView { newReminder in
                    viewModel.addReminder(newReminder)
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView(calendarPrefs: calendarPrefs, displayPrefs: displayPrefs)
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + AnimationTiming.listAnimationDelay) {
                    didAnimate = true
                }
                // Trigger a refresh to update daysRemaining calculations
                viewModel.lastRefreshDate = Date()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                // Update when app comes from background to refresh daysRemaining
                viewModel.lastRefreshDate = Date()
            }
        }
    }
}
