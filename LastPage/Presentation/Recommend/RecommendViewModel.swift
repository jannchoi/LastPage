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
        makeFetchKeywordUseCase.execute(prompt: query).sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                // 에러 처리
                print("Error fetching books: \(error.localizedDescription)")
            case .finished:
                break
            }
        }, receiveValue: { result in
            let bookKeywordMockData = [
                "우리는 불완전함 속에서 존재의 의미를 어떻게 찾을 수 있을까?",
                "왜 우리는 극단적인 고통을 묘사하는 소설을 통해 위로를 느끼는 걸까?",
                "역사", "비극적 아름다움", "예술", "비즈니스", "여행",
                "내가 느끼는 사회적 소외감", "철학",
                "왜 우리는 극단적인 고통을 묘사하는 소설을 통해 위로를 느끼는 걸까?",
                "죽음에 대한 관점이 변하면, 그 사람의 삶의 태도도 달라질까요?"
            ]
            self.keywordData = bookKeywordMockData
            //self.keywordData = result.keywords
        })
        .store(in: &cancellables)
    }
}
