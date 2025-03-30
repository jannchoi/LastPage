//
//  UseCaseProtocol.swift
//  LastPage
//
//  Created by 최정안 on 3/30/25.
//

import Foundation
import Combine

protocol UseCaseProtocol {
    associatedtype Output
    func execute() -> AnyPublisher<Output, NetworkError>
}

