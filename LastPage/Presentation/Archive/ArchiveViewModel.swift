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
    struct Input {
        
    }
    struct Output {
        
    }
    init(getAllBooksUseCase: GetAllBooksUseCaseProtocol, getBooksByStatusUseCase: GetBooksByStatusUseCaseProtocol, getBooksByCategoryUseCase: GetBooksByCategoryUseCaseProtocol, getBooksByFeelingUseCase: GetBooksByFeelingUseCaseProtocol) {
        self.getAllBooksUseCase = getAllBooksUseCase
        self.getBooksByStatusUseCase = getBooksByStatusUseCase
        self.getBooksByCategoryUseCase = getBooksByCategoryUseCase
        self.getBooksByFeelingUseCase = getBooksByFeelingUseCase
    }
    func transform(input: Input) -> Output {
        //
        return Output()
    }
}
