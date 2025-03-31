//
//  GetBooksByCategoryUseCaseProtocol.swift
//  LastPage
//
//  Created by 최정안 on 4/1/25.
//

import Foundation
import Combine
protocol GetBooksByCategoryUseCaseProtocol {
    func execute(category: String) -> AnyPublisher<[BookEntity], Error>
}


