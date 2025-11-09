//
//  HistoricalEvent.swift
//  DaysToGoKit
//
//  Created by Claude on 09/11/2025.
//

import Foundation

// MARK: - HistoricalEvent Model

/// Represents a historical event from Wikipedia's "On This Day" feature
public struct HistoricalEvent: Identifiable, Hashable, Codable {
    public let id: UUID
    public let year: Int
    public let text: String
    public let eventType: EventType
    public let url: URL?
    public let imageUrl: URL?

    /// AI-generated summary (iOS 18+ only)
    public var aiSummary: String?

    public enum EventType: String, Codable, CaseIterable {
        case event = "event"
        case birth = "birth"
        case death = "death"
        case holiday = "holiday"
        case selected = "selected"  // Featured event

        public var displayName: String {
            switch self {
            case .event: return "Event"
            case .birth: return "Birth"
            case .death: return "Death"
            case .holiday: return "Holiday"
            case .selected: return "Featured"
            }
        }

        public var icon: String {
            switch self {
            case .event: return "calendar"
            case .birth: return "gift"
            case .death: return "leaf"
            case .holiday: return "star"
            case .selected: return "star.fill"
            }
        }
    }

    public init(
        id: UUID = UUID(),
        year: Int,
        text: String,
        eventType: EventType,
        url: URL?,
        imageUrl: URL? = nil,
        aiSummary: String? = nil
    ) {
        self.id = id
        self.year = year
        self.text = text
        self.eventType = eventType
        self.url = url
        self.imageUrl = imageUrl
        self.aiSummary = aiSummary
    }

    enum CodingKeys: String, CodingKey {
        case id, year, text, eventType, url, imageUrl, aiSummary
    }
}
