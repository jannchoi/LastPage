//
//  MainCoordinator.swift
//  LastPage
//
//  Created by 최정안 on 4/1/25.
//

import UIKit

final class MainCoordinator {
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
        let archiveCoordinator = ArchiveCoordinator(navigationController: navigationController, diContainer: diContainer)
        archiveCoordinator.start()
    }

    func showSearch() {
        let searchCoordinator = SearchCoordinator(navigationController: navigationController, diContainer: diContainer)
        searchCoordinator.start()
    }
}
