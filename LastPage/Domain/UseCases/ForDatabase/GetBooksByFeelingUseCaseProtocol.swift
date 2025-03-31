//
//  GetBooksByFeelingUseCaseProtocol.swift
//  LastPage
//
//  Created by 최정안 on 4/1/25.
//

import Foundation
import Combine
protocol GetBooksByFeelingUseCaseProtocol {
    func execute(feeling: String) -> AnyPublisher<[BookEntity], Error>
}


