//
//  UIViewController+.swift
//  LastPage
//
//  Created by 최정안 on 4/3/25.
//

import UIKit

extension UIViewController  {
    func showAlert(text: String, action: (() -> Void)? = nil) {
    
        let alert = UIAlertController(title: TextResource.Global.alert.text, message: text, preferredStyle: .alert)
        var button : UIAlertAction
        if let action {
            button = UIAlertAction(title: "다시 시도하세요.", style: .default) { _ in
                action()
            }
        } else {
            button = UIAlertAction(title: TextResource.Global.cancel.text, style: .default)  { _ in
            }
        }

        alert.addAction(button)
        present(alert, animated: true)
    }
}
