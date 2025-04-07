//
//  SettingViewController.swift
//  LastPage
//
//  Created by 최정안 on 4/5/25.
//

import UIKit
import SnapKit
import Combine

class SettingViewController: BaseViewController {
    weak var coordinator: SettingsCoordinator?
    var viewModel: SettingsViewModel
    private var cancellables: Set<AnyCancellable> = []
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SettingsCell")
        tableView.backgroundColor = .backgroundBase
        return tableView
    }()
    
    private let version = UILabel()
    
    init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
    }
    
    // MARK: - View 계층 구조 설정
    override func configureHierarchy() {
        view.addSubview(tableView)
        view.addSubview(version)
    }
    
    // MARK: - View 레이아웃 설정
    override func configureLayout() {
        tableView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(version.snp.top).offset(-20)
        }
        
        version.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-20)
        }
    }
    
    // MARK: - 프로퍼티 속성 설정
    override func configureView() {
        view.backgroundColor = .backgroundBase
        version.text = "Version 1.0.0"
        version.textColor = .secondaryLabel
        version.font = .systemFont(ofSize: 14)
    }
}

// MARK: - UITableViewDataSource
extension SettingViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)
        cell.accessoryType = .disclosureIndicator
        
        var content = cell.defaultContentConfiguration()
        switch indexPath.row {
        case 0:
            content.text = "Help & FAQ"
            content.image = UIImage(systemName: "questionmark.circle")
            content.textProperties.color = .mainText
        case 1:
            content.text = "About"
            content.image = UIImage(systemName: "info.circle")
            content.textProperties.color = .mainText
        case 2:
            content.text = "Reset"
            content.image = UIImage(systemName: "arrow.right.square")
            content.textProperties.color = .burgundy
            
        default:
            break
        }
        content.imageProperties.tintColor = .btnTint
        cell.contentConfiguration = content
        return cell
    }
}

// MARK: - UITableViewDelegate
extension SettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            coordinator?.showHelpFAQ()
        case 1:
            coordinator?.showAbout()
        case 2:
            showResetConfirmation()
        default:
            break
        }
    }
    
    private func showResetConfirmation() {
        let alert = UIAlertController(
            title: "초기화",
            message: "데이터를 초기화하시겠습니까? 다시 데이터를 되돌릴 수 없습니다.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel))
        alert.addAction(UIAlertAction(title: "초기화", style: .destructive) { [weak self] _ in
            guard let self = self else {return}
            self.viewModel.resetBooks()
        })
        
        present(alert, animated: true)
    }
}
