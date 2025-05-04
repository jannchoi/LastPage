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
    let deleteBookUsecase: DeleteBookUseCaseProtocol
    let fetchBackColorsUsecase: FetchBackColorsUseCaseProtocol
    var bookDeleted = PassthroughSubject<Void, Never>()
    var oldFeelings: [String] = []
    @Published var bookDetail: BookEntity?
    @Published var isLoading: Bool = false
    @Published private(set) var fetchError: String? = nil
    @Published var backColor: BackColorEntity?
    var bookId : String?
    struct Input {

    }
    struct Output {
        
    }
    init(bookAddedSubject: PassthroughSubject<String, Never>, bookId: String? = nil, bookDetail: BookDetail? = nil, getBookUseCase: GetBookUseCaseProtocol, updateBookUsecase: UpdateBookUseCaseProtocol, deleteBookUsecase: DeleteBookUseCaseProtocol, fetchBackColorsUsecase: FetchBackColorsUseCaseProtocol) {
        self.getBookUseCase = getBookUseCase
        self.updateBookUsecase = updateBookUsecase
        self.deleteBookUsecase = deleteBookUsecase
        self.fetchBackColorsUsecase = fetchBackColorsUsecase
        self.bookId = bookId
        bookAddedSubject.sink { newId in
            self.bookId = newId
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
    func deleteBook(targetId: String) {
        deleteBookUsecase.execute(with: targetId).sink { [weak self] completion in
            if case .failure(let error) = completion {
                self?.fetchError = TextResource.DataError.deleteError.text
            }
        } receiveValue: { [weak self] _ in
            guard let self = self else {return}
            self.bookDeleted.send(())
        }
        .store(in: &cancellables)
    }
    func deleteBook(targetIdx: Int) {
        guard let bookDetail = bookDetail, let id = bookDetail.id else {return}
        updateBookUsecase.execute(bookId: id, field: .reading, newValue:  Optional<ProgressMemoEntity>.none, index: targetIdx).sink(
            receiveCompletion: {[weak self] completion in
                guard let self = self else {return}
                switch completion {
                case .finished:
                    print("Update completed successfully")
                case .failure(let error):
                    self.fetchError = TextResource.DataError.updateError.text
                }
            },
            receiveValue: { [weak self] _ in
                guard let self = self else {return}
                self.bookDeleted.send(())
            }
        )
        .store(in: &cancellables)
    }
    private func fetchBook(itemId: String) {
        getBookUseCase.execute(with: itemId)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(_) = completion {
                    self?.fetchError = TextResource.DataError.fetchError.text
                }
            } receiveValue: { [weak self] book in
                guard let self = self, let book = book else { return }
                self.bookDetail = book
                
                let newFeelings = book.bookDetail.feelings
                let backgroundColor = book.bookDetail.backgroundColor
                
                let shouldFetch: Bool = (
                    backgroundColor == nil &&
                    !newFeelings.isEmpty &&
                    newFeelings != self.oldFeelings
                )
                
                if shouldFetch {
                    self.oldFeelings = newFeelings
                    self.fetchBackColors(newFeelings)
                }
            }
            .store(in: &cancellables)
    }

    private func fetchBackColors(_ feelings: [String]) {
        fetchBackColorsUsecase.execute(feelings: feelings)
            .sink { [weak self] completion in
                if case .failure( _) = completion {
                    self?.fetchError = TextResource.DataError.fetchError.text
                }
            } receiveValue: { [weak self]  backColorsEntity in
                guard let self = self else {return}
                self.backColor = backColorsEntity
                self.updateBackColor(backColorsEntity)
            }.store(in: &cancellables)

    }
    private func updateBackColor(_ target: BackColorEntity) {
        guard let newBookDetail = bookDetail, let bookId = bookId else {return}
        var newValue = newBookDetail.bookDetail
        newValue.backgroundColor = backColor
        updateBookUsecase.execute(bookId: bookId, field: .detail, newValue: newValue, index: nil).sink { [weak self] completion in
            if case .failure(_) = completion {
                self?.fetchError = TextResource.DataError.updateError.text
            }
            } receiveValue: { [weak self] _ in
                guard let self = self else {return}
                //
            }.store(in: &cancellables)

    }
    
}
