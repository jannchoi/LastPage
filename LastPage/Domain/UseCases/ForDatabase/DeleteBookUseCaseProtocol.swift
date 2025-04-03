//
//  DeleteBookUseCaseProtocol.swift
//  LastPage
//
//  Created by 최정안 on 4/1/25.
//

import Foundation
import Combine
protocol DeleteBookUseCaseProtocol {
    func execute(with id: String) -> AnyPublisher<Void, Error>
    func execute() -> AnyPublisher<Void, Error>
}

