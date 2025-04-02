//
//  BookEntityMapper.swift
//  LastPage
//
//  Created by 최정안 on 4/1/25.
//

import Foundation
class BookEntityMapper {
    static func map(_ bookdetail: BookDetail) -> BookEntity {
        return BookEntity(id: nil, imagePath: bookdetail.cover, title: bookdetail.title, author: bookdetail.author, status: .unread, categories: [bookdetail.categoryName], feelings: [], beforeMemo: nil, inProgressMemo: [], afterMemo: nil)
    }
    static func map() -> BookEntity {
        return BookEntity(id: nil, imagePath: "", title: "", author: "", status: .unread, categories: [], feelings: [], beforeMemo: nil, inProgressMemo: [], afterMemo: nil)
    }
}
