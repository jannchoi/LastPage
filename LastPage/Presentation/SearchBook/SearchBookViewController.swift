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
    private let plusButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.setTitleColor(.blue, for: .normal)
        return button
    }()
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    private var cancellables: Set<AnyCancellable> = []
    private var querySubject = PassthroughSubject<String, Never>()
    private var loadMoreSubject = PassthroughSubject<Void, Never>()

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
    }
    
    override func configureHierarchy() {
        view.addSubview(searchBar)
        view.addSubview(tableView)
        view.addSubview(loadingIndicator)
    }
    
    override func configureLayout() {
        searchBar.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        loadingIndicator.snp.makeConstraints { make in
            make.center.equalTo(tableView)
        }
    }
    
    override func configureView() {
        view.backgroundColor = .backgroundBase
        navigationItem.title = "Search"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(backButtonTapped))
        
        searchBar.delegate = self
        searchBar.placeholder = TextResource.Placeholder.bookSearch.text
        searchBar.barTintColor = .backgroundBase
        searchBar.searchBarStyle = .minimal
        searchBar.backgroundColor = .clear
        
        tableView.delegate = self
        tableView.dataSource = self
        searchBar.backgroundColor = .backgroundBase
        tableView.backgroundColor = .backgroundBase
        tableView.register(SearchBookTableViewCell.self, forCellReuseIdentifier: SearchBookTableViewCell.identifier)
        
        // Add loading footer view
        tableView.tableFooterView = createLoadingFooterView()
        
        plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: plusButton)
    }
    
    private func createLoadingFooterView() -> UIView {
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 50))
        let spinner = UIActivityIndicatorView(style: .medium)
        footerView.addSubview(spinner)
        spinner.center = footerView.center
        spinner.startAnimating()
        footerView.isHidden = true
        return footerView
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func plusButtonTapped() {
        coordinator?.showReading()
    }
    
    override func bind() {
        let input = SearchBookViewModel.Input(
            query: querySubject,
            loadMoreTrigger: loadMoreSubject
        )
        let output = viewModel.transform(input: input)
        
        viewModel.$bookList
            .receive(on: DispatchQueue.main)
            .sink { [weak self] bookList in
                print(bookList.item.count)
                self?.tableView.reloadData()
                self?.updateFooterVisibility(isEmpty: bookList.item.isEmpty)
            }
            .store(in: &cancellables)
        
        viewModel.$error.compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] networkError in
                self?.showAlert(text: networkError.errorMessage)
            }
            .store(in: &cancellables)
        
        viewModel.$isLoading
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoading in
                if isLoading {
                    self?.loadingIndicator.startAnimating()
                } else {
                    self?.loadingIndicator.stopAnimating()
                }
            }
            .store(in: &cancellables)
        
        viewModel.$shouldScrollToTop
            .filter { $0 }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.scrollToTop()
            }
            .store(in: &cancellables)
    }
    
    private func scrollToTop() {
        if !viewModel.bookList.item.isEmpty {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
    }
    
    private func updateFooterVisibility(isEmpty: Bool) {
        tableView.tableFooterView?.isHidden = isEmpty
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        view.endEditing(true)
        
        // Check if user has scrolled near the bottom to trigger pagination
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let screenHeight = scrollView.frame.height
        
        // When the user scrolls to the bottom (with some threshold)
        if offsetY > contentHeight - screenHeight - 150 {
            // Check if there are more items to load based on the BookInfo data
            let totalResults = viewModel.bookList.totalResults
            let currentItemCount = viewModel.bookList.item.count
            
            if currentItemCount < totalResults && !viewModel.isLoading {
                loadMoreSubject.send(())
            }
        }
    }
}
