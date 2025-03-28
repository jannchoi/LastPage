//
//  Cell+.swift
//  LastPage
//
//  Created by 최정안 on 3/29/25.
//

import UIKit

protocol Identifier {
    static var identifier: String { get }
}

extension UICollectionViewCell: Identifier {
    static var identifier: String {
        return String(describing: self)
    }
    
}

extension UITableViewCell: Identifier {
    static var identifier: String {
        return String(describing: self)
    }
    
}
