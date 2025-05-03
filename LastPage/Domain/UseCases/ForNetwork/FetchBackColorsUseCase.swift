//
//  FetchBackColorsUseCase.swift
//  LastPage
//
//  Created by 최정안 on 5/3/25.
//

import Foundation
import Combine

class FetchBackColorsUseCase: FetchBackColorsUseCaseProtocol {
    private let repository: BackColorRepositoryProtocol
    init(repository: BackColorRepositoryProtocol) {
        self.repository = repository
    }
    func execute(feelings: [String]) ->  AnyPublisher<BackColorEntity, NetworkError> {
        return repository.fetchColors(feelings: feelings)
    }
}
