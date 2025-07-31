//
//  Reminder.swift
//  DaysToGo
//
//  Created by Jon Wright on 23/07/2025.
//


import Foundation

struct Reminder: Identifiable, Codable {
    let id: UUID
    var title: String
    var date: Date
    
    var daysRemaining: Int {
        let start = Calendar.current.startOfDay(for: Date())
        let end = Calendar.current.startOfDay(for: date)
        return Calendar.current.dateComponents([.day], from: start, to: end).day ?? 0
    }

}

extension Reminder {
    var reflectionDate: Date? {
        let days = daysRemaining
        let today = Calendar.current.startOfDay(for: Date())
        return Calendar.current.date(byAdding: .day, value: -days, to: today)
    }
}


