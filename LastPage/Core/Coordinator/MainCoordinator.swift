//
//  MainCoordinator.swift
//  LastPage
//
//  Created by 최정안 on 4/1/25.
//

import UIKit

final class MainCoordinator:Coordinator {
    var childCoordinators: [Coordinator] = []
    private let navigationController: UINavigationController
    private let diContainer: AppDIContainer

    init(navigationController: UINavigationController, diContainer: AppDIContainer) {
        self.navigationController = navigationController
        self.diContainer = diContainer
    }

    func start() {
        let mainVC = ViewController()
        mainVC.coordinator = self
        navigationController.pushViewController(mainVC, animated: false)
    }

    func showArchive() {
        let archiveCoordinator = ArchiveCoordinator(parentCoordinator: self ,navigationController: navigationController, diContainer: diContainer)
        childCoordinators.append(archiveCoordinator)
        archiveCoordinator.start()
    }

    func showSearch() {
        let searchCoordinator = SearchCoordinator(parentCoordinator: self,navigationController: navigationController, diContainer: diContainer)
        childCoordinators.append(searchCoordinator)
        searchCoordinator.start()
    }
}
