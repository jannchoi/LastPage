//
//  HomeCoordinator.swift
//  LastPage
//
//  Created by 최정안 on 4/5/25.
//

import UIKit
final class HomeCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    
    let navigationController: UINavigationController
    let diContainer: AppDIContainer

    init(navigationController: UINavigationController, diContainer: AppDIContainer) {
        self.navigationController = navigationController
        self.diContainer = diContainer
    }

    func start() {
        let viewModel = HomeViewModel(getAllBooksUseCase: diContainer.makeGetAllBooksUseCase())
        let vc = HomeViewController(viewModel: viewModel)
        vc.coordinator = self
        navigationController.viewControllers = [vc]
    }
    func showReading(bookId: String?) {
        let readingCoordinator = ReadingCoordinator(parentCoordinator: self,navigationController: navigationController, diContainer: diContainer)
        childCoordinators.append(readingCoordinator)
        readingCoordinator.start(bookId: bookId)
    }

}
