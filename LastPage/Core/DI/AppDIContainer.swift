//
//  AppDIContainer.swift
//  LastPage
//
//  Created by 최정안 on 4/1/25.
//

import Foundation
final class AppDIContainer {
    static let shared = AppDIContainer()

    private let networkDI = NetworkDIContainer.shared
    private let databaseDI = DatabaseDIContainer.shared

    private init() {}

    // UseCase 제공
    func makeFetchBookUseCase() -> FetchBookUseCaseProtocol {
        return networkDI.getFetchBookUseCase
    }

    func makeFetchKeywordUseCase() -> FetchKeywordUseCaseProtocol {
        return networkDI.getFetchKeywordUseCase
    }

    func makeGetAllBooksUseCase() -> GetAllBooksUseCaseProtocol {
        return databaseDI.getGetAllBooksUseCase
    }

    func makeGetBookUseCase() -> GetBookUseCaseProtocol {
        return databaseDI.getGetBookUseCase
    }

    func makeSaveBookUseCase() -> SaveBookUseCaseProtocol {
        return databaseDI.getSaveBookUseCase
    }
}
