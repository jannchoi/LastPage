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
    }
    override func bind() {
        let input = SearchBookViewModel.Input(query: querySubject)
        let output = viewModel.transform(input: input)
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
//        let mockItem = BookDetail(title: "걸리버 여행기 (완역본)", link: "http://www.aladin.co.kr/shop/wproduct.aspx?ItemId=361171269&amp;copyPaper=1&amp;ttbkey=ttbgongjo36951633001&amp;start=api", author: "조너선 스위프트 지음, 강경숙 옮김", description: "", itemId: 361171269, cover: "https://image.aladin.co.kr/product/36117/12/coversum/k552038160_1.jpg", categoryName: "국내도서>소설/시/희곡>세계의 소설>아일랜드소설")
        coordinator?.showReading(bookDetail: item)
    }
    
    
}
