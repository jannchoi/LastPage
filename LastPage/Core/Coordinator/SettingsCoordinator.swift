//
//  SettingsCoordinator.swift
//  LastPage
//
//  Created by 최정안 on 4/5/25.
//

import UIKit
final class SettingsCoordinator: Coordinator {
    private weak var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    
    let navigationController: UINavigationController
    let diContainer: AppDIContainer

    init(parentCoordinator: Coordinator?, navigationController: UINavigationController, diContainer: AppDIContainer) {
        self.parentCoordinator = parentCoordinator
        self.navigationController = navigationController
        self.diContainer = diContainer
    }

    func start() {
        let viewModel = SettingsViewModel()
        let vc = SettingViewController(viewModel: viewModel)
        vc.coordinator = self
        navigationController.viewControllers = [vc]
    }

}

