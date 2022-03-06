//
//  REShapeNode.swift
//  PeggleClone
//
//  Created by Kyle キラ on 24/2/22.
//

import UIKit

class REShapeNode: RESceneNode {

    var path: CGPath {
        didSet {
            let newPosition = path.boundingBox.origin
            if position != newPosition {
                position = newPosition
            }
        }
    }
    override var position: CGPoint {
        willSet {
            let newPath = path.translateTo(position: newValue)
            if path != newPath {
                path = newPath
            }
        }
    }

    init(path: CGPath, name: String, position: CGPoint,
         anchorPoint: CGPoint,
         physicsBody: REPhysicsBody, size: CGSize) {
        self.path = path

        super.init(
            name: name, position: position,
            anchorPoint: anchorPoint,
            physicsBody: physicsBody, size: size)

        self.position = position

    }
}
