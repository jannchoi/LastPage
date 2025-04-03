//
//  NetworkError.swift
//  LastPage
//
//  Created by 최정안 on 3/30/25.
//

import Foundation

enum NetworkError: Error, Equatable {
    case badRequest // 400
    case unauthorized // 401
    case forbidden // 403
    case notFound // 404
    case rateLimited // 429
    case serverError // 500, 503
    case customError(code: Int, message: String) // 기타 상태 코드

    var errorMessage: String {
        switch self {
        case .badRequest:
            return "잘못된 요청입니다."
        case .unauthorized:
            return "인증이 실패했습니다. 유효한 API 키를 제공해야 합니다."
        case .forbidden:
            return "접근이 금지되었습니다."
        case .notFound:
            return "요청한 리소스를 찾을 수 없습니다."
        case .rateLimited:
            return "요청 한도를 초과했습니다. 나중에 다시 시도하세요."
        case .serverError:
            return "서버에서 오류가 발생했습니다."
        case .customError(_, let message):
            return message
        }
    }
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
