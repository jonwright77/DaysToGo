import SwiftUI
import DaysToGoKit

struct SettingsView: View {
    @ObservedObject var calendarPrefs: CalendarPreferences
    @ObservedObject var displayPrefs: ReminderDisplayPreferences
    @EnvironmentObject var profileStore: UserProfileStore
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    NavigationLink(destination: ProfileSettingsView(profileStore: profileStore)) {
                        HStack {
                            Image(systemName: "person.fill")
                                .foregroundColor(.accentColor)
                                .frame(width: 28)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Profile")
                                if !profileStore.profile.fullName.isEmpty {
                                    Text(profileStore.profile.fullName)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                } header: {
                    Text("Personal")
                }

                Section {
                    NavigationLink(destination: ReminderDisplaySettingsView(displayPrefs: displayPrefs)) {
                        HStack {
                            Image(systemName: "eye")
                                .foregroundColor(.accentColor)
                                .frame(width: 28)
                            Text("Display Options")
                        }
                    }

                    NavigationLink(destination: CalendarSettingsView(calendarPrefs: calendarPrefs)) {
                        HStack {
                            Image(systemName: "calendar")
                                .foregroundColor(.accentColor)
                                .frame(width: 28)
                            Text("Calendars")
                        }
                    }
                } header: {
                    Text("Data Sources")
                }

                Section {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.accentColor)
                            .frame(width: 28)
                        Text("Version")
                        Spacer()
                        Text(appVersion)
                            .foregroundColor(.secondary)
                    }
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
        return "\(version) (\(build))"
    }
}
