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
    @State private var name: String = ""
    @State private var location: String = ""
    @State private var hasChanges = false

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
                    TextField("Name", text: $name)
                        .onChange(of: name) { _ in
                            hasChanges = true
                        }
                }

                HStack {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(.accentColor)
                        .frame(width: 28)
                    TextField("Location", text: $location)
                        .onChange(of: location) { _ in
                            hasChanges = true
                        }
                }
            } header: {
                Text("Personal Information")
            } footer: {
                Text("Your name and location help personalize your experience")
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
        name = profileStore.profile.name
        location = profileStore.profile.location
        hasChanges = false
    }

    private func saveProfile() {
        profileStore.updateProfile(name: name, location: location)
        hasChanges = false
    }
}
