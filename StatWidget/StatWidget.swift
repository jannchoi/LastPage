//
//  StatWidget.swift
//  StatWidget
//
//  Created by 최정안 on 4/22/25.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    // UserDefaults에서 데이터를 가져오는 헬퍼 메서드
    private func getBookStats() -> BookStats {
        return BookStats.loadFromUserDefaults()
    }
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent(), bookStats: BookStats(monthCount: 0, yearCount: 0, totalCount: 0))
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        // 최신 데이터를 가져옵니다
        let stats = getBookStats()
        return SimpleEntry(date: Date(), configuration: configuration, bookStats: stats)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        let currentDate = Date()
        
        // 최신 데이터를 가져옵니다
        let stats = getBookStats()
        let entry = SimpleEntry(
            date: currentDate,
            configuration: configuration,
            bookStats: stats
        )
        
        // 더 짧은 간격으로 업데이트 (30초로 변경)
        return Timeline(entries: [entry], policy: .after(currentDate.addingTimeInterval(30)))
    }
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
        VStack {
            switch family {
            case .systemSmall:
                smallStatWidgetView(entry.bookStats)
            case .systemMedium:
                mediumStatWidgetView(entry.bookStats)
            @unknown default:
                smallStatWidgetView(entry.bookStats)
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
