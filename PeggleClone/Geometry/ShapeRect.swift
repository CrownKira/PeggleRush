//
//  Rectangle.swift
//  PeggleClone
//
//  Created by Kyle キラ on 10/2/22.
//

import UIKit

protocol ShapeRect {
    var position: CGPoint { get set }
    var size: CGSize { get set }
}

extension ShapeRect {
    var frame: CGRect {
        CGRect(origin: position, size: size)
    }
    var rightTopCorner: CGPoint {
        CGPoint(
            x: position.x + size.width,
            y: position.y)
    }

    var leftBottomCorner: CGPoint {
        CGPoint(
            x: position.x,
            y: position.y + size.height)
    }

    var rightBottomCorner: CGPoint {
        CGPoint(
            x: position.x + size.width,
            y: position.y + size.height)
    }

    var leftLine: ShapeLine {
        LineSegment(
            startPoint: position,
            endPoint: leftBottomCorner)
    }

    var rightLine: ShapeLine {
        LineSegment(
            startPoint: rightTopCorner,
            endPoint: rightBottomCorner)
    }

    var topLine: ShapeLine {
        LineSegment(
            startPoint: position,
            endPoint: rightTopCorner)
    }

    var bottomLine: ShapeLine {
        LineSegment(
            startPoint: leftBottomCorner,
            endPoint: rightBottomCorner)
    }

    var bottomBound: Double {
        position.y + size.height
    }

    var topBound: Double {
        position.y
    }

    var rightBound: Double {
        position.x + size.width
    }

    var leftBound: Double {
        position.x
    }

    var midX: Double {
        (leftBound + rightBound) / 2
    }

    var midY: Double {
        (topBound + bottomBound) / 2
    }

    var midPosition: CGPoint {
        CGPoint(x: midX, y: midY)
    }

    func isPointInRect(point: CGPoint) -> Bool {

        point.x >= leftBound
        && point.x <= rightBound
        && point.y >= topBound
        && point.y <= bottomBound

    }

    func intersects(withCircle circle: ShapeCircle) -> Bool {
        circle.intersects(withRect: self)
    }

    func intersects(withRect rectangle: ShapeRect) -> Bool {
        false
    }

    func intersects(withShape shape: Shape) -> Bool {
        false
    }
}
