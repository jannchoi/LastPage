//
//  BookEntity.swift
//  LastPage
//
//  Created by 최정안 on 4/1/25.
//

import Foundation
struct BookEntity {
    let id: String?
    var bookDetail: BookDetailEntity
    var beforeMemo: MemoEntity?
    var inProgressMemo: [ProgressMemoEntity]
    var afterMemo: MemoEntity?
}

