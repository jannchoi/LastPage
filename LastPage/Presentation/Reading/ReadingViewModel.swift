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
    let updateBookUsecase: UpdateBookUseCaseProtocol
    @Published var bookDetail: BookEntity?
    @Published var isLoading: Bool = false
    //@Published var error:
    var bookId : String?
    struct Input {

    }
    struct Output {
        
    }
    init(bookAddedSubject: PassthroughSubject<String, Never>, bookId: String? = nil, bookDetail: BookDetail? = nil, getBookUseCase: GetBookUseCaseProtocol, updateBookUsecase: UpdateBookUseCaseProtocol) {
        self.getBookUseCase = getBookUseCase
        self.updateBookUsecase = updateBookUsecase
        self.bookId = bookId
        bookAddedSubject.sink { newId in
            self.bookDetail?.id = newId
            self.fetchBook(itemId: newId)
        }.store(in: &cancellables)
        
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

        return Output()
    }
    func deleteBook(targetIdx: Int) {
        guard let bookDetail = bookDetail, let id = bookDetail.id else {return}
        updateBookUsecase.execute(bookId: id, field: .reading, newValue:  Optional<ProgressMemoEntity>.none, index: targetIdx)
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
