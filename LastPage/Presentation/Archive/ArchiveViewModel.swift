//
//  ArchiveViewModel.swift
//  LastPage
//
//  Created by 최정안 on 4/1/25.
//

import Foundation
import Combine

final class ArchiveViewModel: BaseViewModel {
    private var internalData: InternalData
    var cancellables = Set<AnyCancellable>()
    let getAllBooksUseCase: GetAllBooksUseCaseProtocol
    let deleteBookUsecase: DeleteBookUseCaseProtocol
    var bookDeleted = PassthroughSubject<Void, Never>()
    @Published private(set) var fetchError: String? = nil
    
    @Published var bookList: [HomeBookEntity] = []
    @Published var categoryList: [String] = []
    @Published var feelingList: [String] = []
    
    // 검색 및 필터 관련 속성 추가
    @Published var searchQuery: String = ""
    @Published var selectedStatusTags: [ReadingStatusEntity] = []
    @Published var selectedCategoryTags: [String] = []
    @Published var selectedFeelingTags: [String] = []
    
    struct Input {
        let searchQueryPublisher: AnyPublisher<String, Never>
        let statusSelectionPublisher: AnyPublisher<[ReadingStatusEntity], Never>
        let categorySelectionPublisher: AnyPublisher<[String], Never>
        let feelingSelectionPublisher: AnyPublisher<[String], Never>
    }
    
    struct Output {
        let filteredBooks: AnyPublisher<[HomeBookEntity], Never>
    }
    
    struct InternalData {
        var bookList: [HomeBookEntity] = []
    }
    
    init(bookDeletedSubject : PassthroughSubject<Void, Never>, bookAddedSubject: PassthroughSubject<String, Never>,getAllBooksUseCase: GetAllBooksUseCaseProtocol, deleteBookUsecase: DeleteBookUseCaseProtocol) {
        self.getAllBooksUseCase = getAllBooksUseCase
        self.deleteBookUsecase = deleteBookUsecase
        self.internalData = InternalData()
        self.getAllBooks()
        bookAddedSubject.sink { _ in
            self.bookList = []
            self.getAllBooks()
        }.store(in: &cancellables)
        bookDeletedSubject.sink{ newId in
            self.getAllBooks()
        }.store(in: &cancellables)
    }
    
    func transform(input: Input) -> Output {
        let filteredBooks = Publishers.CombineLatest4(
            $searchQuery,
            $selectedStatusTags,
            $selectedCategoryTags,
            $selectedFeelingTags
        )
        .map { [weak self] (query, statusTags, categoryTags, feelingTags) -> [HomeBookEntity] in
            guard let self = self else { return [] }
            return self.filterBooks(
                query: query,
                statusTags: statusTags,
                categoryTags: categoryTags,
                feelingTags: feelingTags
            )
        }
        .eraseToAnyPublisher()
        
        return Output(filteredBooks: filteredBooks)
    }

    
    func deleteBook(index: Int) {
        if index >= bookList.count { return }
        
        deleteBookUsecase.execute(with: bookList[index].id).sink { [weak self] completion in
            if case .failure(let error) = completion {
                self?.fetchError = TextResource.DataError.deleteError.text
            }
        } receiveValue: { [weak self] _ in
            guard let self = self else {return}
            self.bookDeleted.send(())
        }
        .store(in: &cancellables)
        getAllBooks()
    }
    
    private func getAllBooks() {
        getAllBooksUseCase.excuteHome().sink { [weak self] completion in
            if case .failure(let error) = completion {
                self?.fetchError = TextResource.DataError.fetchError.text
            }
        } receiveValue: { [weak self] books in
            guard let self = self else { return }
            
            self.internalData.bookList = books
            // 초기에는 전체 데이터로 bookList 업데이트
            self.bookList = books
            // 모든 카테고리와 감정 추출
            self.getAllFilters()
        }
        .store(in: &cancellables)
    }
    
    private func getAllFilters() {
        // 모든 카테고리와 감정 가져오기 (중복 제거)
        var categorySet = Set<String>()
        var feelingSet = Set<String>()
        
        for book in internalData.bookList {
            categorySet.formUnion(book.bookDetail.categories)
            feelingSet.formUnion(book.bookDetail.feelings)
        }
        
        // Set → Array로 변환 후 정렬
        categoryList = Array(categorySet).sorted()
        feelingList = Array(feelingSet).sorted()
    }
    
    // 검색 쿼리 업데이트
    func updateSearchQuery(_ query: String) {
        searchQuery = query
        applyFilters()
    }
    
    // 읽기 상태 태그 토글
    func toggleStatusTag(_ status: ReadingStatusEntity) {
        if selectedStatusTags.contains(status) {
            selectedStatusTags.removeAll { $0 == status }
        } else {
            selectedStatusTags.append(status)
        }
        applyFilters()
    }
    
    // 카테고리 태그 토글
    func toggleCategoryTag(_ tag: String) {
        if selectedCategoryTags.contains(tag) {
            selectedCategoryTags.removeAll { $0 == tag }
        } else {
            selectedCategoryTags.append(tag)
        }
        applyFilters()
    }
    
    // 감정 태그 토글
    func toggleFeelingTag(_ tag: String) {
        if selectedFeelingTags.contains(tag) {
            selectedFeelingTags.removeAll { $0 == tag }
        } else {
            selectedFeelingTags.append(tag)
        }
        applyFilters()
    }
    
    // 모든 필터 적용 및 bookList 업데이트
    func applyFilters() {
        bookList = filterBooks(
            query: searchQuery,
            statusTags: selectedStatusTags,
            categoryTags: selectedCategoryTags,
            feelingTags: selectedFeelingTags
        )
    }
    
    // 모든 필터 초기화
    func clearFilters() {
        searchQuery = ""
        selectedStatusTags = []
        selectedCategoryTags = []
        selectedFeelingTags = []
        bookList = internalData.bookList
    }
    
    // 모든 기준에 따라 책 필터링
    private func filterBooks(query: String, statusTags: [ReadingStatusEntity], categoryTags: [String], feelingTags: [String]) -> [HomeBookEntity] {
        var filteredBooks = internalData.bookList
        
        // 검색어가 비어있지 않으면 검색 필터 적용
        if !query.isEmpty {
            filteredBooks = filteredBooks.filter { book in
                // 제목, 작가 등 관련 필드에서 검색
                return book.bookDetail.title.localizedCaseInsensitiveContains(query) ||
                       book.bookDetail.author.localizedCaseInsensitiveContains(query)
            }
        }
        
        // 상태 태그가 선택되었으면 상태 필터 적용
        if !statusTags.isEmpty {
            filteredBooks = filteredBooks.filter { book in
                return statusTags.contains(book.bookDetail.status)
            }
        }
        
        // 카테고리 태그가 선택되었으면 카테고리 필터 적용
        if !categoryTags.isEmpty {
            filteredBooks = filteredBooks.filter { book in
                // 책의 카테고리가 선택된 카테고리와 일치하는지 확인
                return !Set(book.bookDetail.categories).isDisjoint(with: Set(categoryTags))
            }
        }
        
        // 감정 태그가 선택되었으면 감정 필터 적용
        if !feelingTags.isEmpty {
            filteredBooks = filteredBooks.filter { book in
                // 책의 감정이 선택된 감정과 일치하는지 확인
                return !Set(book.bookDetail.feelings).isDisjoint(with: Set(feelingTags))
            }
        }
        
        return filteredBooks
    }
}
