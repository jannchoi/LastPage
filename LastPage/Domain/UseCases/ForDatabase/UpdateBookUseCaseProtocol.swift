//
//  UpdateBookUseCaseProtocol.swift
//  LastPage
//
//  Created by 최정안 on 4/1/25.
//

import Foundation
import Combine

protocol UpdateBookUseCaseProtocol {
    func execute<T>(bookId: String, field: UpdateTarget, newValue: T, index: Int?) -> AnyPublisher<Void, Error>
}

