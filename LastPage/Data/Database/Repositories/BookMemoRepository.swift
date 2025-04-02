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

    func updateBook<T>(bookId: String, field: UpdateTarget, newValue: T, index: Int? = nil) -> AnyPublisher<Void, Error> {
        return dataSource.getBook(with: try! ObjectId(string: bookId))
            .flatMap { existingMemo -> AnyPublisher<Void, Error> in
                guard let existingMemo = existingMemo else {
                    return Fail(error: NSError(domain: "BookMemoRepository", code: 404, userInfo: [NSLocalizedDescriptionKey: "Book not found"]))
                        .eraseToAnyPublisher()
                }

                // BookMemo -> BookEntity 변환
                let existingEntity = self.mapper.mapToDomain(realmModel: existingMemo)

                // BookEntity 업데이트
                let updatedEntity = self.mapper.updateBookEntity(existing: existingEntity, newValue: newValue, field: field, index: index)

                // BookEntity -> BookMemo 변환 후 Realm 저장
                let updatedMemo = self.mapper.mapToRealm(domainModel: updatedEntity)

                return self.dataSource.updateBook(updatedMemo)
            }
            .eraseToAnyPublisher()
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
