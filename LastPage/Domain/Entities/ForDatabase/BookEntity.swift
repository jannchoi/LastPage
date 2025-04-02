//
//  BookEntity.swift
//  LastPage
//
//  Created by 최정안 on 4/1/25.
//

import Foundation
struct BookEntity {
    let id: String?
    let imagePath: String
    let title: String
    let author: String
    let status: ReadingStatusEntity
    let categories: [String]
    let feelings: [String]
    let beforeMemo: MemoEntity?
    let inProgressMemo: [ProgressMemoEntity]
    let afterMemo: MemoEntity?
}
struct BookDetailEntity {
    let imagePath: String
    let title: String
    let author: String
    let status: ReadingStatusEntity
    let shortMemo: String
    let categories: [String]
    let feelings: [String]
}
