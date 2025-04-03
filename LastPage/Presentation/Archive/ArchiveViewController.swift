//
//  ArchiveViewController.swift
//  LastPage
//
//  Created by 최정안 on 3/29/25.
//

import UIKit
import Combine

final class ArchiveViewController: BaseViewController {
    weak var coordinator: ArchiveCoordinator?
    var viewModel: ArchiveViewModel
    private var cancellables: Set<AnyCancellable> = []
    private let filterButton = UIButton()
    private let filterMenu = UIMenu()
    private let searchBar = UISearchBar()
    private let tableView = UITableView()
    let list = Array(0...10)
    
    deinit {
        coordinator?.popVC()
    }
    init(viewModel: ArchiveViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    override func bind() {
        viewModel.$bookList
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.tableView.reloadData()
            }
            .store(in: &cancellables)
    }
    override func configureHierarchy() {
        view.addSubview(searchBar)
        view.addSubview(tableView)
        view.addSubview(filterButton)
    }
    override func configureLayout() {
        searchBar.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(view.safeAreaLayoutGuide)
        }
        filterButton.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(8)
            make.height.equalTo(40)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(16)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(filterButton.snp.bottom).offset(8)
            make.horizontalEdges.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
    override func configureView() {
        searchBar.backgroundColor = .blue
        tableView.backgroundColor = .yellow
        tableView.register(ArchiveTableViewCell.self, forCellReuseIdentifier: ArchiveTableViewCell.identifier)
        filterButton.setTitle("filterBy", for: .normal)
        filterButton.backgroundColor = .systemMint
        tableView.delegate = self
        tableView.dataSource = self
    }


}
extension ArchiveViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 152
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.bookList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ArchiveTableViewCell.identifier, for: indexPath) as! ArchiveTableViewCell
        let item = viewModel.bookList[indexPath.row]
        cell.configure(item: item)
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let targetId = viewModel.bookList[indexPath.row].id
        coordinator?.showReading(bookId: targetId)
    }
    
    
}
