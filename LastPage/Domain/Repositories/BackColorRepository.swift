//
//  BackColorRepository.swift
//  LastPage
//
//  Created by 최정안 on 5/3/25.
//

import Foundation
import Combine

class BackColorRepository: BackColorRepositoryProtocol {
    private let networkManagerRepository: NetworkManagerRepository
    
    init(networkManagerRepository: NetworkManagerRepository = .shared) {
        self.networkManagerRepository = networkManagerRepository
    }
    
    func fetchColors(feelings: [String]) -> AnyPublisher<BackColorEntity, NetworkError> {
        let target = NetworkRouter.chatGPT(prompt: Strings.Network.gptColor(feelings: feelings))
        return networkManagerRepository.callRequest(target: target, model: ChatGPTDTO.self)
            .map {$0.toBackColorEntity() ?? BackColorEntity(hexColors: ["#F4F6F8"], startPoint: CGPoint(x: 0.0, y: 0.0), endPoint: CGPoint(x: 0.0, y: 0.0))}
            .eraseToAnyPublisher()
    }
}
