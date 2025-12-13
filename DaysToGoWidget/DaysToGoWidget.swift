import WidgetKit
import SwiftUI
import CloudKit
import DaysToGoKit
import os

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), reminder: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), reminder: .placeholder)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let reminder = fetchReminder()
        let entry = SimpleEntry(date: Date(), reminder: reminder)
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
    
    func fetchReminder() -> Reminder? {
        guard let documentsDirectory = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppConstants.appGroupID) else {
            return nil
        }
        let fileURL = documentsDirectory.appendingPathComponent(AppConstants.remindersFileName)

        // Check if file exists and validate its age
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return nil
        }

        // Validate file modification date (warn if older than 1 hour)
        if let attributes = try? FileManager.default.attributesOfItem(atPath: fileURL.path),
           let modificationDate = attributes[.modificationDate] as? Date {
            let hoursSinceModification = Date().timeIntervalSince(modificationDate) / 3600
            if hoursSinceModification > 1 {
                // Data may be stale but still show it - better than nothing
                os_log(.info, log: OSLog.default, "Widget data is %d hours old", Int(hoursSinceModification))
            }
        }

        // Attempt to load and decode data with error handling
        guard let data = try? Data(contentsOf: fileURL) else {
            return nil
        }

        // Validate JSON structure
        guard let reminders = try? JSONDecoder().decode([Reminder].self, from: data),
              !reminders.isEmpty else {
            return nil
        }

        return reminders.filter { $0.daysRemaining >= 0 }.sorted { $0.date < $1.date }.first
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let reminder: Reminder?
}

struct DaysToGoWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            if let reminder = entry.reminder {
                Text(reminder.title)
                    .font(.headline)
                    .foregroundColor(.black)
                    .padding(.top)

                Spacer()

                if reminder.daysRemaining == 0 {
                    Text("Today")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.black)
                } else {
                    Text("\(reminder.daysRemaining)")
                        .font(.system(size: 80, weight: .bold))
                        .foregroundColor(.black)
                }

                Spacer()
            } else {
                Text("No Upcoming Reminders")
                    .font(.headline)
                    .foregroundColor(.black)
            }
        }
        .containerBackground(for: .widget) {
            colorFromString(entry.reminder?.backgroundColor) ?? Color.gray
        }
    }
}

@main
struct DaysToGoWidget: Widget {
    let kind: String = AppConstants.widgetKind

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) {
            entry in
            DaysToGoWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Days To Go")
        .description("See your upcoming reminders.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

extension Reminder {
    static var placeholder: Reminder {
        Reminder(title: "An Event", date: Date().addingTimeInterval(86400 * 5))
    }
}