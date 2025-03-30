//
//  BookRepository.swift
//  LastPage
//
//  Created by 최정안 on 3/30/25.
//

import Foundation
import Combine

class BookRepository: BookRepositoryProtocol {
    private let networkManagerRepository: NetworkManagerRepository
    
    init(networkManagerRepository: NetworkManagerRepository = .shared) {
        self.networkManagerRepository = networkManagerRepository
    }
    
    func fetchBooks(query: String) -> AnyPublisher<BookInfo, NetworkError> {
        let target = NetworkRouter.aladin(query: query)
        return networkManagerRepository.callRequest(target: target, model: BookInfoDTO.self)
            .map { dtoBook in
                return dtoBook.toDomain()
            }
            .eraseToAnyPublisher()
    }
}

