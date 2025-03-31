//
//  ReadingCoordinator.swift
//  LastPage
//
//  Created by 최정안 on 4/1/25.
//

import UIKit

final class ReadingCoordinator {
    private let navigationController: UINavigationController
    private let diContainer: AppDIContainer

    init(navigationController: UINavigationController, diContainer: AppDIContainer) {
        self.navigationController = navigationController
        self.diContainer = diContainer
    }

    func start() {
        let viewModel = ReadingViewModel(getGetBookUseCase: diContainer.makeGetBookUseCase)
        let readingVC = SearchViewController(viewModel: viewModel)
        readingVC.coordinator = self
        navigationController.pushViewController(readingVC, animated: true)
    }

    func showEditInfo() {
        let viewModel = EditInfoViewModel(makeGetBookUseCase: diContainer.makeGetBookUseCase())
        let editInfoVC = EditInfoViewController(viewModel: viewModel)
        navigationController.pushViewController(editInfoVC, animated: true)
    }

    func showEditReading() {
        let editReadingCoordinator = EditReadingCoordinator(navigationController: navigationController, diContainer: diContainer)
        editReadingCoordinator.start()
    }
    
    func showEditReadingInProgress() {
        let viewModel = EditReadingInProgressViewModel(makeGetBookUseCase: diContainer.makeGetBookUseCase())
        let editReadingInProgressVC = EditReadingInProgressViewController(viewModel: viewModel)
        navigationController.pushViewController(editReadingInProgressVC, animated: true)
    }
}


