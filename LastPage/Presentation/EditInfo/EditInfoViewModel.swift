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
    
    var bookAdded = PassthroughSubject<String, Never>()
    @Published private(set) var fetchError: String? = nil
    @Published var bookDetail: BookDetailEntity?
    @Published var popVCTrigger: String?
    var bookId : String?
    struct Input {
        
    }
    struct Output {
        
    }
    init(passedBook: BookDetailEntity? = nil, bookId: String? = nil, getBookUseCase: GetBookUseCaseProtocol, updateBookUsecase: UpdateBookUseCaseProtocol, saveBookUsecase: SaveBookUseCaseProtocol) {
        self.getBookUseCase = getBookUseCase
        self.updateBookUsecase = updateBookUsecase
        self.saveBookUsecase = saveBookUsecase
        self.bookId = bookId
        if let bookId = bookId {
            self.fetchBook(itemId: bookId)
        } else {
            self.bookDetail = passedBook

        }
    }
    func transform(input: Input) -> Output {
        //
        return Output()
    }
    func saveBook(newValue: BookDetailEntity) {
        if let bookId = bookId {
            updateBookUsecase.execute(bookId: bookId, field: .detail, newValue: newValue, index: nil).sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.fetchError = TextResource.DataError.updateError.text
                }
                } receiveValue: {[weak self] _ in
                    guard let self = self else {return}
                    
                    self.bookAdded.send(bookId)
                    self.fetchBook(itemId: bookId)
                    self.popVCTrigger = "저장되었습니다."
                    
                }.store(in: &cancellables)

        } else {
            let newBook = BookEntity(id: nil, bookDetail: newValue, inProgressMemo: [], keywords: [])
            saveBookUsecase.execute(newBook).sink { [weak self] completion in
            if case .failure(let error) = completion {
                self?.fetchError = TextResource.DataError.updateError.text
            }
            } receiveValue: {[weak self] newId in
                guard let self = self else {return}
                self.bookAdded.send(newId)
                self.popVCTrigger = "저장되었습니다."
                self.fetchBook(itemId: newId)

            }.store(in: &cancellables)

        }
        
    }
    private func fetchBook(itemId: String) {
        getBookUseCase.execute(with: itemId)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.fetchError = TextResource.DataError.fetchError.text
                }
            } receiveValue: { [weak self] book in
                guard let self = self, let book = book else {return}
                self.bookDetail = book.bookDetail

                
            }
            .store(in: &cancellables)
    }
}
