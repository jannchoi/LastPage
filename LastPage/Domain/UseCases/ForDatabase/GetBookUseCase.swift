//
//  GetBookUseCase.swift
//  LastPage
//
//  Created by 최정안 on 4/1/25.
//

import Foundation
import Combine
class GetBookUseCase: GetBookUseCaseProtocol {
    private let repository: BookMemoRepositoryProtocol
    
    init(repository: BookMemoRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(with id: String) -> AnyPublisher<BookEntity?, Error> {
        return repository.getBook(with: id)
    }
}
