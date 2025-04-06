//
//  ReadingCoordinator.swift
//  LastPage
//
//  Created by 최정안 on 4/1/25.
//

import UIKit
import Combine
final class ReadingCoordinator:Coordinator {
    private weak var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    private let navigationController: UINavigationController
    private let diContainer: AppDIContainer
    
    let bookAddedSubject : PassthroughSubject<String, Never>

    init(bookAddedSubject : PassthroughSubject<String, Never>, parentCoordinator: Coordinator?, navigationController: UINavigationController, diContainer: AppDIContainer) {
        self.parentCoordinator = parentCoordinator
        self.navigationController = navigationController
        self.diContainer = diContainer
        self.bookAddedSubject = bookAddedSubject
    }

    func start() {
        let viewModel = ReadingViewModel(bookAddedSubject: bookAddedSubject, getBookUseCase: diContainer.makeGetBookUseCase(), updateBookUsecase: diContainer.makeUpdateBookUseCase())
        let readingVC = ReadingViewController(viewModel: viewModel)
        readingVC.coordinator = self
        navigationController.pushViewController(readingVC, animated: true)
    }
    func start(bookId: String?) {
        let viewModel = ReadingViewModel(bookAddedSubject: bookAddedSubject, bookId: bookId, getBookUseCase: diContainer.makeGetBookUseCase(), updateBookUsecase: diContainer.makeUpdateBookUseCase())
        let readingVC = ReadingViewController(viewModel: viewModel)
        readingVC.coordinator = self
        navigationController.pushViewController(readingVC, animated: true)
    }
    func start(bookDetail: BookDetail) {
        let viewModel = ReadingViewModel(bookAddedSubject: bookAddedSubject, bookDetail: bookDetail,getBookUseCase: diContainer.makeGetBookUseCase(), updateBookUsecase: diContainer.makeUpdateBookUseCase())
        let readingVC = ReadingViewController(viewModel: viewModel)
        readingVC.coordinator = self
        navigationController.pushViewController(readingVC, animated: true)
    }
    

    func showEditInfo(passedBook: BookDetailEntity? = nil, bookId: String? = nil) {
        let editInfoCoordinator = EditInfoCoordinator(parentCoordinator: self, navigationController: navigationController, diContainer: diContainer, bookAddedSubject: bookAddedSubject)
        childCoordinators.append(editInfoCoordinator)
        editInfoCoordinator.start(passedBook: passedBook, bookId: bookId)
    }

    func showEditReading(bookId: String? = nil, status: UpdateTarget? = nil) {
        let editReadingCoordinator = EditReadingCoordinator(parentCoordinator: self,navigationController: navigationController, diContainer: diContainer, bookAddedSubject: bookAddedSubject)
        childCoordinators.append(editReadingCoordinator)
        editReadingCoordinator.start(bookId: bookId, status: status)
    }
    
    func showEditReadingInProgress(bookId: String?, index: Int? = nil) {
        let viewModel = EditReadingInProgressViewModel(bookId: bookId,index: index ,getBookUseCase: diContainer.makeGetBookUseCase(),updateBookUsecase : diContainer.makeUpdateBookUseCase())
        viewModel.bookAdded.sink { [weak self] bookId in
            guard let self = self else {return}
            self.bookAddedSubject.send(bookId)
        }
        .store(in: &viewModel.cancellables)
        let editReadingInProgressVC = EditReadingInProgressViewController(viewModel: viewModel)
        navigationController.pushViewController(editReadingInProgressVC, animated: true)
    }
    func popVC() {
        parentCoordinator?.removeChildCoordinator(self)
    }
}


