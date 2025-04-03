//
//  DatabaseDIContainer.swift
//  LastPage
//
//  Created by 최정안 on 4/1/25.
//

import Foundation
import RealmSwift

final class DatabaseDIContainer {
    static let shared = DatabaseDIContainer()

    private init() {}

    // Realm 인스턴스
    private lazy var realm: Realm = {
        return try! Realm()
    }()

    // DataSource & Mapper
    private lazy var bookMemoDataSource: BookMemoDataSourceProtocol = {
        return BookMemoDataSource(realm: realm)
    }()

    private lazy var bookMemoMapper: BookMemoMapperProtocol = {
        return BookMemoMapper()
    }()

    // Repository
    private lazy var bookLocalRepository: BookMemoRepositoryProtocol = {
        return BookMemoRepository(dataSource: bookMemoDataSource, mapper: bookMemoMapper)
    }()

    // UseCase
    private lazy var getAllBooksUseCase: GetAllBooksUseCaseProtocol = {
        return GetAllBooksUseCase(repository: bookLocalRepository)
    }()

    private lazy var getBookUseCase: GetBookUseCaseProtocol = {
        return GetBookUseCase(repository: bookLocalRepository)
    }()

    private lazy var saveBookUseCase: SaveBookUseCaseProtocol = {
        return SaveBookUseCase(repository: bookLocalRepository)
    }()

    private lazy var updateBookUseCase: UpdateBookUseCaseProtocol = {
        return UpdateBookUseCase(repository: bookLocalRepository)
    }()

    private lazy var deleteBookUseCase: DeleteBookUseCaseProtocol = {
        return DeleteBookUseCase(repository: bookLocalRepository)
    }()

    private lazy var getBooksByStatusUseCase: GetBooksByStatusUseCaseProtocol = {
        return GetBooksByStatusUseCase(repository: bookLocalRepository)
    }()

    private lazy var getBooksByCategoryUseCase: GetBooksByCategoryUseCaseProtocol = {
        return GetBooksByCategoryUseCase(repository: bookLocalRepository)
    }()

    private lazy var getBooksByFeelingUseCase: GetBooksByFeelingUseCaseProtocol = {
        return GetBooksByFeelingUseCase(repository: bookLocalRepository)
    }()

    // MARK: - 외부 제공
    var getGetAllBooksUseCase: GetAllBooksUseCaseProtocol {
        return getAllBooksUseCase
    }

    var getGetBookUseCase: GetBookUseCaseProtocol {
        return getBookUseCase
    }

    var getSaveBookUseCase: SaveBookUseCaseProtocol {
        return saveBookUseCase
    }

    var getUpdateBookUseCase: UpdateBookUseCaseProtocol {
        return updateBookUseCase
    }

    var getDeleteBookUseCase: DeleteBookUseCaseProtocol {
        return deleteBookUseCase
    }

    var getGetBooksByStatusUseCase: GetBooksByStatusUseCaseProtocol {
        return getBooksByStatusUseCase
    }

    var getGetBooksByCategoryUseCase: GetBooksByCategoryUseCaseProtocol {
        return getBooksByCategoryUseCase
    }

    var getGetBooksByFeelingUseCase: GetBooksByFeelingUseCaseProtocol {
        return getBooksByFeelingUseCase
    }
}

