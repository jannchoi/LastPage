//
//  NavigationBarStyleManager.swift
//  LastPage
//
//  Created by 최정안 on 5/5/25.
//

import UIKit

enum NavigationBarStyle {
    case `default`
    case blur
}

struct NavigationBarStyleManager {
    
    static func applyStyle(_ style: NavigationBarStyle, to navigationController: UINavigationController?) {
        guard let navigationBar = navigationController?.navigationBar else { return }
        
        let appearance = UINavigationBarAppearance()
        
        switch style {
        case .default:
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.backgroundBase // 배경색
            appearance.titleTextAttributes = [.foregroundColor: UIColor.mainText] // 제목 텍스트 색상
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.mainText]
            navigationBar.tintColor = .mainText
            

        case .blur:
            appearance.configureWithTransparentBackground() // 배경 투명 설정
            appearance.backgroundEffect = UIBlurEffect(style: .systemMaterial) // 블러 효과 추가
            appearance.backgroundColor = UIColor.backgroundBase.withAlphaComponent(0.3) // 약간 투명한 배경색
            appearance.titleTextAttributes = [.foregroundColor: UIColor.mainText]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.mainText]
            navigationBar.tintColor = .mainText
        }

        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.compactAppearance = appearance
    }
}

