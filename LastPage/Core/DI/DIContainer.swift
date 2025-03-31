//
//  DIContainer.swift
//  LastPage
//
//  Created by 최정안 on 3/30/25.
//

import Foundation
import RealmSwift

class DIContainer {
    static let shared = DIContainer()
    
    private init() {
        setupDatabaseDependencies()
    }
    
    // MARK: - 기존 네트워크 의존성
    
    private lazy var bookRepository: BookRepositoryProtocol = {
        return BookRepository()
    }()
    
    private lazy var fetchBookUseCase: FetchBookUseCaseProtocol = {
        return FetchBookUseCase(bookRepository: bookRepository)
    }()
    
    private lazy var keywordRepository: KeywordRepositoryProtocol = {
        return KeywordRepository()
    }()
    
    private lazy var fetchKeywordUseCase: FetchKeywordUseCaseProtocol = {
        return FetchKeywordUseCase(keywordRepository: keywordRepository)
    }()
    
    // MARK: - 데이터베이스 의존성
    
    private lazy var realm: Realm = {
        return try! Realm()
    }()
    
    private lazy var bookMemoDataSource: BookMemoDataSourceProtocol = {
        return BookMemoDataSource(realm: realm)
    }()
    
    private lazy var bookMemoMapper: BookMemoMapperProtocol = {
        return BookMemoMapper()
    }()
    
    private lazy var bookLocalRepository: BookMemoRepositoryProtocol = {
        return BookMemoRepository(dataSource: bookMemoDataSource, mapper: bookMemoMapper)
    }()
    
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
    
    // MARK: - 데이터베이스 의존성 주입 설정
    
    private func setupDatabaseDependencies() {
        // 필요한 경우 초기 설정 코드
    }
    
    // MARK: - 네트워크 의존성 제공 (기존)
    
    var getBookRepository: BookRepositoryProtocol {
        return bookRepository
    }
    
    var getFetchBookUseCase: FetchBookUseCaseProtocol {
        return fetchBookUseCase
    }
    
    var getKeywordRepository: KeywordRepositoryProtocol {
        return keywordRepository
    }
    
    var getFetchKeywordUseCase: FetchKeywordUseCaseProtocol {
        return fetchKeywordUseCase
    }
    
    // MARK: - 데이터베이스 의존성 제공 (새로 추가)
    
    var getBookLocalRepository: BookMemoRepositoryProtocol {
        return bookLocalRepository
    }
    
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
