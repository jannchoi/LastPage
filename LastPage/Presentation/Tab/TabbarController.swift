//
//  TabbarController.swift
//  LastPage
//
//  Created by 최정안 on 4/5/25.
//

import UIKit
// MARK: - TabBarController
class MainTabBarController: UITabBarController {
    var coordinator: MainCoordinator?
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBar()
    }
    
    private func setupTabBar() {
        self.tabBar.tintColor = .systemBlue
    }
}
