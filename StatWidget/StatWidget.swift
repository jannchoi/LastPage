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
        let currentDate = Date()
        let entry = SimpleEntry(
            date: currentDate,
            configuration: configuration,
            bookStats: BookStats.loadFromUserDefaults() // 하드코딩 테스트
        )
        return Timeline(entries: [entry], policy: .after(currentDate.addingTimeInterval(60)))
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
        .contentMarginsDisabled()
        .containerBackgroundRemovable(false)
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
        guard let defaults = UserDefaults(suiteName: "group.com.jannchoi.readingStats") else {
            print("📛 App Group 설정 안됨!")
            return BookStats(monthCount: 0, yearCount: 0, totalCount: 0)
        }
        
        guard let data = defaults.data(forKey: "bookStats") else {
            print("📛 데이터 없음")
            return BookStats(monthCount: 0, yearCount: 0, totalCount: 0)
        }
        
        do {
            let stats = try JSONDecoder().decode(BookStats.self, from: data)
            print(stats)
            return stats
        } catch {
            print("📛 디코딩 실패: \(error)")
            return BookStats(monthCount: 0, yearCount: 0, totalCount: 0)
        }
    }
}
