//
//  REPhysicsContatDelegate.swift
//  PeggleClone
//
//  Created by Kyle キラ on 8/2/22.
//

import UIKit

struct REPhysicsContact {
    let bodyA: REPhysicsBody
    let bodyB: REPhysicsBody
    let collisionImpulse: Double
    let contactNormal: CGVector
}

extension REPhysicsContact {
    var reverse: REPhysicsContact {
        REPhysicsContact(
            bodyA: bodyB, bodyB: bodyA,
            collisionImpulse: collisionImpulse,
            contactNormal: contactNormal.multiply(with: -1))
    }
}
