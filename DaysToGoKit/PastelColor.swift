//
//  PastelColor.swift
//  DaysToGoKit
//
//  Created by Gemini on 02/11/2025.
//

import SwiftUI

public enum PastelColor: String, CaseIterable, Identifiable {
    case pastelBlue = "Pastel Blue"
    case pastelGreen = "Pastel Green"
    case pastelPink = "Pastel Pink"
    case pastelPurple = "Pastel Purple"
    case pastelYellow = "Pastel Yellow"
    case pastelOrange = "Pastel Orange"
    case pastelRed = "Pastel Red"
    case pastelGray = "Pastel Gray"

    public var id: String { self.rawValue }

    public var color: Color {
        switch self {
        case .pastelBlue:
            return Color(red: 0.6, green: 0.8, blue: 1.0)
        case .pastelGreen:
            return Color(red: 0.6, green: 1.0, blue: 0.6)
        case .pastelPink:
            return Color(red: 1.0, green: 0.6, blue: 0.8)
        case .pastelPurple:
            return Color(red: 0.8, green: 0.6, blue: 1.0)
        case .pastelYellow:
            return Color(red: 1.0, green: 1.0, blue: 0.6)
        case .pastelOrange:
            return Color(red: 1.0, green: 0.8, blue: 0.6)
        case .pastelRed:
            return Color(red: 1.0, green: 0.6, blue: 0.6)
        case .pastelGray:
            return Color(red: 0.8, green: 0.8, blue: 0.8)
        }
    }
}

public func colorFromString(_ colorName: String?) -> Color? {
    guard let colorName = colorName else { return nil }
    return PastelColor(rawValue: colorName)?.color
}
