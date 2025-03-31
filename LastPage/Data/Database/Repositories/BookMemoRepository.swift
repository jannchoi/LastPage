//
//  BookMemoRepository.swift
//  LastPage
//
//  Created by 최정안 on 4/1/25.
//

import Foundation
import Combine
import RealmSwift

class BookMemoRepository: BookMemoRepositoryProtocol {
    private let dataSource: BookMemoDataSourceProtocol
    private let mapper: BookMemoMapperProtocol
    
    init(dataSource: BookMemoDataSourceProtocol, mapper: BookMemoMapperProtocol) {
        self.dataSource = dataSource
        self.mapper = mapper
    }
    
    func getAllBooks() -> AnyPublisher<[BookEntity], Error> {
        return dataSource.getAllBooks()
            .map { bookMemos in
                bookMemos.map { self.mapper.mapToDomain(realmModel: $0) }
            }
            .eraseToAnyPublisher()
    }
    
    func getBook(with id: String) -> AnyPublisher<BookEntity?, Error> {
        let objectId = try! ObjectId(string: id)
        return dataSource.getBook(with: objectId)
            .map { bookMemo in
                bookMemo.map { self.mapper.mapToDomain(realmModel: $0) }
            }
            .eraseToAnyPublisher()
    }
    
    func saveBook(_ book: BookEntity) -> AnyPublisher<Void, Error> {
        let realmModel = mapper.mapToRealm(domainModel: book)
        return dataSource.saveBook(realmModel)
    }
    
    func updateBook(_ book: BookEntity) -> AnyPublisher<Void, Error> {
        let realmModel = mapper.mapToRealm(domainModel: book)
        return dataSource.updateBook(realmModel)
    }
    
    func deleteBook(with id: String) -> AnyPublisher<Void, Error> {
        let objectId = try! ObjectId(string: id)
        return dataSource.deleteBook(with: objectId)
    }
    
    func getBooks(withStatus status: ReadingStatusEntity) -> AnyPublisher<[BookEntity], Error> {
        let realmStatus = ReadingStatus(rawValue: status.rawValue)!
        return dataSource.getBooks(withStatus: realmStatus)
            .map { bookMemos in
                bookMemos.map { self.mapper.mapToDomain(realmModel: $0) }
            }
            .eraseToAnyPublisher()
    }
    
    func getBooks(withCategory category: String) -> AnyPublisher<[BookEntity], Error> {
        return dataSource.getBooks(withCategory: category)
            .map { bookMemos in
                bookMemos.map { self.mapper.mapToDomain(realmModel: $0) }
            }
            .eraseToAnyPublisher()
    }
    
    func getBooks(withFeeling feeling: String) -> AnyPublisher<[BookEntity], Error> {
        return dataSource.getBooks(withFeeling: feeling)
            .map { bookMemos in
                bookMemos.map { self.mapper.mapToDomain(realmModel: $0) }
            }
            .eraseToAnyPublisher()
    }
}
