//
//  DaysToGoWidgetLiveActivity.swift
//  DaysToGoWidget
//
//  Created by Jon Wright on 01/11/2025.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct DaysToGoWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct DaysToGoWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: DaysToGoWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension DaysToGoWidgetAttributes {
    fileprivate static var preview: DaysToGoWidgetAttributes {
        DaysToGoWidgetAttributes(name: "World")
    }
}

extension DaysToGoWidgetAttributes.ContentState {
    fileprivate static var smiley: DaysToGoWidgetAttributes.ContentState {
        DaysToGoWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: DaysToGoWidgetAttributes.ContentState {
         DaysToGoWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: DaysToGoWidgetAttributes.preview) {
   DaysToGoWidgetLiveActivity()
} contentStates: {
    DaysToGoWidgetAttributes.ContentState.smiley
    DaysToGoWidgetAttributes.ContentState.starEyes
}
