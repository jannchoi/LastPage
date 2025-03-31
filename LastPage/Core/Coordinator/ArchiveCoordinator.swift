//
//  ArchiveCoordinator.swift
//  LastPage
//
//  Created by 최정안 on 4/1/25.
//

import UIKit

final class ArchiveCoordinator {
    private let navigationController: UINavigationController
    private let diContainer: AppDIContainer

    init(navigationController: UINavigationController, diContainer: AppDIContainer) {
        self.navigationController = navigationController
        self.diContainer = diContainer
    }

    func start() {
        let viewModel = ArchiveViewModel(
            getAllBooksUseCase: diContainer.makeGetAllBooksUseCase,
            getBooksByStatusUseCase: diContainer.makeGetBooksByStatusUseCase,
            getBooksByCategoryUseCase: diContainer.makeGetBooksByCategoryUseCase,
            getBooksByFeelingUseCase: diContainer.makeGetBooksByFeelingUseCase
        )
        let archiveVC = ArchiveViewController(viewModel: viewModel)
        archiveVC.coordinator = self
        navigationController.pushViewController(archiveVC, animated: true)
    }

    func showReading(bookId: String) {
        let readingCoordinator = ReadingCoordinator(navigationController: navigationController, diContainer: diContainer)
        readingCoordinator.start()
    }

}

