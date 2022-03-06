//
//  Circle.swift
//  PeggleClone
//
//  Created by Kyle キラ on 10/2/22.
//

import UIKit

struct Circle: ShapeCircle {

    var radius: Double
    var position: CGPoint

    init(radius: Double, center: CGPoint) {
        assert(radius > 0)

        self.radius = radius
        self.position = CGPoint(x: center.x - radius, y: center.y - radius)
    }

}
