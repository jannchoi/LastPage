//
//  ArchiveCoordinator.swift
//  LastPage
//
//  Created by 최정안 on 4/1/25.
//

import UIKit

final class ArchiveCoordinator:Coordinator {
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
        let viewModel = ArchiveViewModel(
            getAllBooksUseCase: diContainer.makeGetAllBooksUseCase(), deleteBookUsecase: diContainer.makeDeleteBookUseCase(),
            getBooksByStatusUseCase: diContainer.makeGetBooksByStatusUseCase(),
            getBooksByCategoryUseCase: diContainer.makeGetBooksByCategoryUseCase(),
            getBooksByFeelingUseCase: diContainer.makeGetBooksByFeelingUseCase()
        )
        let archiveVC = ArchiveViewController(viewModel: viewModel)
        archiveVC.coordinator = self
        navigationController.pushViewController(archiveVC, animated: true)
    }

    func showReading(bookId: String?) {
        let readingCoordinator = ReadingCoordinator(parentCoordinator: self,navigationController: navigationController, diContainer: diContainer)
        childCoordinators.append(readingCoordinator)
        readingCoordinator.start(bookId: bookId)
    }
    func popVC() {
        parentCoordinator?.removeChildCoordinator(self)
    }

}

