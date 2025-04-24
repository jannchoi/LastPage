//
//  SmallStatWidgetView.swift
//  StatWidgetExtension
//
//  Created by 최정안 on 4/22/25.
//

import SwiftUI


struct SmallStatWidgetView: View {
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
        VStack(spacing: 4) {
            Text("총 기록 수")
                .font(.caption)
                .foregroundColor(Color("mainText"))
            Text("\(stats.totalCount)")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(Color("btnTint"))
        }
    }
}
