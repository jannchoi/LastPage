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
    
    func execute<T>(bookId: String, field: UpdateTarget, newValue: T) -> AnyPublisher<Void, Error> {
          return repository.updateBook(bookId: bookId, field: field, newValue: newValue)
      }
}
