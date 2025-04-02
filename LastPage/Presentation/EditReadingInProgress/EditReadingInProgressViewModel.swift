//
//  EditReadingInProgressViewModel.swift
//  LastPage
//
//  Created by 최정안 on 4/1/25.
//

import Foundation
import Combine

final class EditReadingInProgressViewModel: BaseViewModel {
    var cancellables = Set<AnyCancellable>()
    let getBookUseCase: GetBookUseCaseProtocol
    let updateBookUsecase: UpdateBookUseCaseProtocol
    @Published var bookDetail: ProgressMemoEntity?
    let bookId : String?
    let index : Int?
    struct Input {
        
    }
    struct Output {
        
    }
    init(bookId: String? = nil, index: Int? = nil, getBookUseCase: GetBookUseCaseProtocol, updateBookUsecase: UpdateBookUseCaseProtocol) {
        self.getBookUseCase = getBookUseCase
        self.updateBookUsecase = updateBookUsecase
        self.bookId = bookId
        self.index = index
        if let bookId = bookId, let index = index{
            self.fetchBook(itemId: bookId, index: index)
        }
    }
    func transform(input: Input) -> Output {
        //
        return Output()
    }
    func saveBook<T>(newValue: T) {
        print(#function)
        if let bookId = bookId{
            updateBookUsecase.execute(bookId: bookId, field: .reading, newValue: newValue, index: index)
        }
    }
    private func fetchBook(itemId: String, index: Int) {
        getBookUseCase.execute(with: itemId)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    print("fetch error")
                }
            } receiveValue: { [weak self] book in
                guard let self = self, let book = book else {return}
                self.bookDetail = book.inProgressMemo[index]
            }
            .store(in: &cancellables)
    }
}
