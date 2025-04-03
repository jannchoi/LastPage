//
//  BookMemoRepositoryProtocol.swift
//  LastPage
//
//  Created by 최정안 on 4/1/25.
//

import Foundation
import Combine
import RealmSwift

protocol BookMemoRepositoryProtocol {
    func getAllBooks() -> AnyPublisher<[BookEntity], Error>
    func getBook(with id: String) -> AnyPublisher<BookEntity?, Error>
    func saveBook(_ book: BookEntity) -> AnyPublisher<String, Error>
    func updateBook<T>(bookId: String, field: UpdateTarget, newValue: T?, index: Int?) -> AnyPublisher<Void, Error>
    func deleteBook(with id: String) -> AnyPublisher<Void, Error>
    func getBooks(withStatus status: ReadingStatusEntity) -> AnyPublisher<[BookEntity], Error>
    func getBooks(withCategory category: String) -> AnyPublisher<[BookEntity], Error>
    func getBooks(withFeeling feeling: String) -> AnyPublisher<[BookEntity], Error>
    func resetBooks() -> AnyPublisher<Void, Error>
}

