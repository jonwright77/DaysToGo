//
//  LocationService.swift
//  DaysToGo
//
//  Created by Claude on 09/11/2025.
//

import Foundation
import CoreLocation
import DaysToGoKit

/// Service for tracking and fetching location data
class LocationService: NSObject, LocationFetching {
    private let locationManager = CLLocationManager()
    private var locationPoints: [LocationPoint] = []
    private let fileURL: URL
    private var authorizationContinuation: CheckedContinuation<Void, Error>?
    private var lastRecordedDate: Date?

    override init() {
        // Set up file URL for storing locations
        guard let documentsDirectory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppConstants.appGroupID) else {
            fatalError("Could not access shared app group container")
        }
        self.fileURL = documentsDirectory.appendingPathComponent("locations.json")

        super.init()

        // Configure location manager for more frequent updates
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // Better accuracy for detailed tracking
        locationManager.distanceFilter = 20 // Update every 20 meters (more frequent)
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false // Keep tracking even when stationary

        // Load existing locations from file
        loadLocationsFromFile()

        // Set last recorded date from most recent location
        if let mostRecent = locationPoints.max(by: { $0.timestamp < $1.timestamp }) {
            lastRecordedDate = Calendar.current.startOfDay(for: mostRecent.timestamp)
        }
    }

    func requestAuthorization() async throws {
        let status = locationManager.authorizationStatus

        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            // Already authorized
            return
        case .notDetermined:
            // Request authorization
            return try await withCheckedThrowingContinuation { continuation in
                self.authorizationContinuation = continuation
                locationManager.requestAlwaysAuthorization()
            }
        case .denied, .restricted:
            throw AppError.permissionDenied(service: "Location")
        @unknown default:
            throw AppError.permissionDenied(service: "Location")
        }
    }

    func startTracking() {
        AppLogger.general.info("Starting continuous location tracking (20m distance filter)")
        locationManager.startUpdatingLocation()
    }

    func stopTracking() {
        AppLogger.general.info("Stopping continuous location tracking")
        locationManager.stopUpdatingLocation()
    }

    func fetchLocations(from date: Date, maxCount: Int = 50) async throws -> [LocationPoint] {
        // Get start and end of the day for the given date
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return []
        }

        // Filter locations for that day
        let filtered = locationPoints.filter { location in
            location.timestamp >= startOfDay && location.timestamp < endOfDay
        }

        // Sort by timestamp and limit to maxCount
        let sorted = filtered.sorted { $0.timestamp < $1.timestamp }
        return Array(sorted.prefix(maxCount))
    }

    // MARK: - Private Helpers

    private func loadLocationsFromFile() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([LocationPoint].self, from: data) else {
            AppLogger.general.info("No existing location data found")
            return
        }
        self.locationPoints = decoded
        AppLogger.general.info("Loaded \(self.locationPoints.count) location points from file")
    }

    private func saveLocationsToFile() {
        do {
            let data = try JSONEncoder().encode(self.locationPoints)
            try data.write(to: fileURL, options: .atomic)
            AppLogger.general.info("Saved \(self.locationPoints.count) location points to file")
        } catch {
            AppLogger.general.error("Error saving locations: \(error.localizedDescription)")
        }
    }

    private func addLocation(_ location: CLLocation) {
        let locationPoint = LocationPoint(from: location)
        let calendar = Calendar.current
        let currentDate = calendar.startOfDay(for: location.timestamp)

        // Check if this is the first location of a new day
        let isFirstLocationOfDay = lastRecordedDate == nil || currentDate > lastRecordedDate!

        // Always record first location of the day, regardless of accuracy
        if isFirstLocationOfDay {
            self.locationPoints.append(locationPoint)
            lastRecordedDate = currentDate
            AppLogger.general.info("Added FIRST location of day: \(locationPoint.latitude), \(locationPoint.longitude) at \(locationPoint.timestamp)")
        } else {
            // For subsequent locations, only store those with good accuracy
            guard locationPoint.hasGoodAccuracy else {
                AppLogger.general.info("Skipping location with poor accuracy: \(locationPoint.horizontalAccuracy)m")
                return
            }

            self.locationPoints.append(locationPoint)
            AppLogger.general.info("Added location: \(locationPoint.latitude), \(locationPoint.longitude) at \(locationPoint.timestamp)")
        }

        // Keep only last 90 days of data to manage storage
        let ninetyDaysAgo = calendar.date(byAdding: .day, value: -90, to: Date()) ?? Date()
        self.locationPoints = self.locationPoints.filter { $0.timestamp >= ninetyDaysAgo }

        saveLocationsToFile()
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            addLocation(location)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        AppLogger.general.error("Location manager failed: \(error.localizedDescription)")
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus

        AppLogger.general.info("Location authorization changed: \(status.rawValue)")

        // Handle pending authorization request
        if let continuation = authorizationContinuation {
            authorizationContinuation = nil

            switch status {
            case .authorizedAlways, .authorizedWhenInUse:
                continuation.resume()
            case .denied, .restricted:
                continuation.resume(throwing: AppError.permissionDenied(service: "Location"))
            case .notDetermined:
                // Still waiting, do nothing
                break
            @unknown default:
                continuation.resume(throwing: AppError.permissionDenied(service: "Location"))
            }
        }
    }
}
