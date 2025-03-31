//
//  BookMemoRepositoryProtocol.swift
//  LastPage
//
//  Created by 최정안 on 4/1/25.
//

import Foundation
import Combine

protocol BookMemoRepositoryProtocol {
    func getAllBooks() -> AnyPublisher<[BookEntity], Error>
    func getBook(with id: String) -> AnyPublisher<BookEntity?, Error>
    func saveBook(_ book: BookEntity) -> AnyPublisher<Void, Error>
    func updateBook(_ book: BookEntity) -> AnyPublisher<Void, Error>
    func deleteBook(with id: String) -> AnyPublisher<Void, Error>
    func getBooks(withStatus status: ReadingStatusEntity) -> AnyPublisher<[BookEntity], Error>
    func getBooks(withCategory category: String) -> AnyPublisher<[BookEntity], Error>
    func getBooks(withFeeling feeling: String) -> AnyPublisher<[BookEntity], Error>
}

