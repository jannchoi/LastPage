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
    let updateBookUsecase: UpdateBookUseCaseProtocol
    
    @Published var bookDetail: MemoEntity?
    let bookId : String?
    let status : UpdateTarget?
    
    var bookAdded = PassthroughSubject<String, Never>()
    
    struct Input {
        
    }
    struct Output {
        
    }
    init(bookId: String? = nil, status: UpdateTarget? = nil, getBookUseCase: GetBookUseCaseProtocol, updateBookUsecase: UpdateBookUseCaseProtocol) {
        self.getBookUseCase = getBookUseCase
        self.updateBookUsecase = updateBookUsecase
        self.bookId = bookId
        self.status = status
        if let bookId = bookId, let status = status {
            self.fetchBook(itemId: bookId, status: status)
        }
        
    }
    func transform(input: Input) -> Output {
        //
        return Output()
    }
    func saveBook<T>(newValue: T) {
        if let bookId = bookId, let status = status {
            updateBookUsecase.execute(bookId: bookId, field: status, newValue: newValue, index: nil).sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("Update completed successfully")
                    case .failure(let error):
                        print("Update failed with error: \(error)")
                    }
                },
                receiveValue: {
                    [weak self] _ in
                        guard let self = self else {return}
                    self.bookAdded.send(bookId)
                }
            )
            .store(in: &cancellables)
        }
    }
    private func fetchBook(itemId: String, status: UpdateTarget) {
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
                case .detail:
                    return
                }
            }
            .store(in: &cancellables)
    }
}
