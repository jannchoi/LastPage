//
//  KeywordRepository.swift
//  LastPage
//
//  Created by 최정안 on 3/31/25.
//

import Foundation
import Combine

class KeywordRepository: KeywordRepositoryProtocol {
    private let networkManagerRepository: NetworkManagerRepository
    
    init(networkManagerRepository: NetworkManagerRepository = .shared) {
        self.networkManagerRepository = networkManagerRepository
    }
    func fetchKeywords(prompt: String) -> AnyPublisher<KeywordEntity, NetworkError> {
        let target = NetworkRouter.chatGPT(prompt: prompt)
        return networkManagerRepository.callRequest(target: target, model: KeywordDTO.self)
            .map{ dtoKeyword in
                guard let keywordEntity = dtoKeyword.toDomain() else {return KeywordEntity(id: dtoKeyword.id, keywords: [])}
                return keywordEntity
            }.eraseToAnyPublisher()
    }
    
}


