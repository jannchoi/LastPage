//
//  EditInfoViewModel.swift
//  LastPage
//
//  Created by 최정안 on 4/1/25.
//

import Foundation
import Combine
final class EditInfoViewModel:BaseViewModel {
    var cancellables = Set<AnyCancellable>()
    let getBookUseCase: GetBookUseCaseProtocol
    let updateBookUsecase: UpdateBookUseCaseProtocol
    let saveBookUsecase: SaveBookUseCaseProtocol
    
    @Published var bookDetail: BookDetailEntity?
    let bookId : String?
    struct Input {
        
    }
    struct Output {
        
    }
    init(bookId: String? = nil, getBookUseCase: GetBookUseCaseProtocol, updateBookUsecase: UpdateBookUseCaseProtocol, saveBookUsecase: SaveBookUseCaseProtocol) {
        self.getBookUseCase = getBookUseCase
        self.updateBookUsecase = updateBookUsecase
        self.saveBookUsecase = saveBookUsecase
        self.bookId = bookId
        if let bookId = bookId {
            self.fetchBook(itemId: bookId)
        }
    }
    func transform(input: Input) -> Output {
        //
        return Output()
    }
    func saveBook(newValue: BookDetailEntity) {
        print(#function)
        if let bookId = bookId {
            updateBookUsecase.execute(bookId: bookId, field: .detail, newValue: newValue, index: nil)
        } else {
            let newBook = BookEntity(id: nil, bookDetail: newValue, inProgressMemo: [])
            saveBookUsecase.execute(newBook)
        }
        
    }
    private func fetchBook(itemId: String) {
        getBookUseCase.execute(with: itemId)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    print("fetch error")
                }
            } receiveValue: { [weak self] book in
                guard let self = self, let book = book else {return}
                self.bookDetail = book.bookDetail
                
            }
            .store(in: &cancellables)
    }
}
