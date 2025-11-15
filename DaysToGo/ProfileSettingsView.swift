//
//  ProfileSettingsView.swift
//  DaysToGo
//
//  Created by Claude on 09/11/2025.
//

import SwiftUI
import DaysToGoKit

struct ProfileSettingsView: View {
    @ObservedObject var profileStore: UserProfileStore
    @State private var firstName: String = ""
    @State private var surname: String = ""
    @State private var country: String = ""
    @State private var hasChanges = false

    // List of countries
    private let countries = [
        "United States", "United Kingdom", "Canada", "Australia", "Germany",
        "France", "Italy", "Spain", "Netherlands", "Belgium", "Switzerland",
        "Sweden", "Norway", "Denmark", "Finland", "Ireland", "Austria",
        "Portugal", "Greece", "Poland", "Czech Republic", "Hungary",
        "Japan", "China", "South Korea", "India", "Singapore", "Thailand",
        "Brazil", "Mexico", "Argentina", "Chile", "New Zealand",
        "South Africa", "Israel", "Turkey", "United Arab Emirates",
        "Saudi Arabia", "Egypt", "Nigeria", "Kenya", "Other"
    ].sorted()

    var body: some View {
        Form {
            Section {
                HStack {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.accentColor)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
            }

            Section {
                HStack {
                    Image(systemName: "person.fill")
                        .foregroundColor(.accentColor)
                        .frame(width: 28)
                    TextField("First Name", text: $firstName)
                        .onChange(of: firstName) { _ in
                            hasChanges = true
                        }
                }

                HStack {
                    Image(systemName: "person.fill")
                        .foregroundColor(.accentColor)
                        .frame(width: 28)
                    TextField("Surname", text: $surname)
                        .onChange(of: surname) { _ in
                            hasChanges = true
                        }
                }

                Picker("Country", selection: $country) {
                    Text("Select a country").tag("")
                    ForEach(countries, id: \.self) { country in
                        Text(country).tag(country)
                    }
                }
                .onChange(of: country) { _ in
                    hasChanges = true
                }
            } header: {
                Text("Personal Information")
            } footer: {
                Text("Your name and country help personalize your experience")
            }

            if hasChanges {
                Section {
                    Button(action: saveProfile) {
                        HStack {
                            Spacer()
                            Text("Save Changes")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                }
            }
        }
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadProfile()
        }
    }

    private func loadProfile() {
        firstName = profileStore.profile.firstName
        surname = profileStore.profile.surname
        country = profileStore.profile.country
        hasChanges = false
    }

    private func saveProfile() {
        profileStore.updateProfile(firstName: firstName, surname: surname, country: country)
        hasChanges = false
    }
}
