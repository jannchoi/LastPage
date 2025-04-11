//
//  NetworkManagerRepository.swift
//  LastPage
//
//  Created by 최정안 on 3/30/25.
//

import Foundation
import Combine

class NetworkManagerRepository: NetworkProtocol {
    static let shared = NetworkManagerRepository()
    private let networkManager: NetworkManager

    init(networkManager: NetworkManager = .shared) {
        self.networkManager = networkManager
    }

    func callRequest<T: Decodable>(target: NetworkRouter, model: T.Type) -> AnyPublisher<T, NetworkError> {
        return networkManager.callRequest(target: target, model: model)
    }
}

