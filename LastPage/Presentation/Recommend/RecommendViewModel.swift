//
//  RecommendViewModel.swift
//  LastPage
//
//  Created by 최정안 on 4/1/25.
//

import Foundation
import Combine

final class RecommendViewModel:BaseViewModel {
    var cancellables = Set<AnyCancellable>()
    let makeFetchKeywordUseCase: FetchKeywordUseCaseProtocol
    struct Input {
        
    }
    struct Output {
        
    }
    init(makeFetchKeywordUseCase: FetchKeywordUseCaseProtocol) {
        self.makeFetchKeywordUseCase = makeFetchKeywordUseCase
    }
    func transform(input: Input) -> Output {
        //
        return Output()
    }
}
