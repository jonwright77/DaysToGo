//
//  NewsHeadline.swift
//  DaysToGoKit
//
//  Created by Claude on 08/11/2025.
//

import Foundation

// MARK: - NewsHeadline Model

/// Represents a news headline from a specific date
public struct NewsHeadline: Identifiable, Hashable, Codable {
    public let id: UUID
    public let title: String
    public let description: String?
    public let source: String
    public let publishedAt: Date
    public let url: URL?
    public let imageUrl: URL?

    /// AI-generated summary (iOS 18+ only)
    public var aiSummary: String?

    public init(
        id: UUID = UUID(),
        title: String,
        description: String?,
        source: String,
        publishedAt: Date,
        url: URL?,
        imageUrl: URL? = nil,
        aiSummary: String? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.source = source
        self.publishedAt = publishedAt
        self.url = url
        self.imageUrl = imageUrl
        self.aiSummary = aiSummary
    }

    enum CodingKeys: String, CodingKey {
        case id, title, description, source, publishedAt, url, imageUrl, aiSummary
    }
}
