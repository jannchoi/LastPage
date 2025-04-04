//
//  HomeViewModel.swift
//  LastPage
//
//  Created by 최정안 on 4/5/25.
//

import Foundation
import Combine

final class HomeViewModel:BaseViewModel {
    private let internalData : InternalData
    var cancellables = Set<AnyCancellable>()
    let getAllBooksUseCase: GetAllBooksUseCaseProtocol
    @Published private(set) var bookDetail : [BookDetailEntity] = []
    @Published private(set) var selectedTags = [String]()
    @Published private(set) var fetchError: String = ""
    struct Input {
        
    }
    struct Output {
        
    }
    struct InternalData {
        let bookListSubject = PassthroughSubject<[BookEntity], NetworkError>()
    }
    
    init(getAllBooksUseCase: GetAllBooksUseCaseProtocol) {
        self.getAllBooksUseCase = getAllBooksUseCase
        self.internalData = InternalData()
    }
    
    func transform(input: Input) -> Output {
        //
        return Output()
    }
    private func getBookData() {
        getAllBooksUseCase.execute().sink { [weak self] completion in
            if case .failure(let error) = completion {
                self?.fetchError = TextResource.DataError.fetchError.text
            }
        } receiveValue: { [weak self] books in
            guard let self = self else {return}
            
            self.internalData.bookListSubject.send(books)
            
        }
        .store(in: &cancellables)
    }
    
}

