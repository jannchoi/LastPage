//
//  StatsViewModel.swift
//  LastPage
//
//  Created by 최정안 on 4/5/25.
//

import Foundation
import Combine

final class StatsViewModel:BaseViewModel {
    private var internalData : InternalData
    var cancellables = Set<AnyCancellable>()
    let getAllBooksUseCase: GetAllBooksUseCaseProtocol
    @Published private(set) var bookDetail : [HomeBookEntity]? = nil
    @Published private(set) var fetchError: String? = nil
    @Published private(set) var bookStats: BookStats? = nil
    struct Input {
        
    }
    struct Output {
        
    }
    struct InternalData {
        var bookList : [HomeBookEntity] = []
    }
    
    init(bookDeletedSubject : PassthroughSubject<Void, Never>, bookAddedSubject: PassthroughSubject<String, Never>, getAllBooksUseCase: GetAllBooksUseCaseProtocol) {
        self.getAllBooksUseCase = getAllBooksUseCase
        self.internalData = InternalData()
        bookAddedSubject.sink { _ in
            self.getBookData()
        }.store(in: &cancellables)
        bookDeletedSubject.sink{ _ in
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
            self.internalData.bookList = books
            self.getStats()
        }
        .store(in: &cancellables)
    }
    private func getStats() {
        if internalData.bookList.isEmpty {return}
        let calendar = Calendar.current
        let now = Date()
        
        let validBooks = internalData.bookList.compactMap { $0.bookDetail.addedDate }

        let monthCount = validBooks.filter {
            calendar.isDate($0, equalTo: now, toGranularity: .month)
        }.count

        let yearCount = validBooks.filter {
            calendar.isDate($0, equalTo: now, toGranularity: .year)
        }.count

        let totalCount = validBooks.count

        bookStats = BookStats(monthCount: monthCount, yearCount: yearCount, totalCount: totalCount)
    }
    func getBooksInDate(target: Date) {
        let calendar = Calendar.current
        let result = internalData.bookList.filter {
            guard let addedDate = $0.bookDetail.addedDate else { return false }
            return calendar.isDate(addedDate, inSameDayAs: target)
        }

        bookDetail = result
    }


    
}


