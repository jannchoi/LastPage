//
//  TextSelectionViewController.swift
//  LastPage
//
//  Created by 최정안 on 4/5/25.
//

import UIKit

// MARK: - TextSelectionViewController
protocol TextSelectionViewControllerDelegate: AnyObject {
    func didSelectTexts(_ texts: [String])
}

class TextSelectionViewController: UIViewController {
    private let textItems: [String]
    weak var delegate: TextSelectionViewControllerDelegate?
    var allowMultipleSelection: Bool = false
    
    private let tableView = UITableView()
    private var selectedRows = Set<IndexPath>()
    
    init(textItems: [String]) {
        self.textItems = textItems
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    private func setupView() {
        title = "문장 선택"
        view.backgroundColor = .white
        
        // Configure navigation bar
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: "취소",
            style: .plain,
            target: self,
            action: #selector(dismissView)
        )
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "적용",
            style: .done,
            target: self,
            action: #selector(applySelection)
        )
        
        // Configure table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TextCell")
        tableView.allowsMultipleSelection = allowMultipleSelection
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // Add instructions label
        let instructionLabel = UILabel()
        instructionLabel.text = allowMultipleSelection ?
            "원하는 문장을 여러 개 선택한 후 '적용'을 눌러주세요." :
            "원하는 문장을 선택해주세요."
        instructionLabel.textAlignment = .center
        instructionLabel.textColor = .mainText
        instructionLabel.font = .systemFont(ofSize: 14)
        instructionLabel.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        instructionLabel.numberOfLines = 0
        
        view.addSubview(instructionLabel)
        instructionLabel.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(44)
        }
        
        tableView.snp.remakeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(instructionLabel.snp.bottom)
        }
    }
    
    @objc private func dismissView() {
        dismiss(animated: true)
    }
    
    @objc private func applySelection() {
        var selectedTexts: [String] = []
        
        if allowMultipleSelection {
            let sortedSelectedRows = selectedRows.sorted(by: { $0.row < $1.row })
            for indexPath in sortedSelectedRows {
                selectedTexts.append(textItems[indexPath.row])
            }
        } else {
            if let selectedRow = tableView.indexPathForSelectedRow {
                selectedTexts.append(textItems[selectedRow.row])
            }
        }
        
        if !selectedTexts.isEmpty {
            delegate?.didSelectTexts(selectedTexts)
        }
        
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension TextSelectionViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return textItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TextCell", for: indexPath)
        cell.textLabel?.text = textItems[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        
        // Apply checkmark for multiple selection mode
        if allowMultipleSelection {
            cell.selectionStyle = .none
            cell.accessoryType = selectedRows.contains(indexPath) ? .checkmark : .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if allowMultipleSelection {
            // Toggle selection with checkmark
            if selectedRows.contains(indexPath) {
                selectedRows.remove(indexPath)
                tableView.cellForRow(at: indexPath)?.accessoryType = .none
            } else {
                selectedRows.insert(indexPath)
                tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
            }
        } else {
            // Single selection mode - immediately apply and dismiss
            delegate?.didSelectTexts([textItems[indexPath.row]])
            dismiss(animated: true)
        }
    }
}
