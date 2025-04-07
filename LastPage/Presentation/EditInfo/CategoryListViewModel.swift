//
//  CategoryListViewModel.swift
//  LastPage
//
//  Created by 최정안 on 4/6/25.
//


import Foundation
import Combine

final class CategoryListViewModel:BaseViewModel {
    var cancellables = Set<AnyCancellable>()

    @Published var categories: [String] = []
    let type : TagType
    struct Input {
        
    }
    struct Output {
        
    }
    struct InternalData {
        var bookList : [HomeBookEntity] = []
    }
    
    init(type: TagType) {
        self.type = type
        switch type {
        case .category:
            categories = TextDataStorage.allBookGenres
        case .feeling:
            categories = TextDataStorage.allFeelings
        }
        
    }
    func transform(input: Input) -> Output {
        //
        return Output()
    }
}

