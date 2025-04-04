//
//  StatsCoordinator.swift
//  LastPage
//
//  Created by 최정안 on 4/5/25.
//

import UIKit
final class StatsCoordinator: Coordinator {
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
        let viewModel = StatsViewModel(getAllBooksUseCase: diContainer.makeGetAllBooksUseCase() )
        let vc = StatisticsViewController(viewModel: viewModel)
        vc.coordinator = self
        navigationController.viewControllers = [vc]
    }

}

