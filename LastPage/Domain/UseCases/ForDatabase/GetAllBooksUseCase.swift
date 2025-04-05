//
//  GetAllBooksUseCase.swift
//  LastPage
//
//  Created by 최정안 on 4/1/25.
//

import Foundation
import Combine
class GetAllBooksUseCase: GetAllBooksUseCaseProtocol {
    private let repository: BookMemoRepositoryProtocol
    
    init(
        repository: BookMemoRepositoryProtocol
    ) {
        self.repository = repository
    }
    
    func execute() -> AnyPublisher<[BookEntity], Error> {
        return repository.getAllBooks()
    }
    func excuteHome() -> AnyPublisher<[HomeBookEntity], Error> {
        return repository.getHomeBooks()
    }
}
