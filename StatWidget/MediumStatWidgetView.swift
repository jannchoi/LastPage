//
//  MediumStatWidgetView.swift
//  StatWidgetExtension
//
//  Created by 최정안 on 4/22/25.
//

import SwiftUI

struct MediumStatWidgetView: View {
    let stats: BookStats

    var body: some View {
        ZStack {
            if #available(iOSApplicationExtension 17.0, *) {
                containerBackground(for: .widget) {
                    content
                }
            } else {
                Color("background")
                content
            }
        }
    }

    private var content: some View {
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
