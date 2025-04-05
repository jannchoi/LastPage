//
//  BookMemo.swift
//  LastPage
//
//  Created by 최정안 on 4/1/25.
//

import Foundation
import RealmSwift

class BookMemo: Object {
    @Persisted(primaryKey: true) var id: ObjectId
    @Persisted var imagePath: String?
    @Persisted var addedDate: Date
    @Persisted var title: String
    @Persisted var author: String
    @Persisted var status: String // Enum은 직접 저장할 수 없으므로 String으로 변환
    @Persisted var shortMemo: String
    @Persisted var categories: List<String>
    @Persisted var feelings: List<String>
    @Persisted var beforeMemo: Memo?
    @Persisted var inProgressMemo: List<ProgressMemo>
    @Persisted var afterMemo: Memo?

    convenience init(
        imagePath: String?,
        title: String,
        author: String,
        status: ReadingStatus,
        shortMemo: String,
        categories: [String],
        feelings: [String],
        beforeMemo: Memo?,
        inProgressMemo: [ProgressMemo],
        afterMemo: Memo?
    ) {
        self.init()
        self.imagePath = imagePath
        self.addedDate = Date()
        self.title = title
        self.author = author
        self.status = status.rawValue
        self.shortMemo = shortMemo
        self.categories.append(objectsIn: categories)
        self.feelings.append(objectsIn: feelings)
        self.beforeMemo = beforeMemo
        self.inProgressMemo.append(objectsIn: inProgressMemo)
        self.afterMemo = afterMemo
    }
}
