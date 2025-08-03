//
//  NewsService.swift
//  DaysToGo
//
//  Created by Claude on 08/11/2025.
//

import Foundation
import DaysToGoKit
import NaturalLanguage

/// Service for fetching news headlines using NewsAPI.org
class NewsService: NewsFetching {
    private let apiKey: String?
    private let baseURL = "https://newsapi.org/v2/everything"

    /// Initializes the news service.
    /// Reads API key from UserDefaults or Config.plist if available.
    init() {
        // Try to read API key from UserDefaults first (user-configurable)
        if let storedKey = UserDefaults.standard.string(forKey: "NewsAPIKey"), !storedKey.isEmpty {
            self.apiKey = storedKey
        } else if let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
                  let config = NSDictionary(contentsOfFile: path),
                  let key = config["NewsAPIKey"] as? String, !key.isEmpty {
            // Fallback to Config.plist
            self.apiKey = key
        } else {
            self.apiKey = nil
            AppLogger.general.warning("NewsAPI key not configured. News headlines will not be available.")
        }
    }

    func fetchHeadlines(from date: Date, maxCount: Int = 5) async throws -> [NewsHeadline] {
        guard let apiKey = apiKey else {
            throw AppError.underlying(NSError(
                domain: "NewsService",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "News API key not configured"]
            ))
        }

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            throw AppError.dataCorruption
        }

        let dateFormatter = ISO8601DateFormatter()
        let fromDate = dateFormatter.string(from: startOfDay)
        let toDate = dateFormatter.string(from: endOfDay)

        var components = URLComponents(string: baseURL)
        components?.queryItems = [
            URLQueryItem(name: "q", value: "news OR world OR breaking"),  // Required by NewsAPI
            URLQueryItem(name: "from", value: fromDate),
            URLQueryItem(name: "to", value: toDate),
            URLQueryItem(name: "sortBy", value: "popularity"),
            URLQueryItem(name: "pageSize", value: String(maxCount)),
            URLQueryItem(name: "language", value: "en"),
            URLQueryItem(name: "apiKey", value: apiKey)
        ]

        guard let url = components?.url else {
            throw AppError.underlying(NSError(
                domain: "NewsService",
                code: 2,
                userInfo: [NSLocalizedDescriptionKey: "Invalid URL"]
            ))
        }

        AppLogger.general.info("Fetching news headlines from: \(fromDate)")
        AppLogger.general.info("NewsAPI URL: \(url.absoluteString)")

        let (data, response): (Data, URLResponse)
        do {
            (data, response) = try await URLSession.shared.data(from: url)
        } catch {
            AppLogger.general.error("URLSession error: \(error.localizedDescription)")
            AppLogger.general.error("Error details: \(String(describing: error))")
            throw AppError.underlying(error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            AppLogger.general.error("Failed to get HTTP response")
            throw AppError.networkUnavailable
        }

        AppLogger.general.info("NewsAPI HTTP Status: \(httpResponse.statusCode)")

        guard httpResponse.statusCode == 200 else {
            // Log the response body for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                AppLogger.general.error("NewsAPI Error Response: \(responseString)")
            }

            if httpResponse.statusCode == 401 {
                throw AppError.underlying(NSError(
                    domain: "NewsService",
                    code: 401,
                    userInfo: [NSLocalizedDescriptionKey: "Invalid API key"]
                ))
            } else if httpResponse.statusCode == 426 {
                throw AppError.underlying(NSError(
                    domain: "NewsService",
                    code: 426,
                    userInfo: [NSLocalizedDescriptionKey: "NewsAPI requires HTTPS upgrade"]
                ))
            } else if httpResponse.statusCode == 429 {
                throw AppError.underlying(NSError(
                    domain: "NewsService",
                    code: 429,
                    userInfo: [NSLocalizedDescriptionKey: "API rate limit exceeded"]
                ))
            } else if httpResponse.statusCode >= 500 {
                throw AppError.underlying(NSError(
                    domain: "NewsService",
                    code: httpResponse.statusCode,
                    userInfo: [NSLocalizedDescriptionKey: "NewsAPI server error (\(httpResponse.statusCode))"]
                ))
            }

            throw AppError.underlying(NSError(
                domain: "NewsService",
                code: httpResponse.statusCode,
                userInfo: [NSLocalizedDescriptionKey: "NewsAPI returned status code: \(httpResponse.statusCode)"]
            ))
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let apiResponse = try decoder.decode(NewsAPIResponse.self, from: data)

        guard apiResponse.status == "ok" else {
            throw AppError.underlying(NSError(
                domain: "NewsService",
                code: 3,
                userInfo: [NSLocalizedDescriptionKey: apiResponse.message ?? "Unknown error"]
            ))
        }

        let headlines = apiResponse.articles.map { article in
            NewsHeadline(
                title: article.title,
                description: article.description,
                source: article.source.name,
                publishedAt: article.publishedAt,
                url: article.url,
                imageUrl: article.urlToImage
            )
        }

        AppLogger.general.info("Fetched \(headlines.count) news headlines")

        return headlines
    }

    func enhanceWithAI(_ headlines: [NewsHeadline]) async -> [NewsHeadline] {
        // Check if Apple Intelligence is available (iOS 18+)
        guard #available(iOS 18.0, *) else {
            AppLogger.general.info("Apple Intelligence not available on this OS version")
            return headlines
        }

        // Enhance headlines with AI summaries
        var enhanced = [NewsHeadline]()

        for headline in headlines {
            // Use NaturalLanguage framework to generate summaries
            if let summary = generateSummary(for: headline) {
                var enhancedHeadline = headline
                enhancedHeadline.aiSummary = summary
                enhanced.append(enhancedHeadline)
                AppLogger.general.info("Enhanced headline with AI summary: \(headline.title)")
            } else {
                enhanced.append(headline)
            }
        }

        return enhanced
    }

    /// Generates an AI summary for a headline using NaturalLanguage framework
    @available(iOS 18.0, *)
    private func generateSummary(for headline: NewsHeadline) -> String? {
        // Combine title and description for better context
        let fullText = [headline.title, headline.description].compactMap { $0 }.joined(separator: ". ")

        guard !fullText.isEmpty else { return nil }

        // Use NLTagger for extractive summarization
        let tagger = NLTagger(tagSchemes: [.lemma, .nameType])
        tagger.string = fullText

        // Extract key sentences (simple extractive summarization)
        // For a production app, you'd want to use more sophisticated AI summarization
        // This is a simplified version using the NaturalLanguage framework

        let sentences = fullText.components(separatedBy: ". ")
        if let firstSentence = sentences.first, sentences.count > 1 {
            // Return first sentence as summary if there's more than one sentence
            return firstSentence + "..."
        }

        return nil
    }
}

// MARK: - NewsAPI Response Models

private struct NewsAPIResponse: Codable {
    let status: String
    let totalResults: Int?
    let articles: [NewsAPIArticle]
    let code: String?
    let message: String?
}

private struct NewsAPIArticle: Codable {
    let source: NewsAPISource
    let title: String
    let description: String?
    let url: URL?
    let urlToImage: URL?
    let publishedAt: Date
}

private struct NewsAPISource: Codable {
    let name: String
}
