//
//  GetBooksByStatusUseCaseProtocol.swift
//  LastPage
//
//  Created by 최정안 on 4/1/25.
//

import Foundation
import Combine
protocol GetBooksByStatusUseCaseProtocol {
    func execute(status: ReadingStatusEntity) -> AnyPublisher<[BookEntity], Error>
}

