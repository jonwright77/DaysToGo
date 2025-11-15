//
//  UserProfile.swift
//  DaysToGoKit
//
//  Created by Claude on 09/11/2025.
//

import Foundation

// MARK: - UserProfile Model

/// Represents the user's profile information
public struct UserProfile: Codable, Equatable {
    public var firstName: String
    public var surname: String
    public var country: String

    public init(firstName: String = "", surname: String = "", country: String = "") {
        self.firstName = firstName
        self.surname = surname
        self.country = country
    }

    /// Returns the full name (first name + surname)
    public var fullName: String {
        let names = [firstName, surname].filter { !$0.isEmpty }
        return names.joined(separator: " ")
    }

    /// Returns true if the profile is incomplete (missing required fields)
    public var isIncomplete: Bool {
        firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// Returns a display-friendly greeting based on the profile
    public var greeting: String {
        if firstName.isEmpty {
            return "Welcome"
        } else {
            return "Hello, \(firstName)"
        }
    }
}
