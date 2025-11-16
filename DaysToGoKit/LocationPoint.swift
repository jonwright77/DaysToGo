//
//  LocationPoint.swift
//  DaysToGoKit
//
//  Created by Claude on 09/11/2025.
//

import Foundation
import CoreLocation

// MARK: - LocationPoint Model

/// Represents a location point with coordinates and timestamp
public struct LocationPoint: Identifiable, Hashable, Codable {
    public let id: UUID
    public let latitude: Double
    public let longitude: Double
    public let timestamp: Date
    public let horizontalAccuracy: Double

    public init(
        id: UUID = UUID(),
        latitude: Double,
        longitude: Double,
        timestamp: Date,
        horizontalAccuracy: Double = 0
    ) {
        self.id = id
        self.latitude = latitude
        self.longitude = longitude
        self.timestamp = timestamp
        self.horizontalAccuracy = horizontalAccuracy
    }

    /// Creates a LocationPoint from a CLLocation
    public init(from location: CLLocation) {
        self.id = UUID()
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        self.timestamp = location.timestamp
        self.horizontalAccuracy = location.horizontalAccuracy
    }

    /// Returns a CLLocationCoordinate2D for use with MapKit
    public var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    /// Returns true if this location has acceptable accuracy (< 100 meters)
    public var hasGoodAccuracy: Bool {
        horizontalAccuracy >= 0 && horizontalAccuracy < 100
    }
}
