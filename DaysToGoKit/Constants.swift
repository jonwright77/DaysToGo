//
//  Constants.swift
//  DaysToGoKit
//
//  Created by Claude on 07/11/2025.
//

import Foundation

/// Application-wide constants shared between the main app and extensions.
public enum AppConstants {
    /// App Group identifier for shared data container.
    public static let appGroupID = "group.wright.DaysToGo"

    /// Widget kind identifier.
    public static let widgetKind = "DaysToGoWidget"

    /// Name of the JSON file storing reminders in the shared container.
    public static let remindersFileName = "reminders.json"
}

/// Notification names used throughout the application.
public extension Notification.Name {
    /// Posted when reminders data changes (add, update, delete, or sync).
    static let remindersDidChange = Notification.Name("remindersDidChange")

    /// Posted when a CloudKit remote notification is received.
    static let cloudKitNotification = Notification.Name("CloudKitNotification")
}

/// Animation and timing constants.
public enum AnimationTiming {
    /// Duration to display the splash screen (in seconds).
    public static let splashDuration: TimeInterval = 2.0

    /// Delay before animating list items (in seconds).
    public static let listAnimationDelay: TimeInterval = 0.1
}
