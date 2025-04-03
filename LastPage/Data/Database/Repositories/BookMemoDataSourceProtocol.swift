//
//  BookMemoDataSourceProtocol.swift
//  LastPage
//
//  Created by 최정안 on 4/1/25.
//

import Foundation
import Combine
import RealmSwift


protocol BookMemoDataSourceProtocol {
    func getAllBooks() -> AnyPublisher<[BookMemo], Error>
    func getBook(with id: ObjectId) -> AnyPublisher<BookMemo?, Error>
    func saveBook(_ book: BookMemo) -> AnyPublisher<ObjectId, Error>
    func updateBook(_ book: BookMemo) -> AnyPublisher<Void, Error>
    func deleteBook(with id: ObjectId) -> AnyPublisher<Void, Error>
    func getBooks(withStatus status: ReadingStatus) -> AnyPublisher<[BookMemo], Error>
    func getBooks(withCategory category: String) -> AnyPublisher<[BookMemo], Error>
    func getBooks(withFeeling feeling: String) -> AnyPublisher<[BookMemo], Error>
}
