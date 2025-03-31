//
//  FetchKeywordUseCase.swift
//  LastPage
//
//  Created by 최정안 on 3/31/25.
//

import Foundation
import Combine

class FetchKeywordUseCase: FetchKeywordUseCaseProtocol {
    private let keywordRepository: KeywordRepositoryProtocol
    
    init(keywordRepository: KeywordRepositoryProtocol) {
        self.keywordRepository = keywordRepository
    }
    
    func execute(prompt: String) -> AnyPublisher<KeywordEntity, NetworkError> {
        return keywordRepository.fetchKeywords(prompt: prompt)
    }
}
