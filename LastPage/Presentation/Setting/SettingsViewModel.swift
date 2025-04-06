//
//  SettingsViewModel.swift
//  LastPage
//
//  Created by 최정안 on 4/5/25.
//

import Foundation
import Combine

final class SettingsViewModel:BaseViewModel {
    var cancellables = Set<AnyCancellable>()
    let resetBooksUsecase : DeleteBookUseCaseProtocol
    var bookDeleted = PassthroughSubject<Void, Never>()
    @Published private(set) var fetchError: String? = nil
    struct Input {
        
    }
    struct Output {
        
    }
    
    init(resetBookUsecase: DeleteBookUseCaseProtocol) {
        self.resetBooksUsecase = resetBookUsecase
    }
    
    func transform(input: Input) -> Output {
        //
        return Output()
    }
    func resetBooks() {
        resetBooksUsecase.execute().sink { [weak self] completion in
            if case .failure(let error) = completion {
                self?.fetchError = TextResource.DataError.deleteError.text
            }
        } receiveValue: { [weak self] _ in
            guard let self = self else {return}
            self.bookDeleted.send(())
        }
        .store(in: &cancellables)
    }
}
