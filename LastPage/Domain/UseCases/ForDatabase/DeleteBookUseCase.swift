//
//  DeleteBookUseCase.swift
//  LastPage
//
//  Created by 최정안 on 4/1/25.
//

import Foundation
import Combine

class DeleteBookUseCase: DeleteBookUseCaseProtocol {
    private let repository: BookMemoRepositoryProtocol
    
    init(repository: BookMemoRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(with id: String) -> AnyPublisher<Void, Error> {
        return repository.deleteBook(with: id)
    }
    func execute() -> AnyPublisher<Void, Error> {
        return repository.resetBooks()
    }
}
