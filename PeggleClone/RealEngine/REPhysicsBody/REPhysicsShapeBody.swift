//
//  REPhysicsShapeBody.swift
//  PeggleClone
//
//  Created by Kyle キラ on 8/2/22.
//

import UIKit

final class REPhysicsShapeBody: REPhysicsBody, Shape {

    var path: CGPath {
        didSet {
            if let node = (node as? REShapeNode) {
                node.path = path
            }
        }
    }
    var position = CGPoint() {
        didSet {
            self.node?.position = position
        }
    }
    var size: CGSize
    var node: RESceneNode? {
        didSet {
            if let position = node?.position {
                self.position = position
            }

            if let node = (node as? REShapeNode) {
                self.path = node.path
            }
        }
    }
    var affectedByGravity = false
    var isDynamic = false
    var categoryBitMask: UInt32 = 0xFFFFFFFF
    var collisionBitMask: UInt32 = 0xFFFFFFFF
    var contactTestBitMask: UInt32 = 0xFFFFFFFF
    var velocity = CGVector()
    var acceleration = CGVector()
    var mass = 1.0
    var frameRate: Double = 60.0
    var externalForce = CGVector()
    var jointWith: RESpring?

    init(size: CGSize, path: CGPath) {
        self.size = size
        self.path = path
    }

    func getContact(with bodyB: REPhysicsBody,
                    in scene: REScene) -> REPhysicsContact? {
        // Intersects with rect body
        if bodyB is REPhysicsShapeBody {
            return nil
        }

        // Intersects with circle body
        if let bodyB = bodyB as? REPhysicsCircleBody {
            let reversedContact = bodyB.getContact(with: self, in: scene)
            return reversedContact?.reverse
        }

        return nil
    }
}
