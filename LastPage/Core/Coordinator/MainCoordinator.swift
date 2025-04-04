//
//  MainCoordinator.swift
//  LastPage
//
//  Created by 최정안 on 4/1/25.
//

import UIKit

final class MainCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    private let window: UIWindow
    private let diContainer: AppDIContainer
    
    init(window: UIWindow, diContainer: AppDIContainer) {
        self.window = window
        self.diContainer = diContainer
    }

    func start() {
        let tabBarController = MainTabBarController()
        tabBarController.coordinator = self

        // 하위 Coordinator 연결
        let homeCoordinator = HomeCoordinator(navigationController: UINavigationController(), diContainer: diContainer)
        let archiveCoordinator = ArchiveCoordinator(parentCoordinator: self ,navigationController: UINavigationController(), diContainer: diContainer)
        let statsCoordinator = StatsCoordinator(parentCoordinator: self ,navigationController: UINavigationController(), diContainer: diContainer)
        let settingsCoordinator = SettingsCoordinator(parentCoordinator: self ,navigationController: UINavigationController(), diContainer: diContainer)

        childCoordinators = [homeCoordinator, archiveCoordinator, statsCoordinator, settingsCoordinator]

        // start() 호출로 각 루트 VC 준비
        homeCoordinator.start()
        archiveCoordinator.start()
        statsCoordinator.start()
        settingsCoordinator.start()

        tabBarController.setViewControllers([
            homeCoordinator.navigationController,
            archiveCoordinator.navigationController,
            statsCoordinator.navigationController,
            settingsCoordinator.navigationController
        ], animated: false)

        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
}
