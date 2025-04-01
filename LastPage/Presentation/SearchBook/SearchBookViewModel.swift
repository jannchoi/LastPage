//
//  SearchBookViewModel.swift
//  LastPage
//
//  Created by 최정안 on 4/1/25.
//

import Foundation
import Combine

final class SearchBookViewModel:BaseViewModel {

    var cancellables = Set<AnyCancellable>()
    let fetchBookUseCase: FetchBookUseCaseProtocol
    struct Input {
        
    }
    struct Output {
        
    }
    init(fetchBookUseCase: FetchBookUseCaseProtocol) {
        self.fetchBookUseCase = fetchBookUseCase
    }
    func transform(input: Input) -> Output {
        //
        return Output()
    }
    
}
