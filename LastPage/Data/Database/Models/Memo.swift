//
//  Memo.swift
//  LastPage
//
//  Created by 최정안 on 4/1/25.
//

import Foundation
import RealmSwift

class Memo: Object {
    @Persisted var date: Date?
    @Persisted var memo: String

    convenience init(date: Date, memo: String) {
        self.init()
        self.date = date
        self.memo = memo
    }
}
