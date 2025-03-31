//
//  SaveBookUseCase.swift
//  LastPage
//
//  Created by 최정안 on 4/1/25.
//

import Foundation
import Combine
class SaveBookUseCase: SaveBookUseCaseProtocol {
    private let repository: BookMemoRepositoryProtocol
    
    init(repository: BookMemoRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(_ book: BookEntity) -> AnyPublisher<Void, Error> {
        return repository.saveBook(book)
    }
}
