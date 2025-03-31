//
//  BookMemoDataSource.swift
//  LastPage
//
//  Created by 최정안 on 4/1/25.
//

import Foundation
import Combine
import RealmSwift

class BookMemoDataSource: BookMemoDataSourceProtocol {
    private let realm: Realm
    
    init(realm: Realm = try! Realm()) {
        self.realm = realm
    }
    
    func getAllBooks() -> AnyPublisher<[BookMemo], Error> {
        return Future<[BookMemo], Error> { promise in
            do {
                let books = Array(self.realm.objects(BookMemo.self))
                promise(.success(books))
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    func getBook(with id: ObjectId) -> AnyPublisher<BookMemo?, Error> {
        return Future<BookMemo?, Error> { promise in
            do {
                let book = self.realm.object(ofType: BookMemo.self, forPrimaryKey: id)
                promise(.success(book))
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    func saveBook(_ book: BookMemo) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            do {
                try self.realm.write {
                    self.realm.add(book)
                }
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    func updateBook(_ book: BookMemo) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            do {
                try self.realm.write {
                    self.realm.add(book, update: .modified)
                }
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    func deleteBook(with id: ObjectId) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            do {
                if let book = self.realm.object(ofType: BookMemo.self, forPrimaryKey: id) {
                    try self.realm.write {
                        self.realm.delete(book)
                    }
                }
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    func getBooks(withStatus status: ReadingStatus) -> AnyPublisher<[BookMemo], Error> {
        return Future<[BookMemo], Error> { promise in
            do {
                let books = self.realm.objects(BookMemo.self).filter("status == %@", status.rawValue)
                promise(.success(Array(books)))
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    func getBooks(withCategory category: String) -> AnyPublisher<[BookMemo], Error> {
        return Future<[BookMemo], Error> { promise in
            do {
                let books = self.realm.objects(BookMemo.self).filter("ANY categories == %@", category)
                promise(.success(Array(books)))
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    func getBooks(withFeeling feeling: String) -> AnyPublisher<[BookMemo], Error> {
        return Future<[BookMemo], Error> { promise in
            do {
                let books = self.realm.objects(BookMemo.self).filter("ANY feelings == %@", feeling)
                promise(.success(Array(books)))
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
}
