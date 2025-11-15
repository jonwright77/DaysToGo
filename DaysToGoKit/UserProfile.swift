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
    public var name: String
    public var location: String

    public init(name: String = "", location: String = "") {
        self.name = name
        self.location = location
    }

    /// Returns true if the profile is incomplete (missing required fields)
    public var isIncomplete: Bool {
        name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// Returns a display-friendly greeting based on the profile
    public var greeting: String {
        if name.isEmpty {
            return "Welcome"
        } else {
            return "Hello, \(name)"
        }
    }
}
