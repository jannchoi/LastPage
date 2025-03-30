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
    
    var bookRepository: BookRepositoryProtocol {
        return BookRepository()
    }
    
    var fetchBookUseCase: FetchBookUseCaseProtocol {
        return FetchBookUseCase(bookRepository: bookRepository)
    }
}
