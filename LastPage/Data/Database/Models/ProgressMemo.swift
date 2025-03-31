//
//  ProgressMemo.swift
//  LastPage
//
//  Created by 최정안 on 4/1/25.
//

import Foundation
import RealmSwift
class ProgressMemo: Object {
    @Persisted var startPage: Int
    @Persisted var endPage: Int
    @Persisted var date: Date
    @Persisted var memo: String

    convenience init(startPage: Int, endPage: Int, date: Date, memo: String) {
        self.init()
        self.startPage = startPage
        self.endPage = endPage
        self.date = date
        self.memo = memo
    }
}
