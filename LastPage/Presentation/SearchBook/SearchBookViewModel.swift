//
//  SearchBookViewModel.swift
//  LastPage
//
//  Created by 최정안 on 4/1/25.
//

import Foundation
import Combine

final class SearchBookViewModel:BaseViewModel {
    private let internalData : InternalData
    var cancellables = Set<AnyCancellable>()
    let fetchBookUseCase: FetchBookUseCaseProtocol
    @Published private(set) var bookList = BookInfo(totalResults: 0, startIndex: 0, itemsPerPage: 0, query: "", item: [])
    @Published private(set) var error: NetworkError?
    struct Input {
        let query: PassthroughSubject<String, Never>
    }
    struct Output {
        
    }
    struct InternalData {
        let bookListSubject = PassthroughSubject<BookInfo, NetworkError>()
    }
    
    init(fetchBookUseCase: FetchBookUseCaseProtocol) {
        self.fetchBookUseCase = fetchBookUseCase
        self.internalData = InternalData()
    }
    
    func transform(input: Input) -> Output {
        
        input.query
            .debounce(for: .milliseconds(300) , scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink{ [weak self] query in
                guard let self = self else {return}
                self.getBookData(query: query)
                print(query)
            }.store(in: &cancellables)
        return Output()
    }
    private func getBookData(query: String) {
        print(query)
        fetchBookUseCase.execute(query: query).sink(receiveCompletion: { [weak self] completion in
            if case .failure(let error) = completion {
                guard let self = self else {return}
                self.error = error
            }
            
        },receiveValue: { [weak self] books in
            guard let self = self else {return}
            self.bookList = books
        }
        )
        .store(in: &cancellables)
    }
    
}
