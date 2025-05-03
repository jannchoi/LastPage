//
//  NetworkDIContainer.swift
//  LastPage
//
//  Created by 최정안 on 4/1/25.
//

import Foundation

final class NetworkDIContainer {
    static let shared = NetworkDIContainer()
    
    private init() {}

    // Repository
    private lazy var bookRepository: BookRepositoryProtocol = {
        return BookRepository()
    }()
    
    private lazy var keywordRepository: KeywordRepositoryProtocol = {
        return KeywordRepository()
    }()
    private lazy var backColorsRepository: BackColorRepositoryProtocol = {
        return BackColorRepository()
    }()

    // UseCase
    private lazy var fetchBookUseCase: FetchBookUseCaseProtocol = {
        return FetchBookUseCase(bookRepository: bookRepository)
    }()

    private lazy var fetchKeywordUseCase: FetchKeywordUseCaseProtocol = {
        return FetchKeywordUseCase(keywordRepository: keywordRepository)
    }()
    private lazy var fetchBackColorsUseCase: FetchBackColorsUseCaseProtocol = {
        return FetchBackColorsUseCase(repository: backColorsRepository)
    }()

    var getFetchBookUseCase: FetchBookUseCaseProtocol {
        return fetchBookUseCase
    }

    var getFetchKeywordUseCase: FetchKeywordUseCaseProtocol {
        return fetchKeywordUseCase
    }
    
    var getFetchBackColorsUseCase: FetchBackColorsUseCaseProtocol {
        return fetchBackColorsUseCase
    }
    
}
