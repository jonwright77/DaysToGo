
//
//  AppServices.swift
//  DaysToGo
//
//  Created by Jon Wright on 01/11/2025.
//

import Foundation
import CloudKit

// MARK: - Error Types

/// Application-specific errors with user-friendly messages and recovery suggestions.
enum AppError: Error, LocalizedError {
    case permissionDenied(service: String)
    case networkUnavailable
    case cloudKitError(CKError)
    case dataCorruption
    case underlying(Error)

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Permission Denied"
        case .networkUnavailable:
            return "Network Unavailable"
        case .cloudKitError(let error):
            return "Sync Error: \(error.localizedDescription)"
        case .dataCorruption:
            return "Data Corruption"
        case .underlying(let error):
            return error.localizedDescription
        }
    }

    var recoverySuggestion: String? {
        switch self {
        case .permissionDenied(let service):
            return "Please grant access to \(service) in the Settings app to use this feature."
        case .networkUnavailable:
            return "Please check your internet connection and try again."
        case .cloudKitError(let error):
            if error.code == .networkUnavailable || error.code == .networkFailure {
                return "Please check your internet connection and try again."
            } else if error.code == .notAuthenticated {
                return "Please sign in to iCloud in Settings to sync your reminders."
            } else {
                return "Please try again later."
            }
        case .dataCorruption:
            return "Your data may be corrupted. Please contact support if this issue persists."
        case .underlying:
            return "Please try again."
        }
    }

    /// Whether the operation should be retried.
    var shouldRetry: Bool {
        switch self {
        case .networkUnavailable, .cloudKitError:
            return true
        case .permissionDenied, .dataCorruption, .underlying:
            return false
        }
    }

    /// Whether to show a button to open Settings.
    var shouldShowSettingsButton: Bool {
        switch self {
        case .permissionDenied:
            return true
        case .cloudKitError(let error):
            return error.code == .notAuthenticated
        case .networkUnavailable, .dataCorruption, .underlying:
            return false
        }
    }
}
