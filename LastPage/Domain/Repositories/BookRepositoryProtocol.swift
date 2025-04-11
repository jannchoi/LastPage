//
//  BookRepositoryProtocol.swift
//  LastPage
//
//  Created by 최정안 on 3/30/25.
//

import Foundation
import Combine

protocol BookRepositoryProtocol {
    func fetchBooks(query: String, page: Int) -> AnyPublisher<BookInfo, NetworkError>
}
