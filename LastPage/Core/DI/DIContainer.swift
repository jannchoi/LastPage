//
//  DIContainer.swift
//  LastPage
//
//  Created by 최정안 on 3/30/25.
//

import Foundation

class DIContainer {
    static let shared = DIContainer()
    
    private init() {}
    
    // Lazy loading을 사용하여 한 번만 생성하도록 처리
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
    
    // 의존성 주입된 객체들을 제공하는 프로퍼티들
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
}
