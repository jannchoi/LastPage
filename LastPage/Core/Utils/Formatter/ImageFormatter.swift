//
//  ImageFormatter.swift
//  LastPage
//
//  Created by 최정안 on 4/5/25.
//

import UIKit
import Kingfisher
class ImageFormatter {
    static let shared = ImageFormatter()
    private init ( ){ }
    @MainActor
    func setImage(target: UIImageView, path: String?) {
        guard let path = path, !path.isEmpty else {
            target.image = UIImage(systemName: "person")
            return
        }

        if path.hasPrefix("https://"), let url = URL(string: path) {
            target.kf.setImage(with: url, placeholder: UIImage(systemName: "person"))
        } else if path.hasPrefix("local://") {
            let fileName = path.replacingOccurrences(of: "local://", with: "")
            if let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileURL = documentPath.appendingPathComponent(fileName)
                if let image = UIImage(contentsOfFile: fileURL.path) {
                    target.image = image
                } else {
                    target.image = UIImage(systemName: "person")
                }
            }
        } else {
            target.image = UIImage(systemName: "person")
        }
    }

}
