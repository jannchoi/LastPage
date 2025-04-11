//
//  EditReadingCoordinator.swift
//  LastPage
//
//  Created by 최정안 on 4/1/25.
//

import UIKit
import Combine

final class EditReadingCoordinator:Coordinator {

    
    private weak var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    private let navigationController: UINavigationController
    private let diContainer: AppDIContainer
    let bookAddedSubject : PassthroughSubject<String, Never>
    init(parentCoordinator: Coordinator?, navigationController: UINavigationController, diContainer: AppDIContainer, bookAddedSubject: PassthroughSubject<String, Never>) {
        self.parentCoordinator = parentCoordinator
        self.navigationController = navigationController
        self.diContainer = diContainer
        self.bookAddedSubject = bookAddedSubject
    }

    func start(bookId: String? = nil, status: UpdateTarget? = nil) {
        let viewModel = EditReadingViewModel(bookId: bookId, status: status, getBookUseCase: diContainer.makeGetBookUseCase(), updateBookUsecase: diContainer.makeUpdateBookUseCase())
        viewModel.bookAdded.sink { [weak self] bookId in
            guard let self = self else {return}
            self.bookAddedSubject.send(bookId)
        }
        .store(in: &viewModel.cancellables)
        let editReadingVC = EditReadingViewController(viewModel: viewModel)
        editReadingVC.coordinator = self
        navigationController.pushViewController(editReadingVC, animated: true)
    }

    func showRecommend(bookId: String) {
        let viewModel = RecommendViewModel(bookId: bookId,makeFetchKeywordUseCase: diContainer.makeFetchKeywordUseCase(), getBookUseCase: diContainer.makeGetBookUseCase())
        let recommendVC = RecommendViewController(viewModel: viewModel)
        navigationController.pushViewController(recommendVC, animated: true)
    }
    func popVC() {
        parentCoordinator?.removeChildCoordinator(self)
    }
}
