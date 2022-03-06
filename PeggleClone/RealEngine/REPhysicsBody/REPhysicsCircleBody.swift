//
//  REPhysicsCircleBody.swift
//  PeggleClone
//
//  Created by Kyle キラ on 8/2/22.
//

import UIKit

final class REPhysicsCircleBody: REPhysicsBody, ShapeCircle {

    var position: CGPoint {
        didSet {
            self.node?.position = position
        }
    }
    var radius: Double
    var node: RESceneNode? {
        didSet {
            guard let position = node?.position else {
                return
            }
            self.position = position
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

    init(radius: Double, position: CGPoint = CGPoint()) {
        assert(radius >= 0)

        self.radius = radius
        self.position = position
    }

    func getContact(
        with bodyB: REPhysicsBody,
        in scene: REScene) -> REPhysicsContact? {

            // Intersects with rect body
            if let bodyB = bodyB as? REPhysicsRectBody {
                return getContact(withRectBody: bodyB, in: scene)
            }

            // Intersects with circle body
            if let bodyB = bodyB as? REPhysicsCircleBody {
                return getContact(withCircleBody: bodyB, in: scene)
            }

            // Intersects with circle body
            if let bodyB = bodyB as? REPhysicsShapeBody {
                return getContact(withShapeBody: bodyB, in: scene)
            }

            return nil

        }

    private func getContact(withShapeBody bodyB: REPhysicsShapeBody, in scene: REScene) -> REPhysicsContact? {

        guard bodyB.points.count > 2 else {
            return nil
        }

        guard let node = node, let nodeB = bodyB.node else {
            return nil
        }

        guard let contactNormal = getContactNormalWithShape(bodyB: bodyB) else {
            return nil
        }

        let collisionImpulse = getCollisionImpulse(
            bodyA: self,
            bodyB: bodyB,
            contactNormal: contactNormal,
            restitution: scene.physicsWorld.impactRestitution)

        return REPhysicsContact(
            bodyA: node.physicsBody,
            bodyB: nodeB.physicsBody,
            collisionImpulse: collisionImpulse,
            contactNormal: contactNormal)
    }

    private func getContactNormalWithShape(bodyB: REPhysicsShapeBody) -> CGVector? {

        guard self.intersects(withShape: bodyB) else {
            return nil
        }

        for line in bodyB.lines {

            if line.intersects(with: self) {
                let foot = self.center.getFootOfPerpendicular(with: line)
                let normalUnitVector = LineSegment(startPoint: foot, endPoint: self.center).unitVector

                return normalUnitVector
            }
        }

        for point in bodyB.points {
            if self.contains(point: point) {
                let normalUnitVector = LineSegment(startPoint: point, endPoint: center).unitVector
                return normalUnitVector

            }
        }

        return nil
    }

    private func getContact(
        withRectBody bodyB: REPhysicsRectBody,
        in scene: REScene) -> REPhysicsContact? {
            guard let node = node, let nodeB = bodyB.node else {
                return nil
            }

            guard let contactNormal = getContactNormalWithRect(bodyB: bodyB) else {
                return nil
            }

            let collisionImpulse = getCollisionImpulse(
                bodyA: self,
                bodyB: bodyB,
                contactNormal: contactNormal,
                restitution: scene.physicsWorld.impactRestitution)

            return REPhysicsContact(
                bodyA: node.physicsBody,
                bodyB: nodeB.physicsBody,
                collisionImpulse: collisionImpulse,
                contactNormal: contactNormal)
        }

    private func getContactNormalWithRect(bodyB: REPhysicsRectBody) -> CGVector? {

        guard let node = node, let nodeB = bodyB.node else {
            return nil
        }

        guard self.intersects(withRect: bodyB) else {
            return nil
        }
        // Computes the contact normal
        var contactNormal = CGVector()
        let onTop = node.center.y <= nodeB.position.y
        let onBottom = node.center.y >= nodeB.position.y + nodeB.size.height
        let onRight = node.center.x >= nodeB.center.x
        let onLeft  = node.center.x <= nodeB.center.x
        let onRightBound = node.center.x >= nodeB.position.x + nodeB.size.width
        let onLeftBound  = node.center.x <= nodeB.position.x

        if onTop {
            if onRightBound {
                contactNormal = LineSegment(startPoint: bodyB.rightTopCorner, endPoint: center).unitVector
            } else if onLeftBound {
                contactNormal = LineSegment(startPoint: bodyB.position, endPoint: center).unitVector
            } else {
                contactNormal.dy -= 1
            }
        } else if onBottom {
            if onRightBound {
                contactNormal = LineSegment(startPoint: bodyB.rightBottomCorner, endPoint: center).unitVector
            } else if onLeftBound {
                contactNormal = LineSegment(startPoint: bodyB.leftBottomCorner, endPoint: center).unitVector
            } else {
                contactNormal.dy += 1
            }
        } else if onRight {
            contactNormal.dx += 1
        } else if onLeft {
            contactNormal.dx -= 1
        }

        return contactNormal
    }

    private func getContact(
        withCircleBody bodyB: REPhysicsCircleBody,
        in scene: REScene) -> REPhysicsContact? {

            guard let node = node, let nodeB = bodyB.node else {
                return nil
            }

            guard self.intersects(withCircle: bodyB) else {
                return nil
            }

            let contactNormal = LineSegment(startPoint: nodeB.center, endPoint: node.center).unitVector

            let collisionImpulse = getCollisionImpulse(
                bodyA: self,
                bodyB: bodyB,
                contactNormal: contactNormal,
                restitution: scene.physicsWorld.impactRestitution)

            return REPhysicsContact(
                bodyA: node.physicsBody,
                bodyB: nodeB.physicsBody,
                collisionImpulse: collisionImpulse,
                contactNormal: contactNormal)
        }

    private func getImpactVelocity(_ velocity: CGVector, contactNormal: CGVector) -> Double {
        let impactVelocity = velocity.dotProduct(with: contactNormal)

        // Ensures that impact velocity is opposite of normal vector of contact
        guard impactVelocity < 0 else {
            return 0
        }

        return abs(impactVelocity)
    }

    /// - Parameters:
    ///   - contactNormal: normal vector of contact pointing from bodyB to bodyA
    private func getCollisionImpulse(
        bodyA: REPhysicsBody,
        bodyB: REPhysicsBody,
        contactNormal: CGVector,
        restitution: Double) -> Double {

            guard restitution >= 0 || restitution <= 1 else {
                return 0
            }

            let mA = bodyA.dynamicMass
            let mB = bodyB.dynamicMass
            let vA = getImpactVelocity(
                bodyA.velocity, contactNormal: contactNormal)
            let vB = getImpactVelocity(
                bodyB.velocity, contactNormal: contactNormal.multiply(with: -1))

            /*
             Computes final velecity of mass A using
             1. Law of conservation of momentum:
             mA * vA + mB * vB = mA * vA' + mB * vB'
             2. Coefficient of restitution:
             (e) = (vA' - vB') / (vB - vA)
             */
            let finalVA = (mA * vA + mB * (vB + restitution * (vB - vA))) / (mA + mB)
            let aA = frameRate * 2 * finalVA
            let dt = 1 / frameRate
            let impulse = mA * aA * dt

            return abs(impulse)

        }
}
