//
//  Reminder.swift
//  DaysToGoKit
//
//  Created by Gemini on 02/11/2025.
//

import Foundation
import CloudKit
import Combine

// MARK: - Reminder Model

public struct Reminder: Identifiable, Hashable, Codable {

    enum RecordType: String { case reminder = "Reminder" }
    public static let recordType = RecordType.reminder.rawValue

    public let id: UUID
    public var recordID: CKRecord.ID?
    public var title: String
    public var date: Date
    public var description: String?
    public var backgroundColor: String?
    public var modifiedAt: Date

    public init(id: UUID = UUID(), recordID: CKRecord.ID? = nil, title: String, date: Date, description: String? = nil, backgroundColor: String? = nil, modifiedAt: Date = Date()) {
        self.id = id
        self.recordID = recordID
        self.title = title
        self.date = date
        self.description = description
        self.backgroundColor = backgroundColor
        self.modifiedAt = modifiedAt
    }
    
    public var daysRemaining: Int {
        let start = Calendar.current.startOfDay(for: Date())
        let end = Calendar.current.startOfDay(for: date)
        return Calendar.current.dateComponents([.day], from: start, to: end).day ?? 0
    }
    
    enum CodingKeys: String, CodingKey {
        case id, title, date, description, backgroundColor, modifiedAt
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        date = try container.decode(Date.self, forKey: .date)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        backgroundColor = try container.decodeIfPresent(String.self, forKey: .backgroundColor)
        modifiedAt = try container.decodeIfPresent(Date.self, forKey: .modifiedAt) ?? Date()
        recordID = nil // recordID is not saved locally
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(date, forKey: .date)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(backgroundColor, forKey: .backgroundColor)
        try container.encode(modifiedAt, forKey: .modifiedAt)
    }
    
    public init?(from record: CKRecord) {
        guard let title = record["title"] as? String,
              let date = record["date"] as? Date else {
            return nil
        }

        self.init(id: UUID(uuidString: record.recordID.recordName) ?? UUID(),
                  recordID: record.recordID,
                  title: title,
                  date: date,
                  description: record["description"] as? String,
                  backgroundColor: record["backgroundColor"] as? String,
                  modifiedAt: record["modifiedAt"] as? Date ?? Date())
    }

    public var record: CKRecord {
        let record: CKRecord
        if let recordID = recordID {
            record = CKRecord(recordType: Self.recordType, recordID: recordID)
        } else {
            record = CKRecord(recordType: Self.recordType, recordID: CKRecord.ID(recordName: id.uuidString, zoneID: .default))
        }
        record["title"] = title
        record["date"] = date
        record["description"] = description
        record["backgroundColor"] = backgroundColor
        record["modifiedAt"] = modifiedAt
        return record
    }
}

extension Reminder {
    public var reflectionDate: Date? {
        let days = daysRemaining
        let today = Calendar.current.startOfDay(for: Date())
        return Calendar.current.date(byAdding: .day, value: -days, to: today)
    }
}
