//
//  StatsCoordinator.swift
//  LastPage
//
//  Created by 최정안 on 4/5/25.
//

import UIKit
import Combine
final class StatsCoordinator: Coordinator {
    private weak var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    
    let navigationController: UINavigationController
    let diContainer: AppDIContainer
    let bookAddedSubject : PassthroughSubject<String, Never>
    let bookDeletedSubject : PassthroughSubject<Void, Never>
    init(bookDeletedSubject : PassthroughSubject<Void, Never>, bookAddedSubject : PassthroughSubject<String, Never>, parentCoordinator: Coordinator?, navigationController: UINavigationController, diContainer: AppDIContainer) {
        self.parentCoordinator = parentCoordinator
        self.navigationController = navigationController
        self.diContainer = diContainer
        self.bookAddedSubject = bookAddedSubject
        self.bookDeletedSubject = bookDeletedSubject
    }

    func start() {
        let viewModel = StatsViewModel(bookDeletedSubject : bookDeletedSubject, getAllBooksUseCase: diContainer.makeGetAllBooksUseCase() )
        let vc = StatisticsViewController(viewModel: viewModel)
        vc.coordinator = self
        navigationController.viewControllers = [vc]
    }
    func showBooksInDate(books: [HomeBookEntity]) {
        let viewModel = BooksInDateViewModel(books: books)
        let vc = BooksInDateViewController(viewModel: viewModel)
        
        navigationController.present(vc, animated: true)
        
    }

}

