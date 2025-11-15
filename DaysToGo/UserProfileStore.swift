//
//  UserProfileStore.swift
//  DaysToGo
//
//  Created by Claude on 09/11/2025.
//

import Foundation
import DaysToGoKit
import Combine

/// Manages user profile data persistence using UserDefaults
@MainActor
class UserProfileStore: ObservableObject {
    @Published var profile: UserProfile {
        didSet {
            saveProfile()
        }
    }

    private let userDefaults = UserDefaults.standard
    private let profileKey = "userProfile"
    private let hasCompletedOnboardingKey = "hasCompletedOnboarding"

    /// Shared singleton instance
    static let shared = UserProfileStore()

    init() {
        // Load profile from UserDefaults
        if let data = userDefaults.data(forKey: profileKey),
           let decoded = try? JSONDecoder().decode(UserProfile.self, from: data) {
            self.profile = decoded
        } else {
            self.profile = UserProfile()
        }
    }

    /// Saves the current profile to UserDefaults
    private func saveProfile() {
        if let encoded = try? JSONEncoder().encode(profile) {
            userDefaults.set(encoded, forKey: profileKey)
        }
    }

    /// Updates the user profile
    func updateProfile(firstName: String, surname: String, country: String) {
        profile.firstName = firstName
        profile.surname = surname
        profile.country = country
    }

    /// Checks if the user has completed onboarding
    var hasCompletedOnboarding: Bool {
        get {
            userDefaults.bool(forKey: hasCompletedOnboardingKey)
        }
        set {
            userDefaults.set(newValue, forKey: hasCompletedOnboardingKey)
        }
    }

    /// Marks onboarding as completed
    func completeOnboarding() {
        hasCompletedOnboarding = true
    }

    /// Resets onboarding status (useful for testing/debugging)
    func resetOnboarding() {
        hasCompletedOnboarding = false
        profile = UserProfile()
    }
}
