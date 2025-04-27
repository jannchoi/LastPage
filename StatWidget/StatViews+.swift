//
//  StatViews+.swift
//  StatWidgetExtension
//
//  Created by 최정안 on 4/24/25.
//

import SwiftUI

struct WidgetBackgroundModifer: ViewModifier {
    var backgroundColor: Color
    
    init(backgroundColor: Color = Color("mainBackground")) {
        self.backgroundColor = backgroundColor
    }
    
    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content
                .containerBackground(for: .widget) {
                    backgroundColor
                }
        } else {
            content.background(backgroundColor)
        }
    }
}

extension StatWidgetEntryView {
    func smallStatWidgetView(_ stats: BookStats) -> some View {
        VStack(spacing: 4) {
            Text("총 기록 수")
                .font(.caption)
                .foregroundColor(Color("mainText"))
            Text("\(stats.totalCount)")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(Color("btnTint"))
        }
        .padding()
        .modifier(WidgetBackgroundModifer())
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
        .modifier(WidgetBackgroundModifer())
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

