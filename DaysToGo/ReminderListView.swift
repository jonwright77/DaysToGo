import SwiftUI
import DaysToGoKit

struct ReminderListView: View {
    @EnvironmentObject var calendarPrefs: CalendarPreferences
    
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

                VStack(alignment: .leading, spacing: 16) {
                    Text("Your Reminders")
                        .font(.largeTitle)
                        .bold()
                        .padding(.horizontal)

                    if viewModel.reminders.isEmpty {
                        Spacer()
                        VStack(spacing: 16) {
                            Image(systemName: "calendar.badge.exclamationmark")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            Text("No reminders yet")
                                .font(.title3)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(viewModel.reminders.sorted(by: { $0.date < $1.date })) { reminder in
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
                SettingsView(calendarPrefs: calendarPrefs)
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + AnimationTiming.listAnimationDelay) {
                    didAnimate = true
                }
            }
        }
    }
}
