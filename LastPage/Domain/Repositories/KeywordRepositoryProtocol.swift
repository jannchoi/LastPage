//
//  KeywordRepositoryProtocol.swift
//  LastPage
//
//  Created by 최정안 on 3/31/25.
//

import Foundation
import Combine

protocol KeywordRepositoryProtocol {
    func fetchKeywords(prompt: String) -> AnyPublisher<KeywordEntity, NetworkError>
}
