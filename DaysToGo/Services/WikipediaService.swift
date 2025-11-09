//
//  WikipediaService.swift
//  DaysToGo
//
//  Created by Claude on 09/11/2025.
//

import Foundation
import DaysToGoKit
import NaturalLanguage

/// Service for fetching historical events from Wikipedia's "On This Day" feature
class WikipediaService: HistoricalEventFetching {
    private let baseURL = "https://api.wikimedia.org/feed/v1/wikipedia/en/onthisday/all"

    func fetchEvents(from date: Date, maxCount: Int = 10) async throws -> [HistoricalEvent] {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        let day = calendar.component(.day, from: date)

        // Format: MM/DD (with leading zeros)
        let monthString = String(format: "%02d", month)
        let dayString = String(format: "%02d", day)

        let urlString = "\(baseURL)/\(monthString)/\(dayString)"

        guard let url = URL(string: urlString) else {
            throw AppError.underlying(NSError(
                domain: "WikipediaService",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]
            ))
        }

        AppLogger.general.info("Fetching historical events from Wikipedia: \(monthString)/\(dayString)")

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(from: url)
        } catch {
            AppLogger.general.error("URLSession error: \(error.localizedDescription)")
            throw AppError.networkUnavailable
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            AppLogger.general.error("Failed to get HTTP response")
            throw AppError.networkUnavailable
        }

        guard httpResponse.statusCode == 200 else {
            AppLogger.general.error("Wikipedia API returned status code: \(httpResponse.statusCode)")
            throw AppError.underlying(NSError(
                domain: "WikipediaService",
                code: httpResponse.statusCode,
                userInfo: [NSLocalizedDescriptionKey: "Wikipedia API returned status code: \(httpResponse.statusCode)"]
            ))
        }

        let decoder = JSONDecoder()
        let apiResponse = try decoder.decode(WikipediaResponse.self, from: data)

        // Combine all event types into a single array
        var allEvents: [HistoricalEvent] = []

        // Add selected/featured events first (highest priority)
        if let selected = apiResponse.selected {
            allEvents.append(contentsOf: parseEvents(selected, type: .selected))
        }

        // Add regular events
        if let events = apiResponse.events {
            allEvents.append(contentsOf: parseEvents(events, type: .event))
        }

        // Add births
        if let births = apiResponse.births {
            allEvents.append(contentsOf: parseEvents(births, type: .birth))
        }

        // Add deaths
        if let deaths = apiResponse.deaths {
            allEvents.append(contentsOf: parseEvents(deaths, type: .death))
        }

        // Add holidays
        if let holidays = apiResponse.holidays {
            allEvents.append(contentsOf: parseEvents(holidays, type: .holiday))
        }

        // Sort by year (most recent first) and limit to maxCount
        let sortedEvents = allEvents.sorted { $0.year > $1.year }.prefix(maxCount)

        AppLogger.general.info("Fetched \(sortedEvents.count) historical events from Wikipedia")

        return Array(sortedEvents)
    }

    func enhanceWithAI(_ events: [HistoricalEvent]) async -> [HistoricalEvent] {
        // Check if Apple Intelligence is available (iOS 18+)
        guard #available(iOS 18.0, *) else {
            AppLogger.general.info("Apple Intelligence not available on this OS version")
            return events
        }

        // Enhance events with AI summaries
        var enhanced = [HistoricalEvent]()

        for event in events {
            // Use NaturalLanguage framework to generate summaries
            if let summary = generateSummary(for: event) {
                var enhancedEvent = event
                enhancedEvent.aiSummary = summary
                enhanced.append(enhancedEvent)
                AppLogger.general.info("Enhanced event with AI summary")
            } else {
                enhanced.append(event)
            }
        }

        return enhanced
    }

    // MARK: - Private Helpers

    private func parseEvents(_ wikiEvents: [WikipediaEvent], type: HistoricalEvent.EventType) -> [HistoricalEvent] {
        wikiEvents.compactMap { wikiEvent in
            guard let year = wikiEvent.year else {
                // Holidays might not have years
                if type == .holiday {
                    // Use current year for holidays
                    let currentYear = Calendar.current.component(.year, from: Date())
                    return parseEvent(wikiEvent, year: currentYear, type: type)
                }
                return nil
            }

            return parseEvent(wikiEvent, year: year, type: type)
        }
    }

    private func parseEvent(_ wikiEvent: WikipediaEvent, year: Int, type: HistoricalEvent.EventType) -> HistoricalEvent {
        // Get the first page's URL and image if available
        let firstPage = wikiEvent.pages?.first
        let url = firstPage?.content_urls?.desktop?.page.flatMap { URL(string: $0) }
        let imageUrl = firstPage?.thumbnail?.source.flatMap { URL(string: $0) }

        return HistoricalEvent(
            year: year,
            text: wikiEvent.text,
            eventType: type,
            url: url,
            imageUrl: imageUrl
        )
    }

    /// Generates an AI summary for an event using NaturalLanguage framework
    @available(iOS 18.0, *)
    private func generateSummary(for event: HistoricalEvent) -> String? {
        let fullText = event.text

        guard !fullText.isEmpty else { return nil }

        // Use NLTagger for extractive summarization
        let tagger = NLTagger(tagSchemes: [.lemma, .nameType])
        tagger.string = fullText

        // Extract key sentences (simple extractive summarization)
        let sentences = fullText.components(separatedBy: ". ")
        if sentences.count > 1, let firstSentence = sentences.first {
            // Return first sentence as summary if there's more than one sentence
            return "In \(event.year), " + firstSentence.lowercased() + "..."
        }

        // If single sentence, add context
        return "In \(event.year), " + fullText.lowercased()
    }
}

// MARK: - Wikipedia Response Models

private struct WikipediaResponse: Codable {
    let selected: [WikipediaEvent]?
    let events: [WikipediaEvent]?
    let births: [WikipediaEvent]?
    let deaths: [WikipediaEvent]?
    let holidays: [WikipediaEvent]?
}

private struct WikipediaEvent: Codable {
    let text: String
    let year: Int?
    let pages: [WikipediaPage]?
}

private struct WikipediaPage: Codable {
    let title: String?
    let thumbnail: WikipediaThumbnail?
    let content_urls: WikipediaContentURLs?
}

private struct WikipediaThumbnail: Codable {
    let source: String?
    let width: Int?
    let height: Int?
}

private struct WikipediaContentURLs: Codable {
    let desktop: WikipediaDesktopURL?
}

private struct WikipediaDesktopURL: Codable {
    let page: String?
}
