//
//  BookStats.swift
//  LastPage
//
//  Created by 최정안 on 4/6/25.
//

import Foundation
import WidgetKit

struct BookStats: Codable {
    let monthCount: Int
    let yearCount: Int
    let totalCount: Int
}
extension BookStats {
    static func loadFromUserDefaults() -> BookStats {
        // App Group 이름 확인
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
            print("✅ 위젯 데이터 로드 성공: \(stats)")
            return stats
        } catch {
            print("📛 디코딩 실패: \(error)")
            return BookStats(monthCount: 0, yearCount: 0, totalCount: 0)
        }
    }
    
    // UserDefaults에 데이터 저장 메서드 추가 (앱과 위젯 간 일관성을 위해)
    static func saveToUserDefaults(_ stats: BookStats) {
        guard let defaults = UserDefaults(suiteName: "group.com.jannchoi.readingStats") else {
            print("📛 App Group 설정 안됨!")
            return
        }
        
        do {
            let data = try JSONEncoder().encode(stats)
            defaults.set(data, forKey: "bookStats")
            defaults.synchronize() // 명시적으로 동기화
            
            // 위젯 업데이트 요청
            WidgetCenter.shared.reloadTimelines(ofKind: "StatWidget")
            print("✅ 위젯 데이터 저장 및 리로드 요청 성공")
        } catch {
            print("📛 인코딩 실패: \(error)")
        }
    }
}


