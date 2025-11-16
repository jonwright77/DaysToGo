//
//  LocationMapView.swift
//  DaysToGo
//
//  Created by Claude on 09/11/2025.
//

import SwiftUI
import MapKit
import DaysToGoKit

struct LocationMapView: View {
    let locationPoints: [LocationPoint]

    @State private var region: MKCoordinateRegion

    init(locationPoints: [LocationPoint]) {
        self.locationPoints = locationPoints

        // Calculate initial region to show all points
        if let firstPoint = locationPoints.first {
            let coordinates = locationPoints.map { $0.coordinate }
            let latitudes = coordinates.map { $0.latitude }
            let longitudes = coordinates.map { $0.longitude }

            let minLat = latitudes.min() ?? firstPoint.latitude
            let maxLat = latitudes.max() ?? firstPoint.latitude
            let minLon = longitudes.min() ?? firstPoint.longitude
            let maxLon = longitudes.max() ?? firstPoint.longitude

            let center = CLLocationCoordinate2D(
                latitude: (minLat + maxLat) / 2,
                longitude: (minLon + maxLon) / 2
            )

            let span = MKCoordinateSpan(
                latitudeDelta: max(0.01, (maxLat - minLat) * 1.5),
                longitudeDelta: max(0.01, (maxLon - minLon) * 1.5)
            )

            _region = State(initialValue: MKCoordinateRegion(center: center, span: span))
        } else {
            // Default region
            _region = State(initialValue: MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            ))
        }
    }

    var body: some View {
        Map(coordinateRegion: $region, annotationItems: locationPoints) { point in
            MapMarker(coordinate: point.coordinate, tint: .accentColor)
        }
        .overlay(
            // Show path if there are multiple points
            locationPoints.count > 1 ? AnyView(pathOverlay) : AnyView(EmptyView())
        )
    }

    private var pathOverlay: some View {
        GeometryReader { geometry in
            Path { path in
                let sortedPoints = locationPoints.sorted { $0.timestamp < $1.timestamp }
                for (index, point) in sortedPoints.enumerated() {
                    let screenPoint = convertToScreenPoint(point.coordinate, in: geometry.size)
                    if index == 0 {
                        path.move(to: screenPoint)
                    } else {
                        path.addLine(to: screenPoint)
                    }
                }
            }
            .stroke(Color.accentColor.opacity(0.6), lineWidth: 2)
        }
    }

    private func convertToScreenPoint(_ coordinate: CLLocationCoordinate2D, in size: CGSize) -> CGPoint {
        let x = (coordinate.longitude - region.center.longitude + region.span.longitudeDelta / 2) / region.span.longitudeDelta * size.width
        let y = (region.center.latitude - coordinate.latitude + region.span.latitudeDelta / 2) / region.span.latitudeDelta * size.height
        return CGPoint(x: x, y: y)
    }
}
