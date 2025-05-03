//
//  FetchBackColorsUseCaseProtocol.swift
//  LastPage
//
//  Created by 최정안 on 5/3/25.
//

import Foundation
import Combine
protocol FetchBackColorsUseCaseProtocol {
    func execute(feelings: [String]) ->  AnyPublisher<BackColorEntity, NetworkError>
}
