//
//  BookInfo.swift
//  LastPage
//
//  Created by 최정안 on 3/30/25.
//

import Foundation

struct BookInfo: Decodable {
    let totalResults, startIndex, itemsPerPage: Int
    let query: String
    let item: [BookDetail]

}

// MARK: - BookDetail
struct BookDetail: Decodable {
    let title: String
    let link: String
    let author, description: String
    let itemId: Int
    let cover: String
    let categoryName: String

}
