//
//  BackColorDTO.swift
//  LastPage
//
//  Created by 최정안 on 5/3/25.
//

import Foundation
struct BackColorDTO: Decodable {
    let colors: [String]
    let startPoint: Point
    let endPoint: Point

    struct Point: Decodable {
        let x: CGFloat
        let y: CGFloat
    }
}
extension BackColorDTO {
    func toEntity() -> BackColorEntity {
        print(self)
        return BackColorEntity(
            hexColors: self.colors,
            startPoint: CGPoint(x: self.startPoint.x, y: self.startPoint.y),
            endPoint: CGPoint(x: self.endPoint.x, y: self.endPoint.y)
        )
    }
}
