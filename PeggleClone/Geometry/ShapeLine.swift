//
//  ShapeLine.swift
//  PeggleClone
//
//  Created by Kyle キラ on 10/2/22.
//

import UIKit

protocol ShapeLine {
    var startPoint: CGPoint { get set }
    var endPoint: CGPoint { get set }
}

extension ShapeLine {
    var dx: Double {
        endPoint.x - startPoint.x
    }

    var dy: Double {
        endPoint.y - startPoint.y
    }

    var magnitude: Double {
        let x = self.dx
        let y = self.dy

        return sqrt(pow(x, 2) + pow(y, 2))
    }

    // Gets the vector formed by the line's magnitude and direction
    var vector: CGVector {
        CGVector(dx: dx, dy: dy)
    }

    var unitVector: CGVector {
        vector.getUnitVector()
    }

    var gradient: Double {
        dy / dx
    }

    var normalVector: CGVector {
        CGVector(dx: -gradient, dy: 1)
    }

    func intersects(with circle: ShapeCircle) -> Bool {
        let footOfPerpendicular = circle
            .center
            .getFootOfPerpendicular(with: self)

        // Checks if foot of perpendicular lies on the line and is within circle
        let footLiesOnLine = footOfPerpendicular.liesOn(line: self)
        let footInCircle = circle.center.getDist(to: footOfPerpendicular) <= circle.radius
        let intersectsAtTwoPoints = footLiesOnLine && footInCircle
        // Otherwise, checks the two ends of the line
        let startPointInCircle = circle.contains(point: startPoint)
        let endPointInCircle = circle.contains(point: endPoint)

        return intersectsAtTwoPoints || startPointInCircle || endPointInCircle
    }
}
