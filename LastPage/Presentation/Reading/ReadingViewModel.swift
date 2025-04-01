//
//  ReadingViewModel.swift
//  LastPage
//
//  Created by 최정안 on 4/1/25.
//

import Foundation
import Combine

final class ReadingViewModel: BaseViewModel {
    var cancellables = Set<AnyCancellable>()
    let getGetBookUseCase: GetBookUseCaseProtocol
    struct Input {
        
    }
    struct Output {
        
    }
    init(getGetBookUseCase: GetBookUseCaseProtocol) {
        self.getGetBookUseCase = getGetBookUseCase
    }
    func transform(input: Input) -> Output {
        //
        return Output()
    }
}
