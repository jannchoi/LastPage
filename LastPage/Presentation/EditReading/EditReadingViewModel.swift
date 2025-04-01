//
//  EditReadingViewModel.swift
//  LastPage
//
//  Created by 최정안 on 4/1/25.
//

import Foundation
import Combine
final class EditReadingViewModel:BaseViewModel {
    var cancellables = Set<AnyCancellable>()
    let makeGetBookUseCase: GetBookUseCaseProtocol
    struct Input {
        
    }
    struct Output {
        
    }
    init(makeGetBookUseCase: GetBookUseCaseProtocol) {
        self.makeGetBookUseCase = makeGetBookUseCase
    }
    func transform(input: Input) -> Output {
        //
        return Output()
    }
}
