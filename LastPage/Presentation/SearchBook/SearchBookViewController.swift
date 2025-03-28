//
//  SearchBookViewController.swift
//  LastPage
//
//  Created by 최정안 on 3/29/25.
//

import UIKit
import SnapKit

class SearchBookViewController: BaseViewController {
    private let tableView = UITableView()
    private let searchBar = UISearchBar()
    let list = Array(0...10)
    override func viewDidLoad() {
        super.viewDidLoad()
        temp()
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
        searchBar.backgroundColor = .blue
        tableView.backgroundColor = .yellow
        tableView.register(SearchBookTableViewCell.self, forCellReuseIdentifier: SearchBookTableViewCell.identifier)
    }
    func temp() {
        tableView.delegate = self
        tableView.dataSource = self
    }

}
extension SearchBookViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 152
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SearchBookTableViewCell.identifier, for: indexPath) as! SearchBookTableViewCell
        cell.configure(title: "", content: "", date: "")
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //
    }
    
    
}
