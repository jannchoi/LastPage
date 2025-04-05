//
//  BooksInDateViewModel.swift
//  LastPage
//
//  Created by 최정안 on 4/6/25.
//

import Combine
import Foundation

class BooksInDateViewModel {
    @Published var books: [HomeBookEntity]
    
    init(books: [HomeBookEntity]) {
        self.books = books
    }
}
