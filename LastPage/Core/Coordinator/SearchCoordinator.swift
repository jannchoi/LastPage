//
//  SearchCoordinator.swift
//  LastPage
//
//  Created by 최정안 on 4/1/25.
//

import UIKit

final class SearchCoordinator:Coordinator {
    private weak var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    private let navigationController: UINavigationController
    private let diContainer: AppDIContainer

    init(parentCoordinator: Coordinator?, navigationController: UINavigationController, diContainer: AppDIContainer) {
        self.parentCoordinator = parentCoordinator
        self.navigationController = navigationController
        self.diContainer = diContainer
    }

    func start() {
        let viewModel = SearchBookViewModel(fetchBookUseCase: diContainer.makeFetchBookUseCase())
        let searchVC = SearchBookViewController(viewModel: viewModel)
        searchVC.coordinator = self
        navigationController.pushViewController(searchVC, animated: true)
    }

    func showReading() {
        let readingCoordinator = ReadingCoordinator(parentCoordinator: self,navigationController: navigationController, diContainer: diContainer)
        childCoordinators.append(readingCoordinator)
        readingCoordinator.start()
    }
    func showReading(bookDetail: BookDetail) {
        let readingCoordinator = ReadingCoordinator(parentCoordinator: self,navigationController: navigationController, diContainer: diContainer)
        childCoordinators.append(readingCoordinator)
        readingCoordinator.start(bookDetail: bookDetail)
    }
    func popVC() {
        parentCoordinator?.removeChildCoordinator(self)
    }

}

