//
//  REShapeNode.swift
//  PeggleClone
//
//  Created by Kyle キラ on 8/2/22.
//

import UIKit

class RESceneNode {

    var name: String
    // The origin of the node (the Cartesian coordinate of the top left corner of the node's frame
    var position: CGPoint
    var center: CGPoint {
        let x = position.x + size.width / 2
        let y = position.y + size.height / 2
        return CGPoint(x: x, y: y)
    }
    var size: CGSize
    var anchorPoint = CGPoint(x: 0.5, y: 0.5)
    // The position formed by the origin and the specified anchor point
    var anchorPosition: CGPoint {
        let x = position.x + anchorPoint.x * size.width
        let y = position.y + anchorPoint.y * size.height
        return CGPoint(x: x, y: y)
    }
    var physicsBody: REPhysicsBody {
        didSet {
            physicsBody.node = self
        }
    }
    var scene: REScene?

    init(name: String, position: CGPoint,
         anchorPoint: CGPoint,
         physicsBody: REPhysicsBody, size: CGSize) {
        self.name = name
        self.position = position
        self.anchorPoint = anchorPoint
        self.physicsBody = physicsBody
        self.size = size
    }
}

extension RESceneNode: Equatable {
    // Compares the scene node by reference
    static func == (lhs: RESceneNode, rhs: RESceneNode) -> Bool {
        lhs === rhs
    }
}
