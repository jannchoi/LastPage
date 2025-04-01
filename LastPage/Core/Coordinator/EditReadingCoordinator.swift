//
//  EditReadingCoordinator.swift
//  LastPage
//
//  Created by 최정안 on 4/1/25.
//

import UIKit

final class EditReadingCoordinator:Coordinator {
    private weak var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    private let navigationController: UINavigationController
    private let diContainer: AppDIContainer
    init(parentCoordinator: Coordinator?, navigationController: UINavigationController, diContainer: AppDIContainer) {
        self.parentCoordinator = parentCoordinator
        self.navigationController = navigationController
        self.diContainer = diContainer
    }

    func start() {
        let viewModel = EditReadingViewModel(makeGetBookUseCase: diContainer.makeGetBookUseCase())
        let editReadingVC = EditReadingViewController(viewModel: viewModel)
        editReadingVC.coordinator = self
        navigationController.pushViewController(editReadingVC, animated: true)
    }

    func showRecommend() {
        let viewModel = RecommendViewModel(makeFetchKeywordUseCase: diContainer.makeFetchKeywordUseCase())
        let recommendVC = RecommendViewController(viewModel: viewModel)
        navigationController.pushViewController(recommendVC, animated: true)
    }
    func popVC() {
        parentCoordinator?.removeChildCoordinator(self)
    }
}
