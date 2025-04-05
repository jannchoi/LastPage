//
//  BookEntityMapper.swift
//  LastPage
//
//  Created by 최정안 on 4/1/25.
//

import Foundation
class BookEntityMapper {
    static func map(_ bookdetail: BookDetail) -> BookEntity {
        return BookEntity(id: nil, bookDetail: BookDetailEntity( imagePath: bookdetail.cover, addedDate: nil, title: bookdetail.title, author: bookdetail.author, status: .unread, shortMemo: TextResource.Global.empty.text, categories: bookdetail.categoryName, feelings: []), beforeMemo: nil, inProgressMemo: [], afterMemo: nil)
    }
    static func map() -> BookEntity {
        return BookEntity(id: nil, bookDetail: BookDetailEntity( imagePath: TextResource.Global.empty.text, addedDate: nil, title: TextResource.Global.empty.text, author: TextResource.Global.empty.text, status: .unread, shortMemo: TextResource.Global.empty.text, categories: [], feelings: []), beforeMemo: nil, inProgressMemo: [], afterMemo: nil)
    }
}
