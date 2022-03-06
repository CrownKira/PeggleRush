//
//  BallViewModel.swift
//  PeggleClone
//
//  Created by Kyle キラ on 8/2/22.
//

import UIKit

final class BallViewModel: ShapeCircle {

    static let image = #imageLiteral(resourceName: "ball")
    static let nodeName = "ball"
    static let defaultRadius = UserDefaults.standard.double(forKey: "ballRadius")

    var radius = BallViewModel.defaultRadius
    var diameter: Double {
        radius * 2
    }
    var position: CGPoint
    var sceneNode: RESceneNode {
        let node = RESceneNode(
            name: BallViewModel.nodeName,
            position: position,
            anchorPoint: CGPoint(x: 0.5, y: 0.5),
            physicsBody: REPhysicsCircleBody(
                radius: radius),
            size: size)

        node.physicsBody.categoryBitMask = ColliderType.ball
        node.physicsBody.contactTestBitMask = ColliderType.peg | ColliderType.bucket | ColliderType.block
        node.physicsBody.collisionBitMask = ColliderType.peg | ColliderType.wall
        | ColliderType.bucket | ColliderType.block
        node.physicsBody.affectedByGravity = true
        node.physicsBody.isDynamic = true

        return node
    }
    var spookySceneNode: RESceneNode {
        let spookyBallNode = sceneNode
        spookyBallNode.position.y = 0

        return spookyBallNode
    }

    init(position: CGPoint) {
        self.position = position
    }

    init(center: CGPoint) {
        self.position = CGPoint(x: center.x - radius, y: center.y - radius)
    }

    init(ballNode: RESceneNode) {
        self.position = ballNode.position
    }

    func enters(bucketViewModel: BucketViewModel) -> Bool {
        bucketViewModel.topLine.intersects(with: self)
    }
}
