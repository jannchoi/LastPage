//
//  FetchBookUseCase.swift
//  LastPage
//
//  Created by 최정안 on 3/30/25.
//

import Foundation
import Combine

class FetchBookUseCase: FetchBookUseCaseProtocol {
    private let bookRepository: BookRepositoryProtocol
    
    init(bookRepository: BookRepositoryProtocol) {
        self.bookRepository = bookRepository
    }
    
    func execute(query: String, page: Int) -> AnyPublisher<BookInfo, NetworkError> {
        return bookRepository.fetchBooks(query: query, page: page)
    }
}

