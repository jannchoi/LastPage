//
//  DateFormattManager.swift
//  LastPage
//
//  Created by 최정안 on 4/3/25.
//

import Foundation

class DateFormattManager {
    static let shared = DateFormattManager()
    
    private let dateFormatter: DateFormatter
    
    private init() {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
    }
    
    func dateToStr(_ target: Date?) -> String? {
        if let target {
            return dateFormatter.string(from: target)
        } else {
            return nil
        }
    }
    
    func strToDate(_ target: String?) -> Date? {
        if let target {
            return dateFormatter.date(from: target)
        } else {
            return nil
        }
        
    }
}
