//
//  NetworkProtocol.swift
//  LastPage
//
//  Created by 최정안 on 3/30/25.
//

import Foundation
import Combine

protocol NetworkProtocol {
    func callRequest<T: Decodable>(target: NetworkRouter, model: T.Type) -> AnyPublisher<T, NetworkError>
}

