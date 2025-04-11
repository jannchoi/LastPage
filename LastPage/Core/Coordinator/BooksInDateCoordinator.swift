//
//  BooksInDateCoordinator.swift
//  LastPage
//
//  Created by 최정안 on 4/12/25.
//

import UIKit
import Combine
final class BooksInDateCoordinator: Coordinator {
    
    private weak var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    let navigationController: UINavigationController
    let diContainer: AppDIContainer
    let bookAddedSubject : PassthroughSubject<String, Never>
    let bookDeletedSubject : PassthroughSubject<Void, Never>

    init(bookDeletedSubject : PassthroughSubject<Void, Never>, bookAddedSubject : PassthroughSubject<String, Never>, parentCoordinator: Coordinator?, navigationController: UINavigationController, diContainer: AppDIContainer) {
        self.navigationController = navigationController
        self.diContainer = diContainer
        self.bookAddedSubject = bookAddedSubject
        self.bookDeletedSubject = bookDeletedSubject
    }
    func start(books: [HomeBookEntity]) {
        let viewModel = BooksInDateViewModel(books: books)
        let vc = BooksInDateViewController(viewModel: viewModel)
        vc.coordinator = self
        navigationController.present(vc, animated: true)
    }
    func showReading(bookId: String?) {
        let readingCoordinator = ReadingCoordinator(bookDeletedSubject : bookDeletedSubject,bookAddedSubject: bookAddedSubject,parentCoordinator: self,navigationController: navigationController, diContainer: diContainer)
        childCoordinators.append(readingCoordinator)
        readingCoordinator.start(bookId: bookId)
    }
  
}
