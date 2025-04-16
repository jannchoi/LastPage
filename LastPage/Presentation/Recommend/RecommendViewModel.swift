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
    let updateBookUsecase: UpdateBookUseCaseProtocol
    @Published private(set) var fetchError: String? = nil
    @Published var keywordData: [String]?
    @Published private(set) var error: NetworkError? = nil
    @Published var bookTitle: String?
    let bookId: String
    struct Input {
        
    }
    struct Output {
        
    }
    init(bookId: String, makeFetchKeywordUseCase: FetchKeywordUseCaseProtocol, getBookUseCase: GetBookUseCaseProtocol, updateBookUsecase: UpdateBookUseCaseProtocol) {
        self.makeFetchKeywordUseCase = makeFetchKeywordUseCase
        self.getBookUseCase = getBookUseCase
        self.updateBookUsecase = updateBookUsecase
        self.bookId = bookId
        self.fetchBook(itemId: self.bookId)
        
        
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
                self.bookTitle = book.bookDetail.title
                guard let booktitle = self.bookTitle else {return}
                if book.keywords.isEmpty {
                    self.fetchKeyword(query: booktitle)
                } else {
                    keywordData = book.keywords
                }
            }
            .store(in: &cancellables)
    }
    func fetchKeyword(query: String) {
        makeFetchKeywordUseCase.execute(prompt: query).receive(on: DispatchQueue.main)
            .sink(receiveCompletion: {[weak self] completion in
            switch completion {
            case .failure(let error):
                guard let self = self else {return}
                self.error = error
                self.keywordData = []
            case .finished:
                break
            }
        }, receiveValue: {[weak self] result in
            guard let self = self else {return}
            self.keywordData = result.keywords
            self.updateKeywords(newValue: self.keywordData)
        })
        .store(in: &cancellables)
    }
    func updateKeywords(newValue: [String]?) {
        updateBookUsecase.execute(bookId: bookId, field: .keywords, newValue: newValue, index: nil).sink { [weak self] completion in
            if case .failure(let error) = completion {
                self?.fetchError = TextResource.DataError.updateError.text
            }
        } receiveValue: {
            //
        }.store(in: &cancellables)
    }
}
