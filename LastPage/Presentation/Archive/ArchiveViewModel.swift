//
//  ArchiveViewModel.swift
//  LastPage
//
//  Created by 최정안 on 4/1/25.
//

import Foundation
import Combine

final class ArchiveViewModel: BaseViewModel {
    var cancellables = Set<AnyCancellable>()
    let getAllBooksUseCase: GetAllBooksUseCaseProtocol
    let deleteBookUsecase: DeleteBookUseCaseProtocol
    let getBooksByStatusUseCase: GetBooksByStatusUseCaseProtocol
    let getBooksByCategoryUseCase: GetBooksByCategoryUseCaseProtocol
    let getBooksByFeelingUseCase: GetBooksByFeelingUseCaseProtocol
    
    
    @Published var bookList: [BookEntity] = []
    
    struct Input {
        
    }
    struct Output {
        
    }
    init(getAllBooksUseCase: GetAllBooksUseCaseProtocol,deleteBookUsecase: DeleteBookUseCaseProtocol, getBooksByStatusUseCase: GetBooksByStatusUseCaseProtocol, getBooksByCategoryUseCase: GetBooksByCategoryUseCaseProtocol, getBooksByFeelingUseCase: GetBooksByFeelingUseCaseProtocol) {
        self.getAllBooksUseCase = getAllBooksUseCase
        self.deleteBookUsecase = deleteBookUsecase
        self.getBooksByStatusUseCase = getBooksByStatusUseCase
        self.getBooksByCategoryUseCase = getBooksByCategoryUseCase
        self.getBooksByFeelingUseCase = getBooksByFeelingUseCase
        
        self.getAllBooks()
    }
    func transform(input: Input) -> Output {
        //
        return Output()
    }
    func deleteBook(index: Int) {
        guard let targetId = bookList[index].id else {return}
        deleteBookUsecase.execute(with: targetId)
        getAllBooks()
        
    }
    private func getAllBooks() {
        getAllBooksUseCase.execute().sink { [weak self] completion in
            if case .failure(let error) = completion {
                print("fetch error")
            }
        } receiveValue: { [weak self] books in
            guard let self = self else {return}
            
            self.bookList = books
            
        }
        .store(in: &cancellables)

    }
    
}
