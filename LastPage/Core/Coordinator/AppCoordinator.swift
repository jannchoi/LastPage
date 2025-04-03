//
//  AppCoordinator.swift
//  LastPage
//
//  Created by 최정안 on 4/1/25.
//

import UIKit

protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] {get set}
    func start()
}
extension Coordinator {
   func removeChildCoordinator(_ child: Coordinator) {
       for (index, coordinator) in childCoordinators.enumerated() {
           if coordinator === child {
               childCoordinators.remove(at: index)
               break
           }
       }
   }
}
final class AppCoordinator:Coordinator {
    var childCoordinators: [Coordinator] = []
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
        childCoordinators.append(mainCoordinator)
        mainCoordinator.start()
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}
