//
//  CGVector+Extensions.swift
//  PeggleClone
//
//  Created by Kyle キラ on 10/2/22.
//

import UIKit

extension CGVector {

    var line: LineSegment {
        LineSegment(startPoint: CGPoint(), endPoint: CGPoint(x: dx, y: dy))
    }

    func dotProduct(with vector: CGVector) -> Double {
        self.dx * vector.dx + self.dy * vector.dy
    }

    func sum(with vector: CGVector) -> CGVector {
        CGVector(dx: self.dx + vector.dx, dy: self.dy + vector.dy)
    }

    func minus(with vector: CGVector) -> CGVector {
        self.sum(with: vector.multiply(with: -1))
    }

    func multiply(with multiple: Double) -> CGVector {
        CGVector(dx: multiple * self.dx, dy: multiple * self.dy)
    }

    func getPerpendicularDist(with vector: CGVector) -> Double {
        // Gets magnitude of normal vector
        let normal = self.dx * vector.dy + self.dy * vector.dx

        let perpendicularDist = normal / vector.getMagnitude()
        return perpendicularDist
    }

    func getMagnitude() -> Double {
        let x = self.dx
        let y = self.dy

        return sqrt(pow(x, 2) + pow(y, 2))
    }

    func getUnitVector() -> CGVector {
        let magnitude = self.getMagnitude()
        if magnitude == 0 {
            return CGVector()
        }
        return self.multiply(with: 1 / self.getMagnitude())
    }

}
