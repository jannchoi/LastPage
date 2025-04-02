//
//  ReadingStatusEntity.swift
//  LastPage
//
//  Created by 최정안 on 4/1/25.
//

import Foundation
enum ReadingStatusEntity: String, CaseIterable {
    case unread = "읽기전"
    case reading = "읽는중"
    case completed = "읽은후"

    var segmentIndex: Int {
        return Self.allCases.firstIndex(of: self) ?? 0
    }

    static func from(index: Int) -> ReadingStatusEntity {
        return Self.allCases[safe: index] ?? .unread
    }
}

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
