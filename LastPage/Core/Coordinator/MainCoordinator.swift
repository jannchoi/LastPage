//
//  MainCoordinator.swift
//  LastPage
//
//  Created by 최정안 on 4/1/25.
//

import UIKit
import Combine

final class MainCoordinator: Coordinator {
    var childCoordinators: [Coordinator] = []
    private let window: UIWindow
    private let diContainer: AppDIContainer
    let bookAddedSubject = PassthroughSubject<String, Never>()
    let bookDeletedSubject = PassthroughSubject<Void, Never>()

    init(window: UIWindow, diContainer: AppDIContainer) {
        self.window = window
        self.diContainer = diContainer
    }

    func start() {
        let tabBarController = MainTabBarController()
        tabBarController.coordinator = self


        let homeCoordinator = HomeCoordinator(bookDeletedSubject : bookDeletedSubject,bookAddedSubject : bookAddedSubject,navigationController: UINavigationController(), diContainer: diContainer)
        let archiveCoordinator = ArchiveCoordinator(bookDeletedSubject : bookDeletedSubject, bookAddedSubject : bookAddedSubject, parentCoordinator: self ,navigationController: UINavigationController(), diContainer: diContainer)
        let statsCoordinator = StatsCoordinator(    bookDeletedSubject : bookDeletedSubject, bookAddedSubject : bookAddedSubject, parentCoordinator: self ,navigationController: UINavigationController(), diContainer: diContainer)
        let settingsCoordinator = SettingsCoordinator(bookDeletedSubject: bookDeletedSubject ,parentCoordinator: self ,navigationController: UINavigationController(), diContainer: diContainer)

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
