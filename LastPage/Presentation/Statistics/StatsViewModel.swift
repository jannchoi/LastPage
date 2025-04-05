//
//  StatsViewModel.swift
//  LastPage
//
//  Created by 최정안 on 4/5/25.
//

import Foundation
import Combine

final class StatsViewModel:BaseViewModel {
    private let internalData : InternalData
    var cancellables = Set<AnyCancellable>()
    let getAllBooksUseCase: GetAllBooksUseCaseProtocol
    @Published private(set) var bookDetail : [BookDetailEntity] = []
    @Published private(set) var fetchError: String = ""
    @Published private(set) var bookStats: BookStats? = nil
    struct Input {
        
    }
    struct Output {
        
    }
    struct InternalData {

    }
    
    init(getAllBooksUseCase: GetAllBooksUseCaseProtocol) {
        self.getAllBooksUseCase = getAllBooksUseCase
        self.internalData = InternalData()
    }
    
    func transform(input: Input) -> Output {
        getBookData()
        return Output()
    }
    private func getBookData() {
        getAllBooksUseCase.execute().sink { [weak self] completion in
            if case .failure(let error) = completion {
                self?.fetchError = TextResource.DataError.fetchError.text
            }
        } receiveValue: { [weak self] books in
            guard let self = self else {return}
            self.getStats(books: books)
        }
        .store(in: &cancellables)
    }
    private func getStats(books: [BookEntity]) {
        let calendar = Calendar.current
        let now = Date()
        
        let validBooks = books.compactMap { $0.bookDetail.addedDate }

        let monthCount = validBooks.filter {
            calendar.isDate($0, equalTo: now, toGranularity: .month)
        }.count

        let yearCount = validBooks.filter {
            calendar.isDate($0, equalTo: now, toGranularity: .year)
        }.count

        let totalCount = validBooks.count

        bookStats = BookStats(monthCount: monthCount, yearCount: yearCount, totalCount: totalCount)
    }

    
}


