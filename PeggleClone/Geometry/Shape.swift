//
//  Shape.swift
//  PeggleClone
//
//  Created by Kyle キラ on 24/2/22.
//

import UIKit

protocol Shape {
    var path: CGPath { get set }
    var position: CGPoint { get set }
}

extension Shape {

    var size: CGSize {
        path.boundingBox.size
    }
    var points: [CGPoint] {
        path.getPathElementsPoints()
    }
    var center: CGPoint {
        let origin = path.boundingBox.origin
        return CGPoint(
            x: origin.x + size.width / 2,
            y: origin.y + size.height / 2)
    }
    var lines: [LineSegment] {
        guard points.count > 1 else {
            return []
        }

        var lines = [LineSegment]()

        for i in 1...points.count {
            if i == points.count {
                let line = LineSegment(startPoint: points[i - 1], endPoint: points[0])
                lines.append(line)
                break
            }
            let line = LineSegment(startPoint: points[i - 1], endPoint: points[i])
            lines.append(line)
        }

        return lines
    }

    func intersects(withCircle circle: ShapeCircle) -> Bool {
        circle.intersects(withShape: self)
    }

    func intersects(withRect rect: ShapeRect) -> Bool {
        false
    }

    //https://stackoverflow.com/questions/753140/how-do-i-determine-if-two-convex-polygons-intersect
    func intersects(withShape shape: Shape) -> Bool {
        guard points.count > 2, shape.points.count > 2 else {
            return false
        }

        var hasIntersection = true

        for line in lines {
            let normalVector = line.normalVector
            let footsA: [CGPoint] = points.map {
                $0.getFootOfPerpendicular(with: normalVector.line)
            }

            let footsB: [CGPoint] = shape.points.map {
                $0.getFootOfPerpendicular(with: normalVector.line)
            }

            let multiplesA = footsA.map { foot -> Double in
                if normalVector.dx == 0 {
                    return foot.y / normalVector.dy
                }
                return foot.x / normalVector.dx
            }

            let multiplesB = footsB.map { foot -> Double in
                if normalVector.dx == 0 {
                    return foot.y / normalVector.dy
                }
                return foot.x / normalVector.dx
            }

            guard let minA = multiplesA.min(),
                  let maxA = multiplesA.max(),
                  let minB = multiplesB.min(),
                  let maxB = multiplesB.max() else {
                      continue
                  }

            let noOverlap = maxB < minA || maxA < minB
            if noOverlap {
                hasIntersection = false
            }
        }
        return hasIntersection
    }
}
