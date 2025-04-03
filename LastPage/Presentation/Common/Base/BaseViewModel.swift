//
//  BaseViewModel.swift
//  LastPage
//
//  Created by 최정안 on 4/1/25.
//

import Foundation
import Combine

protocol BaseViewModel {
    var cancellables: Set<AnyCancellable> {get}
    
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}

