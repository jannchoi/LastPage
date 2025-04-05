//
//  NetworkManager.swift
//  LastPage
//
//  Created by 최정안 on 3/30/25.
//

import Foundation
import Combine

class NetworkManager {
    static let shared = NetworkManager()

    private init() {}

    func callRequest<T: Decodable>(target: NetworkRouter, model: T.Type) -> AnyPublisher<T, NetworkError> {
        guard NetworkMonitor.shared.isConnected else {  // ✅ 동기적으로 현재 상태 확인
            return Fail(error: NetworkError.customError(code: -1009, message: "인터넷 연결이 끊어졌습니다.")).eraseToAnyPublisher()
        }
        
        let request = target.asURLRequest()
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { [weak self] data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.customError(code: 500, message: "Invalid response")
                }
                guard 200..<300 ~= httpResponse.statusCode else {
                    throw self?.getError(code: httpResponse.statusCode) ?? .customError(code: 500, message: "Unknown error")
                }
                var modifiedData = data

                if let stringData = String(data: data, encoding: .utf8),
                   stringData.hasSuffix(";") {
                    let modifiedString = stringData.dropLast()
                    modifiedData = Data(modifiedString.utf8)
                }
                return modifiedData
            }
            .decode(type: T.self, decoder: JSONDecoder())
            .mapError { error in
                if let networkError = error as? NetworkError {
                    return networkError
                } else {
                    return .customError(code: 500, message: error.localizedDescription)
                }
            }
            .eraseToAnyPublisher()
    }


    
    private func getError(code: Int) -> NetworkError {
        switch code {
        case 400:
            return .badRequest
        case 401:
            return .unauthorized
        case 403:
            return .forbidden
        case 404:
            return .notFound
        case 429:
            return .rateLimited
        case 500, 503:
            return .serverError
        default:
            return .customError(code: code, message: "\(code) error")
        }
    }
}
