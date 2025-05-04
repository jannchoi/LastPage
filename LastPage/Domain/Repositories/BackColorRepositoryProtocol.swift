//
//  BackColorRepositoryProtocol.swift
//  LastPage
//
//  Created by 최정안 on 5/3/25.
//

import Foundation
import Combine

protocol BackColorRepositoryProtocol {
    func fetchColors(feelings: [String]) -> AnyPublisher<BackColorEntity, NetworkError>
}
