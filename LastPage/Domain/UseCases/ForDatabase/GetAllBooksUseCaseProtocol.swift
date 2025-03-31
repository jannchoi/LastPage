//
//  GetAllBooksUseCaseProtocol.swift
//  LastPage
//
//  Created by 최정안 on 4/1/25.
//

import Foundation
import Combine

protocol GetAllBooksUseCaseProtocol {
    func execute() -> AnyPublisher<[BookEntity], Error>
}

