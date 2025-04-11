//
//  SearchBookViewModel.swift
//  LastPage
//
//  Created by 최정안 on 4/1/25.
//


import Foundation
import Combine

final class SearchBookViewModel: BaseViewModel {
    private let internalData: InternalData
    var cancellables = Set<AnyCancellable>()
    let fetchBookUseCase: FetchBookUseCaseProtocol
    @Published private(set) var bookList = BookInfo(totalResults: 0, startIndex: 0, itemsPerPage: 0, query: "", item: [])
    @Published private(set) var error: NetworkError?
    @Published private(set) var isLoading = false
    @Published private(set) var shouldScrollToTop = false
    
    private var currentQuery = ""
    private var page = 0
    
    struct Input {
        let query: PassthroughSubject<String, Never>
        let loadMoreTrigger: PassthroughSubject<Void, Never>
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
            .debounce(for: .milliseconds(300), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] query in
                guard let self = self else { return }
                // Reset page for new search query
                self.page = 0
                self.currentQuery = query
                self.shouldScrollToTop = true
                // Clear existing items for a new search
                self.bookList = BookInfo(totalResults: 0, startIndex: 0, itemsPerPage: 0, query: query, item: [])
                self.getBookData(query: query, page: self.page)
            }
            .store(in: &cancellables)
        
        input.loadMoreTrigger
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                // Check if more data is available
                let totalResults = self.bookList.totalResults
                let itemsPerPage = self.bookList.itemsPerPage
                let startIndex = self.bookList.startIndex
                let currentItems = self.bookList.item.count
                
                // Calculate the next start index based on current data
                let nextStartIndex = startIndex + currentItems
                
                // Only load more if we haven't reached the total results
                if nextStartIndex < totalResults && !self.isLoading {
                    self.page += 1
                    self.getBookData(query: self.currentQuery, page: self.page)
                }
            }
            .store(in: &cancellables)
        return Output()
    }
    
    private func getBookData(query: String, page: Int) {
        guard !isLoading else { return }
        
        isLoading = true
        
        fetchBookUseCase.execute(query: query, page: page)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                
                if case .failure(let error) = completion {
                    self.error = error
                }
            }, receiveValue: { [weak self] newBooks in
                guard let self = self else { return }
                self.isLoading = false
                
                if page > 0 {
                    // For pagination: append new items to existing list
                    var updatedItems = self.bookList.item
                    updatedItems.append(contentsOf: newBooks.item)
                    
                    self.bookList = BookInfo(
                        totalResults: newBooks.totalResults,
                        startIndex: newBooks.startIndex,
                        itemsPerPage: newBooks.itemsPerPage,
                        query: newBooks.query,
                        item: updatedItems
                    )
                } else {
                    // For first page: replace with new results
                    self.bookList = newBooks
                }
                
                // Reset the scroll flag after data is loaded
                if self.shouldScrollToTop {
                    self.shouldScrollToTop = false
                }
            })
            .store(in: &cancellables)
    }
}
