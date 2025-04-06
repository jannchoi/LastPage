//
//  SearchCoordinator.swift
//  LastPage
//
//  Created by 최정안 on 4/1/25.
//

import UIKit
import Combine

final class SearchCoordinator:Coordinator {
    private weak var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    private let navigationController: UINavigationController
    private let diContainer: AppDIContainer
    let bookAddedSubject : PassthroughSubject<String, Never>
    let bookDeletedSubject : PassthroughSubject<Void, Never>
    init(bookDeletedSubject : PassthroughSubject<Void, Never>, bookAddedSubject : PassthroughSubject<String, Never>,parentCoordinator: Coordinator?, navigationController: UINavigationController, diContainer: AppDIContainer) {
        self.parentCoordinator = parentCoordinator
        self.navigationController = navigationController
        self.diContainer = diContainer
        self.bookAddedSubject = bookAddedSubject
        self.bookDeletedSubject = bookDeletedSubject
    }

    func start() {
        let viewModel = SearchBookViewModel(fetchBookUseCase: diContainer.makeFetchBookUseCase())
        let searchVC = SearchBookViewController(viewModel: viewModel)
        searchVC.coordinator = self
        navigationController.pushViewController(searchVC, animated: true)
    }

    func showReading() {
        let readingCoordinator = ReadingCoordinator(bookDeletedSubject: bookDeletedSubject,bookAddedSubject : bookAddedSubject,parentCoordinator: self,navigationController: navigationController, diContainer: diContainer)
        childCoordinators.append(readingCoordinator)
        readingCoordinator.start()
    }
    func showReading(bookDetail: BookDetail) {
        let readingCoordinator = ReadingCoordinator(bookDeletedSubject: bookDeletedSubject, bookAddedSubject : bookAddedSubject,parentCoordinator: self,navigationController: navigationController, diContainer: diContainer)
        childCoordinators.append(readingCoordinator)
        readingCoordinator.start(bookDetail: bookDetail)
    }
    func popVC() {
        parentCoordinator?.removeChildCoordinator(self)
    }

}

