//
//  StatViews+.swift
//  StatWidgetExtension
//
//  Created by 최정안 on 4/24/25.
//

import SwiftUI
extension StatWidgetEntryView {
    func smallStatWidgetView(_ stats: BookStats) -> some View {
        ZStack {
            if #available(iOSApplicationExtension 17.0, *) {
                content(for: stats)
                    .containerBackground(for: .widget) {
                        Color("background")
                    }
            } else {
                Color("background")
                content(for: stats)
            }
        }
    }
    
    private func content(for stats: BookStats) -> some View {
        VStack(spacing: 4) {
            Text("총 기록 수")
                .font(.caption)
                .foregroundColor(Color("mainText"))
            Text("\(stats.totalCount)")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(Color("btnTint"))
        }
    }
    
    func mediumStatWidgetView(_ stats: BookStats) -> some View {
        ZStack {
            if #available(iOSApplicationExtension 17.0, *) {
                mediumContent(for: stats)
                    .containerBackground(for: .widget) {
                        Color("background")
                    }
            } else {
                Color("background")
                mediumContent(for: stats)
            }
        }
    }
    
    private func mediumContent(for stats: BookStats) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("📚 기록 통계")
                .font(.headline)
                .foregroundColor(Color("btnTint"))

            HStack {
                statBox(title: "이번 달", count: stats.monthCount)
                Spacer()
                statBox(title: "올해", count: stats.yearCount)
                Spacer()
                statBox(title: "전체", count: stats.totalCount)
            }
        }
        .padding()
    }
    
    private func statBox(title: String, count: Int) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption2)
                .foregroundColor(Color("mainText"))
            Text("\(count)")
                .font(.title2.bold())
                .foregroundColor(Color("btnTint"))
        }
    }
}

