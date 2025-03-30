//
//  FetchBookUseCaseProtocol.swift
//  LastPage
//
//  Created by 최정안 on 3/30/25.
//

import Foundation
import Combine
protocol FetchBookUseCaseProtocol {
    func execute(query: String) -> AnyPublisher<BookInfo, NetworkError>
}
