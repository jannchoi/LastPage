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
    let getBooksByStatusUseCase: GetBooksByStatusUseCaseProtocol
    let getBooksByCategoryUseCase: GetBooksByCategoryUseCaseProtocol
    let getBooksByFeelingUseCase: GetBooksByFeelingUseCaseProtocol
    
    @Published var bookList: [BookEntity] = []
    
    struct Input {
        
    }
    struct Output {
        
    }
    init(getAllBooksUseCase: GetAllBooksUseCaseProtocol, getBooksByStatusUseCase: GetBooksByStatusUseCaseProtocol, getBooksByCategoryUseCase: GetBooksByCategoryUseCaseProtocol, getBooksByFeelingUseCase: GetBooksByFeelingUseCaseProtocol) {
        self.getAllBooksUseCase = getAllBooksUseCase
        self.getBooksByStatusUseCase = getBooksByStatusUseCase
        self.getBooksByCategoryUseCase = getBooksByCategoryUseCase
        self.getBooksByFeelingUseCase = getBooksByFeelingUseCase
        
        self.getAllBooks()
    }
    func transform(input: Input) -> Output {
        //
        return Output()
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
