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
        tableView.backgroundColor = .systemGroupedBackground
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
        view.backgroundColor = .white
        tabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gearshape"), tag: 3)
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
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)
        cell.accessoryType = .disclosureIndicator
        
        var content = cell.defaultContentConfiguration()
        
        switch indexPath.row {
        case 0:
            content.text = "Notifications"
            content.image = UIImage(systemName: "bell")
            
            let switchView = UISwitch()
            switchView.isOn = true
            switchView.onTintColor = .systemGreen
            switchView.addTarget(self, action: #selector(notificationSwitchChanged(_:)), for: .valueChanged)
            cell.accessoryView = switchView
            cell.accessoryType = .none
            
        case 1:
            content.text = "Help & FAQ"
            content.image = UIImage(systemName: "questionmark.circle")
            
        case 2:
            content.text = "About"
            content.image = UIImage(systemName: "info.circle")
            
        case 3:
            content.text = "Reset"
            content.image = UIImage(systemName: "arrow.right.square")
            content.textProperties.color = .systemRed
            
        default:
            break
        }
        
        cell.contentConfiguration = content
        return cell
    }
    
    @objc private func notificationSwitchChanged(_ sender: UISwitch) {
        print(#function)
    }
}

// MARK: - UITableViewDelegate
extension SettingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 1:
            print(#function)
        case 2:
            print(#function)
        case 3:
            showResetConfirmation()
        default:
            break
        }
    }
    
    private func showResetConfirmation() {
        let alert = UIAlertController(
            title: "Reset App",
            message: "Are you sure you want to reset the app? This action cannot be undone.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Reset", style: .destructive) { [weak self] _ in
            guard let self = self else {return}
            self.viewModel.resetBooks()
        })
        
        present(alert, animated: true)
    }
}
