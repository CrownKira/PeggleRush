//
//  Circle.swift
//  PeggleClone
//
//  Created by Kyle キラ on 10/2/22.
//

import UIKit

protocol ShapeCircle {
    var position: CGPoint { get set }
    var radius: Double { get set }
}

extension ShapeCircle {
    var diameter: Double {
        radius * 2
    }
    var size: CGSize {
        CGSize(width: diameter, height: diameter)
    }
    var frame: CGRect {
        CGRect(origin: position, size: size)
    }
    var center: CGPoint {
        let x = position.x + radius
        let y = position.y + radius
        return CGPoint(x: x, y: y)
    }

    func intersects(withCircle circle: ShapeCircle) -> Bool {
        let yDiff = center.y - circle.center.y
        let xDiff = center.x - circle.center.x

        // Computes diff using Pythagorean Theorem
        let diff = sqrt(pow(yDiff, 2) + pow(xDiff, 2))

        return diff < radius + circle.radius
    }

    func intersects(withRect rect: ShapeRect) -> Bool {
        let isCenterInRect = rect.isPointInRect(point: center)
        let intersectsWithTop = rect.topLine.intersects(with: self)
        let intersectsWithBottom = rect.bottomLine.intersects(with: self)
        let intersectsWithLeft = rect.leftLine.intersects(with: self)
        let intersectsWithRight = rect.rightLine.intersects(with: self)

        return isCenterInRect
        || intersectsWithTop
        || intersectsWithBottom
        || intersectsWithLeft
        || intersectsWithRight
    }

    func contains(point: CGPoint) -> Bool {
        self.center.getDist(to: point) <= self.radius
    }

    func intersects(withShape shape: Shape) -> Bool {
        let isCenterInShape = shape.path.contains(center)
        var hasIntersection = false

        for line in shape.lines {
            if line.intersects(with: self) {
                hasIntersection = true
                break
            }
        }

        return isCenterInShape || hasIntersection
    }

}
