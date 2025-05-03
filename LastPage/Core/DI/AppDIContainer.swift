//
//  AppDIContainer.swift
//  LastPage
//
//  Created by 최정안 on 4/1/25.
//

import Foundation
final class AppDIContainer {
    private let networkDI = NetworkDIContainer.shared
    private let databaseDI = DatabaseDIContainer.shared

    init() {}

    // UseCase 제공
    func makeFetchBookUseCase() -> FetchBookUseCaseProtocol {
        return networkDI.getFetchBookUseCase
    }

    func makeFetchKeywordUseCase() -> FetchKeywordUseCaseProtocol {
        return networkDI.getFetchKeywordUseCase
    }

    func makeFetchBackColorsUseCase() -> FetchBackColorsUseCaseProtocol {
        return networkDI.getFetchBackColorsUseCase
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
    func makeUpdateBookUseCase() -> UpdateBookUseCaseProtocol {
        return databaseDI.getUpdateBookUseCase
    }
    func makeDeleteBookUseCase() -> DeleteBookUseCaseProtocol {
        return databaseDI.getDeleteBookUseCase
    }
    func makeGetBooksByStatusUseCase() -> GetBooksByStatusUseCaseProtocol {
        return databaseDI.getGetBooksByStatusUseCase
    }
    func makeGetBooksByCategoryUseCase() -> GetBooksByCategoryUseCaseProtocol {
        return databaseDI.getGetBooksByCategoryUseCase
    }
    func makeGetBooksByFeelingUseCase() -> GetBooksByFeelingUseCaseProtocol {
        return databaseDI.getGetBooksByFeelingUseCase
    }
    
}
