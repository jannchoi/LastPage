//
//  UIColor+.swift
//  LastPage
//
//  Created by 최정안 on 5/3/25.
//

import UIKit

extension UIColor {
    convenience init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let r = CGFloat((rgb & 0xff0000) >> 16) / 255
        let g = CGFloat((rgb & 0x00ff00) >> 8) / 255
        let b = CGFloat(rgb & 0x0000ff) / 255

        self.init(red: r, green: g, blue: b, alpha: 1)
    }
}
