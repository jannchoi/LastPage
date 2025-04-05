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
    func saveImageToLocal(image: UIImage) -> String {
        // 1. 고유한 파일명 생성
        let fileName = UUID().uuidString + ".jpg"
        
        // 2. Documents 디렉토리 경로
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let fileURL = documentsDirectory.appendingPathComponent(fileName)
            
            // 3. 이미지 데이터 저장
            if let imageData = image.jpegData(compressionQuality: 0.8) {
                do {
                    try imageData.write(to: fileURL)
                    
                    // 4. 전체 경로 대신 파일명만 반환
                    return "local://\(fileName)"
                    
                } catch {
                    print("이미지 저장 실패: \(error)")
                }
            }
        }
        return ""
    }
}
