//
//  SearchCoordinator.swift
//  LastPage
//
//  Created by 최정안 on 4/1/25.
//

import UIKit

final class SearchCoordinator {
    private let navigationController: UINavigationController
    private let diContainer: AppDIContainer

    init(navigationController: UINavigationController, diContainer: AppDIContainer) {
        self.navigationController = navigationController
        self.diContainer = diContainer
    }

    func start() {
        let viewModel = SearchViewModel(fetchBookUseCase: diContainer.makeFetchBookUseCase())
        let searchVC = SearchViewController(viewModel: viewModel)
        searchVC.coordinator = self
        navigationController.pushViewController(searchVC, animated: true)
    }

    func showReading(bookId: String) {
        let readingCoordinator = ReadingCoordinator(navigationController: navigationController, diContainer: diContainer)
        readingCoordinator.start()
    }


}

