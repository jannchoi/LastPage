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
    @Published var keywordData: [String]?
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
                    print("fetch error")
                }
            } receiveValue: { [weak self] book in
                guard let self = self, let book = book else {return}
                self.fetchKeyword(query: book.bookDetail.title)

            }
            .store(in: &cancellables)
    }
    private func fetchKeyword(query: String) {
        makeFetchKeywordUseCase.execute(prompt: query).receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                // 에러 처리
                print("Error fetching books: \(error.localizedDescription)")
            case .finished:
                break
            }
        }, receiveValue: { result in
            self.keywordData = result.keywords
        })
        .store(in: &cancellables)
    }
}
