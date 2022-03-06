//
//  CGPoint+Extensions.swift
//  PeggleClone
//
//  Created by Kyle キラ on 10/2/22.
//

import UIKit

extension CGPoint {

    func minus(point: CGPoint) -> CGPoint {
        add(x: -point.x, y: -point.y)
    }

    func add(point: CGPoint) -> CGPoint {
        add(x: point.x, y: point.y)
    }

    func add(x: Double, y: Double) -> CGPoint {
        CGPoint(x: self.x + x, y: self.y + y)
    }

    func getDist(to point: CGPoint) -> Double {
        let dx = point.x - self.x
        let dy = point.y - self.y

        return sqrt(pow(dx, 2) + pow(dy, 2))
    }

    /*
     Finds foot of perpendicular, F, as follows:
     OF = (x1,y1) + λ(a,b), where λ is some constant
     OP = (x2,y2), OP is self
     PF = OF - OP
     ...
     λ = (a(x2-x1) + b(y2-y1)) / (a^2 + b^2)
     */
    func getFootOfPerpendicular(with line: ShapeLine) -> CGPoint {

        let startPoint = line.startPoint
        let vector = line.vector

        let a = vector.dx
        let b = vector.dy

        let x1 = startPoint.x
        let y1 = startPoint.y

        let x2 = self.x
        let y2 = self.y

        let constant = (a * (x2 - x1) + b * (y2 - y1)) / (pow(a, 2) + pow(b, 2))

        return CGPoint(
            x: x1 + constant * a,
            y: y1 + constant * b)
    }

    func liesOn(line: ShapeLine) -> Bool {

        let a = line.startPoint
        let b = line.endPoint
        let c = self

        let crossProduct = (c.y - a.y) * (b.x - a.x) - (c.x - a.x) * (b.y - a.y)

        let smallValue = 0.01
        if abs(crossProduct) > smallValue {
            return false}

        let dotProduct = (c.x - a.x) * (b.x - a.x) + (c.y - a.y) * (b.y - a.y)
        if dotProduct < 0 {
            return false
        }

        let squaredLength = (b.x - a.x) * (b.x - a.x) + (b.y - a.y) * (b.y - a.y)
        if dotProduct > squaredLength {
            return false
        }

        return true
    }
}

extension CGPoint: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.x)
        hasher.combine(self.y)
    }
}
