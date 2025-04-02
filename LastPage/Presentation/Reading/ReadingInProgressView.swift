//
//  ReadingInProgressView.swift
//  LastPage
//
//  Created by 최정안 on 4/2/25.
//

import UIKit
import SnapKit

// MARK: - InProgressView
class ReadingInProgressView: UIView{
    var isDeleteMode: Bool {
            get { return tableView.isEditing }
            set { tableView.setEditing(newValue, animated: true) }
        }
    
    private let tableView = UITableView()
    private var memoList = [ProgressMemoEntity]()
    weak var delegate: ReadingInProgressViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureHierarchy()
        configureLayout()
        setupTableView()
        loadSampleData()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func updateData(data: [ProgressMemoEntity]) {
        memoList = data
        tableView.reloadData()
    }
    private func configureHierarchy() {
        backgroundColor = .darkGray
        addSubview(tableView)
    }
    
    private func configureLayout() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(HighlightTableViewCell.self, forCellReuseIdentifier: HighlightTableViewCell.identifier)
        tableView.backgroundColor = .darkGray
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 200
        // Add this line for delete functionality
        tableView.allowsSelectionDuringEditing = true
    }
    func refreshTableViewForDeleteMode() {
            tableView.reloadData()
        }
    
    private func loadSampleData() {
        memoList = [
          
        ]
        tableView.reloadData()
    }
    
    // Method to add a new highlight
    func addHighlight(_ highlight: ProgressMemoEntity) {
        memoList.append(highlight)
        tableView.reloadData()
    }
}
// MARK: - TableView Delegate & DataSource
extension ReadingInProgressView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.readingInProgressView(self, didSelectItemAt: indexPath.row)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memoList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HighlightTableViewCell.identifier, for: indexPath) as? HighlightTableViewCell else {
            return UITableViewCell()
        }
        
        let item = memoList[indexPath.row]
        cell.configure(item: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    // Add to UITableViewDataSource implementation
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Remove the item from data source
            memoList.remove(at: indexPath.row)
            
            // Delete the row from the table
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    // Add to UITableViewDataSource implementation
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
   

}
protocol ReadingInProgressViewDelegate: AnyObject {
    func readingInProgressView(_ view: ReadingInProgressView, didSelectItemAt index: Int)
}


