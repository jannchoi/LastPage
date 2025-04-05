//
//  BookDetailEntity.swift
//  LastPage
//
//  Created by 최정안 on 4/2/25.
//

import Foundation

struct BookDetailEntity {
    //let addedDate: String
    let imagePath: String?
    let addedDate: Date?
    let title: String
    let author: String
    let status: ReadingStatusEntity
    let shortMemo: String
    let categories: [String]
    let feelings: [String]
}
