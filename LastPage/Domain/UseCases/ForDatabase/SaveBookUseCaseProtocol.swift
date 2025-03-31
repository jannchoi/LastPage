//
//  SaveBookUseCaseProtocol.swift
//  LastPage
//
//  Created by 최정안 on 4/1/25.
//

import Foundation
import Combine
protocol SaveBookUseCaseProtocol {
    func execute(_ book: BookEntity) -> AnyPublisher<Void, Error>
}


