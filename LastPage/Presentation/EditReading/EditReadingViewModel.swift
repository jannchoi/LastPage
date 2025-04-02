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
    let getBookUseCase: GetBookUseCaseProtocol
    let saveBookUsecase: SaveBookUseCaseProtocol
    
    @Published var bookDetail: MemoEntity?
    
    struct Input {
        
    }
    struct Output {
        
    }
    init(bookId: String? = nil, status: ReadingStatusEntity? = nil, getBookUseCase: GetBookUseCaseProtocol, saveBookUsecase: SaveBookUseCaseProtocol) {
        self.getBookUseCase = getBookUseCase
        self.saveBookUsecase = saveBookUsecase
        if let bookId = bookId, let status = status {
            self.fetchBook(itemId: bookId, status: status)
        }
    }
    func transform(input: Input) -> Output {
        //
        return Output()
    }
    private func saveBook() {
        
    }
    private func fetchBook(itemId: String, status: ReadingStatusEntity) {
        getBookUseCase.execute(with: itemId)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    print("fetch error")
                }
            } receiveValue: { [weak self] book in
                guard let self = self, let book = book else {return}
                switch status {
                case .unread:
                    self.bookDetail = book.beforeMemo
                case .reading:
                    return
                case .completed:
                    self.bookDetail = book.afterMemo
                }
            }
            .store(in: &cancellables)
    }
}
