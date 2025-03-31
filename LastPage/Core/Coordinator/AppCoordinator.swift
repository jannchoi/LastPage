//
//  AppCoordinator.swift
//  LastPage
//
//  Created by 최정안 on 4/1/25.
//

import UIKit

final class AppCoordinator {
    private let window: UIWindow
    private let navigationController: UINavigationController
    private let diContainer: AppDIContainer

    init(window: UIWindow, diContainer: AppDIContainer) {
        self.window = window
        self.navigationController = UINavigationController()
        self.diContainer = diContainer
    }

    func start() {
        let mainCoordinator = MainCoordinator(navigationController: navigationController, diContainer: diContainer)
        mainCoordinator.start()
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}
