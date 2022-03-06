//
//  Spring\.swift
//  PeggleClone
//
//  Created by Kyle キラ on 25/2/22.
//

import UIKit

struct RESpring {
    let jointAt: CGPoint
    let forceConstant: Double
    let physicsBody: REPhysicsBody?
    let dampingFactor: Double = 5.0
    var displacement: CGVector? {
        guard let physicsBody = physicsBody else {
            return nil
        }

        guard let position = physicsBody.node?.position else {
            return nil
        }

        let dx = position.x - jointAt.x
        let dy = position.y - jointAt.y
        return CGVector(dx: dx, dy: dy)
    }
}
