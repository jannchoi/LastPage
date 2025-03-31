//
//  GetBooksByFeelingUseCase.swift
//  LastPage
//
//  Created by 최정안 on 4/1/25.
//

import Foundation
import Combine
class GetBooksByFeelingUseCase: GetBooksByFeelingUseCaseProtocol {
    private let repository: BookMemoRepositoryProtocol
    
    init(repository: BookMemoRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(feeling: String) -> AnyPublisher<[BookEntity], Error> {
        return repository.getBooks(withFeeling: feeling)
    }
}
