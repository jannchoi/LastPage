//
//  HomeCoordinator.swift
//  LastPage
//
//  Created by 최정안 on 4/5/25.
//

import UIKit
import Combine

final class HomeCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    
    let navigationController: UINavigationController
    let diContainer: AppDIContainer
    let bookAddedSubject : PassthroughSubject<String, Never>
    let bookDeletedSubject : PassthroughSubject<Void, Never>
    init(bookDeletedSubject : PassthroughSubject<Void, Never>, bookAddedSubject : PassthroughSubject<String, Never>,navigationController: UINavigationController, diContainer: AppDIContainer) {
        self.navigationController = navigationController
        self.diContainer = diContainer
        self.bookAddedSubject = bookAddedSubject
        self.bookDeletedSubject = bookDeletedSubject
    }

    func start() {
        let viewModel = HomeViewModel(bookDeletedSubject : bookDeletedSubject,bookAddedSubject :bookAddedSubject,getAllBooksUseCase: diContainer.makeGetAllBooksUseCase())
        let vc = HomeViewController(viewModel: viewModel)
        vc.coordinator = self
        navigationController.viewControllers = [vc]
    }
    func showReading(bookId: String?) {
        let readingCoordinator = ReadingCoordinator(bookDeletedSubject : bookDeletedSubject,bookAddedSubject: bookAddedSubject,parentCoordinator: self,navigationController: navigationController, diContainer: diContainer)
        childCoordinators.append(readingCoordinator)
        readingCoordinator.start(bookId: bookId)
    }
    func showSearch() {
        let searchCoordinator = SearchCoordinator(bookDeletedSubject: bookDeletedSubject, bookAddedSubject: bookAddedSubject,parentCoordinator: self, navigationController: navigationController, diContainer: diContainer)
        childCoordinators.append(searchCoordinator)
        searchCoordinator.start()
    }

}
