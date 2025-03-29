//
//  ArchiveViewController.swift
//  LastPage
//
//  Created by 최정안 on 3/29/25.
//

import UIKit

class ArchiveViewController: BaseViewController {
    private let filterButton = UIButton()
    private let filterMenu = UIMenu()
    private let searchBar = UISearchBar()
    private let tableView = UITableView()
    let list = Array(0...10)
    override func viewDidLoad() {
        super.viewDidLoad()
        temp()
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
    }
    func temp() {
        tableView.delegate = self
        tableView.dataSource = self
    }

}
extension ArchiveViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 152
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ArchiveTableViewCell.identifier, for: indexPath) as! ArchiveTableViewCell
        cell.configure(title: "", content: "", date: "")
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ReadingViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
}
