//
//  SearchBookViewController.swift
//  LastPage
//
//  Created by 최정안 on 3/29/25.
//

import UIKit
import SnapKit
import Combine

import RealmSwift

final class SearchBookViewController: BaseViewController {
    weak var coordinator: SearchCoordinator?
    var viewModel: SearchBookViewModel
    private let tableView = UITableView()
    private let searchBar = UISearchBar()
    private let plusButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.setTitleColor(.blue, for: .normal)
        return button
    }()
    private var cancellables: Set<AnyCancellable> = []
    private let testBookUseCase = FetchBookUseCase(bookRepository: MockBookRepository())
    private let testkeywordUseCaae = FetchKeywordUseCase(keywordRepository: MockKeywordRepository())
    
    private var querySubject = PassthroughSubject<String, Never>()

    init(viewModel: SearchBookViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    deinit {
        coordinator?.popVC()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
//        let realm = try! Realm()
//        
//        func getFileURL() {
//            print(realm.configuration.fileURL ?? "파일 경로를 찾을 수 없습니다.")
//        }
//        getFileURL()
        bind()

    }
    override func configureHierarchy() {
        view.addSubview(searchBar)
        view.addSubview(tableView)
    }
    override func configureLayout() {
        searchBar.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    override func configureView() {
        searchBar.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.backgroundColor = .blue
        tableView.backgroundColor = .yellow
        tableView.register(SearchBookTableViewCell.self, forCellReuseIdentifier: SearchBookTableViewCell.identifier)
        plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: plusButton)
    }
    @objc private func plusButtonTapped() {
        coordinator?.showReading()
    }
    override func bind() {
        let input = SearchBookViewModel.Input(query: querySubject)
        viewModel.$bookList
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
        viewModel.$error.compactMap{$0}
            .receive(on: DispatchQueue.main)
            .sink { networkError in
                print(networkError.errorMessage)
            }.store(in: &cancellables)
    }

}
// MARK: - SearchBar Delegate
extension SearchBookViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        if let text = searchBar.text, !text.isEmpty {
            querySubject.send(text)
        }
        searchBar.resignFirstResponder()
    }
}
// MARK: - TableView Delegate & DataSource
extension SearchBookViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 152
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.bookList.item.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchBookTableViewCell.identifier, for: indexPath) as! SearchBookTableViewCell
        let item = viewModel.bookList.item[indexPath.row]
        cell.configure(item: item)
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = viewModel.bookList.item[indexPath.row]
        coordinator?.showReading(bookDetail: item)
    }
    
    
}
