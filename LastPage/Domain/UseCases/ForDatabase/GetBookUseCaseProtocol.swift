//
//  GetBookUseCaseProtocol.swift
//  LastPage
//
//  Created by 최정안 on 4/1/25.
//

import Foundation
import Combine

protocol GetBookUseCaseProtocol {
    func execute(with id: String) -> AnyPublisher<BookEntity?, Error>
}

