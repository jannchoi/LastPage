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
    @Published private(set) var bookDetail : [HomeBookEntity] = []
    @Published private(set) var sampleBook : HomeBookEntity?
    @Published private(set) var selectedTags = [String]()
    @Published private(set) var fetchError: String? = nil
    struct Input {
        
    }
    struct Output {
        
    }
    struct InternalData {
        let bookListSubject = [BookEntity]()
    }
    
    init(bookDeletedSubject : PassthroughSubject<Void, Never>, bookAddedSubject: PassthroughSubject<String, Never>, getAllBooksUseCase: GetAllBooksUseCaseProtocol) {
        self.getAllBooksUseCase = getAllBooksUseCase
        self.internalData = InternalData()
        bookAddedSubject.sink { _ in
            self.getBookData()
        }.store(in: &cancellables)
        bookDeletedSubject.sink {
            _ in
            print("home deleted")
            self.getBookData()
        }.store(in: &cancellables)
       
        
    }
    
    func transform(input: Input) -> Output {
        getBookData()
        return Output()
    }
    private func getBookData() {
        getAllBooksUseCase.excuteHome().sink { [weak self] completion in
            if case .failure(let error) = completion {
                self?.fetchError = TextResource.DataError.fetchError.text
            }
        } receiveValue: { [weak self] books in
            guard let self = self else {return}
            
            self.getRandomBook(bookList: books)
            self.sampleBook = books.last
        }
        .store(in: &cancellables)
    }
    private func getRandomBook(bookList: [HomeBookEntity]) {
        if !bookList.isEmpty {
            let shuffledBooks = bookList.shuffled().prefix(min(bookList.count, 10))
            bookDetail = Array(shuffledBooks)
            let randomFeelingList = shuffledBooks
                .compactMap { $0.bookDetail.feelings } 
                .flatMap { $0 }
                .shuffled()
                .prefix(12)
                .map { $0 }

            selectedTags = randomFeelingList
        }
       
        
    }
   
    
}

