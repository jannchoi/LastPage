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
    let getBookUseCase: GetBookUseCaseProtocol
    let viewWillAppearTrigger = PassthroughSubject<Void, Never>()
    @Published var bookDetail: BookEntity?
    @Published var isLoading: Bool = false
    //@Published var error:
    
    struct Input {

    }
    struct Output {
        
    }
    init(bookId: String? = nil, bookDetail: BookDetail? = nil, getBookUseCase: GetBookUseCaseProtocol) {
        self.getBookUseCase = getBookUseCase
        
        // bookId가 전달된 경우, ID로 데이터를 불러옴
        if let bookId = bookId {
            self.fetchBook(itemId: bookId)
        }
        // bookDetail이 전달된 경우, 해당 정보를 사용
        else if let bookDetail = bookDetail {
            self.bookDetail = BookEntityMapper.map(bookDetail)
        }
        // 아무 값도 전달되지 않은 경우, 기본값 설정
        else {
            self.bookDetail = BookEntityMapper.map()
        }
    }
    func transform(input: Input) -> Output {
        
        viewWillAppearTrigger.sink { [weak self]_ in
            guard let self = self, let book = self.bookDetail, let id = book.id else {return}
            self.fetchBook(itemId: id)
        }.store(in: &cancellables)
        
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
                self.bookDetail = book
                
            }
            .store(in: &cancellables)
    }
    
}
