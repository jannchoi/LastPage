//
//  ReadingCoordinator.swift
//  LastPage
//
//  Created by 최정안 on 4/1/25.
//

import UIKit

final class ReadingCoordinator:Coordinator {
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
        let viewModel = ReadingViewModel(getBookUseCase: diContainer.makeGetBookUseCase())
        let readingVC = ReadingViewController(viewModel: viewModel)
        readingVC.coordinator = self
        navigationController.pushViewController(readingVC, animated: true)
    }
    func start(bookId: String) {
        let viewModel = ReadingViewModel(bookId: bookId, getBookUseCase: diContainer.makeGetBookUseCase())
        let readingVC = ReadingViewController(viewModel: viewModel)
        readingVC.coordinator = self
        navigationController.pushViewController(readingVC, animated: true)
    }
    func start(bookDetail: BookDetail) {
        let viewModel = ReadingViewModel(bookDetail: bookDetail,getBookUseCase: diContainer.makeGetBookUseCase())
        let readingVC = ReadingViewController(viewModel: viewModel)
        readingVC.coordinator = self
        navigationController.pushViewController(readingVC, animated: true)
    }
    

    func showEditInfo(bookId: String? = nil) {
        let viewModel = EditInfoViewModel(bookId: bookId,getBookUseCase: diContainer.makeGetBookUseCase(),updateBookUsecase: diContainer.makeUpdateBookUseCase(),saveBookUsecase: diContainer.makeSaveBookUseCase() )
        let editInfoVC = EditInfoViewController(viewModel: viewModel)
        navigationController.pushViewController(editInfoVC, animated: true)
    }

    func showEditReading(bookId: String? = nil, status: UpdateTarget? = nil) {
        let editReadingCoordinator = EditReadingCoordinator(parentCoordinator: self,navigationController: navigationController, diContainer: diContainer)
        childCoordinators.append(editReadingCoordinator)
        editReadingCoordinator.start(bookId: bookId, status: status)
    }
    
    func showEditReadingInProgress(bookId: String? = nil, index: Int? = nil) {
        let viewModel = EditReadingInProgressViewModel(bookId: bookId,index: index ,getBookUseCase: diContainer.makeGetBookUseCase(),updateBookUsecase : diContainer.makeUpdateBookUseCase())
        let editReadingInProgressVC = EditReadingInProgressViewController(viewModel: viewModel)
        navigationController.pushViewController(editReadingInProgressVC, animated: true)
    }
    func popVC() {
        parentCoordinator?.removeChildCoordinator(self)
    }
}


