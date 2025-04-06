//
//  SettingsCoordinator.swift
//  LastPage
//
//  Created by 최정안 on 4/5/25.
//

import UIKit
import Combine
final class SettingsCoordinator: Coordinator {
    private weak var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    
    let navigationController: UINavigationController
    let diContainer: AppDIContainer
    let bookDeletedSubject : PassthroughSubject<Void, Never>
    
    init(bookDeletedSubject : PassthroughSubject<Void, Never>, parentCoordinator: Coordinator?, navigationController: UINavigationController, diContainer: AppDIContainer) {
        self.parentCoordinator = parentCoordinator
        self.navigationController = navigationController
        self.diContainer = diContainer
        self.bookDeletedSubject = bookDeletedSubject
    }

    func start() {
        let viewModel = SettingsViewModel(resetBookUsecase: diContainer.makeDeleteBookUseCase())
        viewModel.bookDeleted.sink { [weak self] _ in
            guard let self = self else {return}
            self.bookDeletedSubject.send(())
        }.store(in: &viewModel.cancellables)
        let vc = SettingViewController(viewModel: viewModel)
        vc.coordinator = self
        navigationController.viewControllers = [vc]
    }

}

