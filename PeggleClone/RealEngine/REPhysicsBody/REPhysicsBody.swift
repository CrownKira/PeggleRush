//
//  REPhysicsBody.swift
//  PeggleClone
//
//  Created by Kyle キラ on 8/2/22.
//

import UIKit

protocol REPhysicsBody {

    var node: RESceneNode? { get set }
    var affectedByGravity: Bool { get set }
    var isDynamic: Bool { get set }
    var categoryBitMask: UInt32 { get set }
    var collisionBitMask: UInt32 { get set }
    var contactTestBitMask: UInt32 { get set }
    var velocity: CGVector { get set }
    var acceleration: CGVector { get set }
    var mass: Double { get set }
    var frameRate: Double { get set }
    var externalForce: CGVector { get set }
    var jointWith: RESpring? { get set }

    func getContact(with bodyB: REPhysicsBody, in scene: REScene) -> REPhysicsContact?
}

extension REPhysicsBody {
    var dynamicMass: Double {
        isDynamic ? mass : UserDefaults.standard.double(forKey: "immovableMass")
    }

    mutating func applyImpulse(_ impulse: CGVector) {
        externalForce = impulse.multiply(with: frameRate)
    }

    mutating func applyForce(_ force: CGVector) {
        externalForce = force
    }
}
