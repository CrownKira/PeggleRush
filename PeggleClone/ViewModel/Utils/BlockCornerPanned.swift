//
//  BlockCornerPanned.swift
//  PeggleClone
//
//  Created by Kyle キラ on 25/2/22.
//

import UIKit

struct BlockCornerPanned {
    let origin: CGPoint
    let location: CGPoint
    let blockView: UIImageView
    let blockViewModel: BlockViewModel
    let sender: UIPanGestureRecognizer

    var newPoints: [CGPoint] {
        var points = [CGPoint]()
        let trueOrigin = blockViewModel.getNearestCorner(to: origin)

        for point in blockViewModel.points {
            if point == trueOrigin {
                points.append(location)
            } else {
                points.append(point)
            }
        }

        return points
    }
    var newPath: CGPath {
        CGPath.createPath(using: newPoints)
    }

}
