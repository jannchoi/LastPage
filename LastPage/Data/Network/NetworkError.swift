//
//  NetworkError.swift
//  LastPage
//
//  Created by 최정안 on 3/30/25.
//

import Foundation

enum NetworkError: Error, Equatable {
    case badRequest
    case unauthorized
    case customError(code: Int, message: String)

    var errorMessage: String {
        switch self {
        case .badRequest:
            return "잘못된 요청입니다."
        case .unauthorized:
            return "인증이 실패했습니다. 유효한 API 키를 제공해야 합니다."
        case .customError(_, let message):
            return message
        }
    }
}

