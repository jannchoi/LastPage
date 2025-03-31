//
//  UpdateBookUseCase.swift
//  LastPage
//
//  Created by 최정안 on 4/1/25.
//

import Foundation
import Combine
class UpdateBookUseCase: UpdateBookUseCaseProtocol {
    private let repository: BookMemoRepositoryProtocol
    
    init(repository: BookMemoRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(_ book: BookEntity) -> AnyPublisher<Void, Error> {
        return repository.updateBook(book)
    }
}
