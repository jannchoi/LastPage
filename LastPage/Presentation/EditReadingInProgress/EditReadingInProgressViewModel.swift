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
    @Published var bookTitle: String?
    let bookId : String?
    let index : Int?
    @Published private(set) var fetchError: String?
    var bookAdded = PassthroughSubject<String, Never>()
    @Published var popVCTrigger: String?
    
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
    func saveBook(newValue: ProgressMemoEntity) {
        if let bookId = bookId{
            updateBookUsecase.execute(bookId: bookId, field: .reading, newValue: newValue, index: index) .sink(
                receiveCompletion: {[weak self] completion in
                    guard let self = self else {return}
                    switch completion {
                    case .finished:
                        print("Update completed successfully")
                    case .failure(let error):
                        self.fetchError = TextResource.DataError.updateError.text
                    }
                },
                receiveValue: {
                    [weak self] _ in
                        guard let self = self else {return}
                    self.bookAdded.send(bookId)
                    self.popVCTrigger = "저장되었습니다"
                    guard let index = index else {return}
                    self.fetchBook(itemId: bookId, index: index)
                }
            )
            .store(in: &cancellables)
        }
    }
    private func fetchBook(itemId: String, index: Int) {
        getBookUseCase.execute(with: itemId)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.fetchError = TextResource.DataError.fetchError.text
                }
            } receiveValue: { [weak self] book in
                guard let self = self, let book = book else {return}
                self.bookTitle = book.bookDetail.title
                if index < book.inProgressMemo.count {
                    self.bookDetail = book.inProgressMemo[index]
                } else {
                    self.bookDetail = nil
                }
                
            }
            .store(in: &cancellables)
    }
}
