//
//  ArchiveCoordinator.swift
//  LastPage
//
//  Created by 최정안 on 4/1/25.
//

import UIKit
import Combine

final class ArchiveCoordinator:Coordinator {
    private weak var parentCoordinator: Coordinator?
    var childCoordinators: [Coordinator] = []
    let navigationController: UINavigationController
    private let diContainer: AppDIContainer
    let bookAddedSubject : PassthroughSubject<String, Never>
    let bookDeletedSubject : PassthroughSubject<Void, Never>
    init(bookDeletedSubject : PassthroughSubject<Void, Never>,bookAddedSubject : PassthroughSubject<String, Never>, parentCoordinator: Coordinator?, navigationController: UINavigationController, diContainer: AppDIContainer) {
        self.parentCoordinator = parentCoordinator
        self.navigationController = navigationController
        self.diContainer = diContainer
        self.bookAddedSubject = bookAddedSubject
        self.bookDeletedSubject = bookDeletedSubject
    }

    func start() {
        let viewModel = ArchiveViewModel(bookDeletedSubject : bookDeletedSubject, bookAddedSubject: bookAddedSubject,
            getAllBooksUseCase: diContainer.makeGetAllBooksUseCase(), deleteBookUsecase: diContainer.makeDeleteBookUseCase())
        viewModel.bookDeleted.sink { [weak self] bookId in
            guard let self = self else {return}
            print("Archive deleted")
            self.bookDeletedSubject.send()
        }.store(in: &viewModel.cancellables)
        let archiveVC = ArchiveViewController(viewModel: viewModel)
        archiveVC.coordinator = self
        navigationController.pushViewController(archiveVC, animated: true)
    }

    func showReading(bookId: String?) {
        let readingCoordinator = ReadingCoordinator(bookDeletedSubject : bookDeletedSubject,bookAddedSubject: bookAddedSubject,parentCoordinator: self,navigationController: navigationController, diContainer: diContainer)
        childCoordinators.append(readingCoordinator)
        readingCoordinator.start(bookId: bookId)
    }
    func popVC() {
        parentCoordinator?.removeChildCoordinator(self)
    }

}

