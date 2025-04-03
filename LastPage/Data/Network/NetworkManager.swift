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
                    // 세미콜론을 제거한 새로운 Data 생성
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
        default:
            return .customError(code: code, message: "\(code) error")
        }
    }
}
