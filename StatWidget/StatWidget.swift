//
//  StatWidget.swift
//  StatWidget
//
//  Created by 최정안 on 4/22/25.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent(), bookStats: BookStats(monthCount: 0, yearCount: 0, totalCount: 0))
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        let stats = BookStats.loadFromUserDefaults()
           return SimpleEntry(date: Date(), configuration: configuration, bookStats: stats)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        let bookStats = BookStats.loadFromUserDefaults()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration, bookStats: bookStats)
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .atEnd)
    }

//    func relevances() async -> WidgetRelevances<ConfigurationAppIntent> {
//        // Generate a list containing the contexts this widget is relevant in.
//    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let bookStats: BookStats
}

struct StatWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    var body: some View {
        let stats = entry.bookStats
        VStack {
            switch family {
            case .systemSmall:
                SmallStatWidgetView(stats: stats)
            case .systemMedium:
                MediumStatWidgetView(stats: stats)
            @unknown default:
                SmallStatWidgetView(stats: stats)
            }
        }
    }
}

struct StatWidget: Widget {
    let kind: String = "StatWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            StatWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

extension ConfigurationAppIntent {
    fileprivate static var smiley: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "😀"
        return intent
    }
    
    fileprivate static var starEyes: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "🤩"
        return intent
    }
}


extension BookStats {
    static func loadFromUserDefaults() -> BookStats {
        let defaults = UserDefaults(suiteName: "group.com.jannchoi.readingStats")
        if let data = defaults?.data(forKey: "bookStats"),
           let stats = try? JSONDecoder().decode(BookStats.self, from: data) {
            return stats
        } else {
            return BookStats(monthCount: 0, yearCount: 0, totalCount: 0)
        }
    }
}
