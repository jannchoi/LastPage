//
//  GetBooksByStatusUseCase.swift
//  LastPage
//
//  Created by 최정안 on 4/1/25.
//

import Foundation
import Combine
class GetBooksByStatusUseCase: GetBooksByStatusUseCaseProtocol {
    private let repository: BookMemoRepositoryProtocol
    
    init(repository: BookMemoRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(status: ReadingStatusEntity) -> AnyPublisher<[BookEntity], Error> {
        return repository.getBooks(withStatus: status)
    }
}
