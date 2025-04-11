//
//  LoadingIndicator.swift
//  LastPage
//
//  Created by 최정안 on 4/12/25.
//

import UIKit
final class LoadingIndicator: UIActivityIndicatorView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        guard let window = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
         
        let screenSize = window.screen.bounds
        self.frame = screenSize
    }
    
    private func configure() {
        color = UIColor.btnTint
        hidesWhenStopped = true
        style = UIActivityIndicatorView.Style.large
        stopAnimating()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
