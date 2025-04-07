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
    let getBookUseCase: GetBookUseCaseProtocol
    @Published private(set) var fetchError: String? = nil
    @Published var keywordData: [String]?
    @Published private(set) var error: NetworkError? = nil
    struct Input {
        
    }
    struct Output {
        
    }
    init(bookId: String, makeFetchKeywordUseCase: FetchKeywordUseCaseProtocol, getBookUseCase: GetBookUseCaseProtocol) {
        self.makeFetchKeywordUseCase = makeFetchKeywordUseCase
        self.getBookUseCase = getBookUseCase
        self.fetchBook(itemId: bookId)
        
    }
    func transform(input: Input) -> Output {
        //
        return Output()
    }
    private func fetchBook(itemId: String) {
        getBookUseCase.execute(with: itemId)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.fetchError = TextResource.DataError.fetchError.text
                }
            } receiveValue: { [weak self] book in
                guard let self = self, let book = book else {return}
                self.fetchKeyword(query: book.bookDetail.title)

            }
            .store(in: &cancellables)
    }
    private func fetchKeyword(query: String) {
        makeFetchKeywordUseCase.execute(prompt: query).receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {[weak self] completion in
            switch completion {
            case .failure(let error):
                guard let self = self else {return}
                self.error = error
            case .finished:
                break
            }
        }, receiveValue: {[weak self] result in
            guard let self = self else {return}
            self.keywordData = result.keywords
        })
        .store(in: &cancellables)
    }
}
