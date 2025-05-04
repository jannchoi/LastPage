//
//  BackColorObject.swift
//  LastPage
//
//  Created by 최정안 on 5/4/25.
//

import RealmSwift
import CoreGraphics

class BackColorObject: EmbeddedObject {
    @Persisted var hexColors: List<String>
    @Persisted var startX: Double
    @Persisted var startY: Double
    @Persisted var endX: Double
    @Persisted var endY: Double
}

