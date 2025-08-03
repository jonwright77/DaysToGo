//
//  BindingExtensions.swift
//  DaysToGo
//
//  Created by Claude on 07/11/2025.
//

import SwiftUI

extension Binding where Value: ExpressibleByNilLiteral {
    /// Creates a binding to a Boolean that represents whether the value is present.
    ///
    /// This is useful for controlling alert presentation based on optional error values.
    /// Setting the binding to `false` will set the wrapped value to `nil`.
    ///
    /// Usage:
    /// ```swift
    /// @State private var error: AppError?
    /// .alert(isPresented: $error.isPresent, error: error) { ... }
    /// ```
    var isPresent: Binding<Bool> {
        Binding<Bool>(
            get: {
                // Check if this is actually an Optional and if it's non-nil
                let mirror = Mirror(reflecting: self.wrappedValue)
                if mirror.displayStyle == .optional {
                    return mirror.children.first != nil
                }
                // If not an Optional, assume present
                return true
            },
            set: { if !$0 { self.wrappedValue = nil } }
        )
    }
}
