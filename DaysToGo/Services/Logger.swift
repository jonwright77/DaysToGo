//
//  Logger.swift
//  DaysToGo
//
//  Created by Claude on 07/11/2025.
//

import Foundation
import OSLog

/// Centralized logging system using OSLog for structured, filterable logging.
///
/// Usage:
/// ```
/// AppLogger.cloudKit.info("Fetching reminders from CloudKit")
/// AppLogger.cloudKit.error("Failed to sync: \(error.localizedDescription)")
/// ```
enum AppLogger {
    private static let subsystem = "wright.DaysToGo"

    /// Logger for CloudKit operations (sync, fetch, save, delete).
    static let cloudKit = Logger(subsystem: subsystem, category: "CloudKit")

    /// Logger for photo library operations.
    static let photos = Logger(subsystem: subsystem, category: "Photos")

    /// Logger for calendar and event operations.
    static let calendar = Logger(subsystem: subsystem, category: "Calendar")

    /// Logger for general application events.
    static let general = Logger(subsystem: subsystem, category: "General")

    /// Logger for widget-related operations.
    static let widget = Logger(subsystem: subsystem, category: "Widget")
}
