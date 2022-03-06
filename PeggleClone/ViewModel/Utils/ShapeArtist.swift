//
//  ShapeArtist.swift
//  PeggleClone
//
//  Created by Kyle キラ on 24/2/22.
//

import UIKit

final class ShapeArtist {

    static func getImageView(on view: UIView, path: CGPath) -> UIImageView {
        let imageView = UIImageView(frame: path.boundingBox)
        let renderer = UIGraphicsImageRenderer(size: path.boundingBox.size)

        let img = renderer.image { ctx in
            let bezierPath = UIBezierPath()

            let points: [CGPoint] = path.getPathElementsPoints().map {
                let offSetX = path.boundingBox.origin.x
                let offSetY = path.boundingBox.origin.y

                return CGPoint(x: $0.x - offSetX, y: $0.y - offSetY)
            }
            for i in 0..<points.count {
                if i == 0 {
                    bezierPath.move(to: points[i])
                } else {
                    bezierPath.addLine(to: points[i])
                }
            }

            ctx.cgContext.setFillColor(UIColor.systemOrange.cgColor)
            ctx.cgContext.setStrokeColor(UIColor.black.cgColor)

            bezierPath.close()
            bezierPath.stroke()
            bezierPath.fill()
        }
        imageView.image = img
        return imageView
    }
}
