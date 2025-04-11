//
//  EditInfoCoordinator.swift
//  LastPage
//
//  Created by 최정안 on 4/6/25.
//

import UIKit
import Combine

final class EditInfoCoordinator:Coordinator {

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

    func start(passedBook: BookDetailEntity? = nil, bookId: String? = nil) {
        let viewModel = EditInfoViewModel(passedBook: passedBook ,bookId: bookId,getBookUseCase: diContainer.makeGetBookUseCase(),updateBookUsecase: diContainer.makeUpdateBookUseCase(),saveBookUsecase: diContainer.makeSaveBookUseCase() )
        viewModel.bookAdded.sink { [weak self] bookId in
            guard let self = self else {return}
            self.bookAddedSubject.send(bookId)
        }
        .store(in: &viewModel.cancellables)
        let editInfoVC = EditInfoViewController(viewModel: viewModel)
        editInfoVC.coordinator = self
        navigationController.pushViewController(editInfoVC, animated: true)
    }
    func showCategories() {
        let viewModel = CategoryListViewModel(type: .category)
        let vc = CategoryListViewController(viewModel: viewModel)

        if let editInfoVC = navigationController.viewControllers.last as? EditInfoViewController {
            vc.delegate = editInfoVC
        }

        navigationController.present(vc, animated: true)
    }
    func showFeelings() {
        let viewModel = CategoryListViewModel(type: .feeling)
        let vc = CategoryListViewController(viewModel: viewModel)

        if let editInfoVC = navigationController.viewControllers.last as? EditInfoViewController {
            vc.delegate = editInfoVC
        }
        navigationController.present(vc, animated: true)
    }

    func popVC() {
        parentCoordinator?.removeChildCoordinator(self)
    }
}
enum TagType {
    case category
    case feeling
}
