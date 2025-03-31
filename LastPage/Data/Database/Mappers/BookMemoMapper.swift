//
//  BookMemoMapper.swift
//  LastPage
//
//  Created by 최정안 on 4/1/25.
//

import Foundation
import RealmSwift

class BookMemoMapper: BookMemoMapperProtocol {
    func mapToDomain(realmModel: BookMemo) -> BookEntity {
        let statusString = realmModel.status
        let statusEntity: ReadingStatusEntity
        
        switch statusString {
        case "읽기전":
            statusEntity = .unread
        case "읽는중":
            statusEntity = .reading
        case "읽은후":
            statusEntity = .completed
        default:
            statusEntity = .unread
        }
        return BookEntity(
            id: realmModel.id.stringValue,
            imagePath: realmModel.imagePath,
            title: realmModel.title,
            author: realmModel.author,
            status: statusEntity,
            categories: Array(realmModel.categories),
            feelings: Array(realmModel.feelings),
            beforeMemo: realmModel.beforeMemo.map {
                MemoEntity(date: $0.date, memo: $0.memo)
            },
            inProgressMemo: realmModel.inProgressMemo.map {
                ProgressMemoEntity(
                    startPage: $0.startPage,
                    endPage: $0.endPage,
                    date: $0.date,
                    memo: $0.memo
                )
            },
            afterMemo: realmModel.afterMemo.map {
                MemoEntity(date: $0.date, memo: $0.memo)
            }
        )
    }
    
    func mapToRealm(domainModel: BookEntity) -> BookMemo {
        let bookMemo = BookMemo()
        if let id = domainModel.id, !id.isEmpty {
            bookMemo.id = try! ObjectId(string: id)
        } else {
            bookMemo.id = ObjectId.generate()
        }
        bookMemo.imagePath = domainModel.imagePath
        bookMemo.title = domainModel.title
        bookMemo.author = domainModel.author
        bookMemo.status = domainModel.status.rawValue
        
        // 카테고리 설정
        bookMemo.categories.removeAll()
        bookMemo.categories.append(objectsIn: domainModel.categories)
        
        // 감정 설정
        bookMemo.feelings.removeAll()
        bookMemo.feelings.append(objectsIn: domainModel.feelings)
        
        // 읽기 전 메모 설정
        if let beforeMemo = domainModel.beforeMemo {
            let memo = Memo()
            memo.date = beforeMemo.date
            memo.memo = beforeMemo.memo
            bookMemo.beforeMemo = memo
        } else {
            bookMemo.beforeMemo = nil
        }
        
        // 읽는 중 메모 설정
        bookMemo.inProgressMemo.removeAll()
        domainModel.inProgressMemo.forEach { item in
            let progressMemo = ProgressMemo()
            progressMemo.startPage = item.startPage
            progressMemo.endPage = item.endPage
            progressMemo.date = item.date
            progressMemo.memo = item.memo
            bookMemo.inProgressMemo.append(progressMemo)
        }
        
        // 읽은 후 메모 설정
        if let afterMemo = domainModel.afterMemo {
            let memo = Memo()
            memo.date = afterMemo.date
            memo.memo = afterMemo.memo
            bookMemo.afterMemo = memo
        } else {
            bookMemo.afterMemo = nil
        }
        
        return bookMemo
    }
}
