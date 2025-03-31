//
//  ReadingStatus.swift
//  LastPage
//
//  Created by 최정안 on 4/1/25.
//

import Foundation
import RealmSwift

enum ReadingStatus: String, PersistableEnum {
    case unread
    case reading
    case completed
}
