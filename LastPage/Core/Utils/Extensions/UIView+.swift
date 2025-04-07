//
//  UIView+.swift
//  LastPage
//
//  Created by 최정안 on 4/6/25.
//

import UIKit
extension UIView {
    func makeShadow() {
        self.layer.cornerRadius = 12
        self.layer.shadowColor = UIColor.black.withAlphaComponent(0.1).cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = 3
    }
    
    func silverFrame(horizontalOnly: Bool = false) {
        // Remove existing gradient layers first to prevent duplicates
        self.layer.sublayers?.forEach { layer in
            if layer is CAGradientLayer {
                layer.removeFromSuperlayer()
            }
        }
        
        let gradient = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = [
            UIColor(white: 0.9, alpha: 1).cgColor,
            UIColor(white: 0.6, alpha: 1).cgColor,
            UIColor(white: 0.9, alpha: 1).cgColor
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        
        let shape = CAShapeLayer()
        shape.lineWidth = 1.5
        
        if horizontalOnly {
            // Create a path that only draws top and bottom lines
            let path = UIBezierPath()
            
            // Top line
            path.move(to: CGPoint(x: 0, y: 1))
            path.addLine(to: CGPoint(x: self.bounds.width, y: 1))
            
            // Bottom line
            path.move(to: CGPoint(x: 0, y: self.bounds.height - 1))
            path.addLine(to: CGPoint(x: self.bounds.width, y: self.bounds.height - 1))
            
            shape.path = path.cgPath
        } else {
            // Original rounded rect for all sides
            shape.path = UIBezierPath(roundedRect: self.bounds.insetBy(dx: 1, dy: 1),
                                      cornerRadius: 12).cgPath
        }
        
        shape.fillColor = UIColor.clear.cgColor
        shape.strokeColor = UIColor.black.cgColor
        
        gradient.mask = shape
        self.layer.addSublayer(gradient)
    }
}
