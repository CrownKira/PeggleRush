//
//  CGPath+Extensions.swift
//  PeggleClone
//
//  Created by Kyle キラ on 24/2/22.
//

import UIKit

//https://stackoverflow.com/questions/12992462/how-to-get-the-cgpoints-of-a-cgpath
extension CGPath {

    func forEach( body: @escaping @convention(block) (CGPathElement) -> Void) {
        typealias Body = @convention(block) (CGPathElement) -> Void
        let callback: @convention(c) (
            UnsafeMutableRawPointer,
            UnsafePointer<CGPathElement>) -> Void = { info, element in
                let body = unsafeBitCast(info, to: Body.self)
                body(element.pointee)
            }

        let unsafeBody = unsafeBitCast(body, to: UnsafeMutableRawPointer.self)
        self.apply(info: unsafeBody, function: unsafeBitCast(callback, to: CGPathApplierFunction.self))
    }

    func getPathElementsPoints() -> [CGPoint] {
        var arrayPoints: [CGPoint]! = [CGPoint]()
        self.forEach { element in
            switch element.type {

            case CGPathElementType.moveToPoint:
                arrayPoints.append(element.points[0])

            case .addLineToPoint:
                arrayPoints.append(element.points[0])

            case .addQuadCurveToPoint:
                arrayPoints.append(element.points[0])
                arrayPoints.append(element.points[1])

            case .addCurveToPoint:
                arrayPoints.append(element.points[0])
                arrayPoints.append(element.points[1])
                arrayPoints.append(element.points[2])

            default:
                break

            }
        }
        return arrayPoints
    }

    func getPathElementsPointsAndTypes() -> ([CGPoint], [CGPathElementType]) {
        var arrayPoints: [CGPoint]! = [CGPoint]()
        var arrayTypes: [CGPathElementType]! = [CGPathElementType]()

        self.forEach { element in
            switch element.type {
            case .moveToPoint:
                arrayPoints.append(element.points[0])
                arrayTypes.append(element.type)
            case .addLineToPoint:
                arrayPoints.append(element.points[0])
                arrayTypes.append(element.type)
            default:
                break
            }
        }
        return (arrayPoints, arrayTypes)
    }

    func resized(to width: Double) -> CGPath {
        let scaleFactor = width / boundingBox.width
        let newBoundingBox = CGRect(
            origin: boundingBox.origin,
            size: CGSize(
                width: boundingBox.width * scaleFactor,
                height: boundingBox.height * scaleFactor))

        return resized(to: newBoundingBox)
    }

    //https://stackoverflow.com/questions/15643626/scale-cgpath-to-fit-uiview
    func resized(to rect: CGRect) -> CGPath {
        let boundingBox = self.boundingBox
        let boundingBoxAspectRatio = boundingBox.width / boundingBox.height
        let viewAspectRatio = rect.width / rect.height
        let scaleFactor = boundingBoxAspectRatio > viewAspectRatio
        ? rect.width / boundingBox.width
        : rect.height / boundingBox.height

        var transform = CGAffineTransform.identity
            .scaledBy(x: scaleFactor, y: scaleFactor)
        let newPath = copy(using: &transform)!
        let newPathAtOldPosition = newPath.translateTo(position: boundingBox.origin)

        return newPathAtOldPosition
    }

    func rotate(to degree: CGFloat) -> CGPath {
        let path = UIBezierPath(cgPath: self)
        let bounds: CGRect = path.cgPath.boundingBox
        let center = CGPoint(x: bounds.midX, y: bounds.midY)

        let radians = degree / 180.0 * .pi
        var transform: CGAffineTransform = .identity
        transform = transform.translatedBy(x: center.x, y: center.y)
        transform = transform.rotated(by: radians)
        transform = transform.translatedBy(x: -center.x, y: -center.y)
        path.apply(transform)
        return path.cgPath
    }

    func translateTo(position newPosition: CGPoint) -> CGPath {
        let oldPosition = self.boundingBox.origin
        let translation = newPosition.minus(point: oldPosition)
        let bezeirPath = UIBezierPath()

        bezeirPath.cgPath = self
        bezeirPath.apply(CGAffineTransform(translationX: translation.x, y: translation.y))

        return bezeirPath.cgPath
    }

    static func createIsoscelesTriangle(at center: CGPoint, size: CGSize) -> CGPath {

        let path = UIBezierPath()
        let origin = CGPoint(
            x: center.x - size.width / 2,
            y: center.y - size.height / 2)
        let pointA = CGPoint(
            x: center.x, y: origin.y)
        let pointB = CGPoint(
            x: origin.x, y: origin.y + size.height)
        let pointC = CGPoint(
            x: origin.x + size.width, y: origin.y + size.height)

        path.move(to: pointA)
        path.addLine(to: pointB)
        path.addLine(to: pointC)
        path.close()
        return path.cgPath
    }

    static func createPath(using points: [CGPoint]) -> CGPath {
        let path = UIBezierPath()

        for i in 0..<points.count {
            if i == 0 {
                path.move(to: points[i])
                continue
            }

            path.addLine(to: points[i])
        }
        path.close()
        return path.cgPath
    }
}
