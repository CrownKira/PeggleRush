//
//  ShapeViewModel.swift
//  PeggleClone
//
//  Created by Kyle キラ on 30/1/22.
//

import UIKit

final class PlayBlockViewModel: Shape {

    static let nodeName = "ball"

    private let userDefaults = UserDefaults.standard
    private var blockDataManager = BlockDataManager()

    var path: CGPath {
        didSet {
            let newPosition = path.boundingBox.origin
            if position != newPosition {
                position = newPosition
            }
        }
    }
    var position = CGPoint() {
        willSet {
            let newPath = path.translateTo(position: newValue)
            if path != newPath {
                path = newPath
            }
        }
    }
    var forceConstant: Double
    var sceneNodeId: Int?
    var sceneNode: REShapeNode {
        let node = REShapeNode(
            path: path,
            name: PlayBlockViewModel.nodeName,
            position: position,
            anchorPoint: CGPoint(x: 0.5, y: 0.5),
            physicsBody: REPhysicsShapeBody(size: size, path: path),
            size: size)

        node.physicsBody.isDynamic = true
        node.physicsBody.mass = userDefaults.double(forKey: "blockMass")
        node.physicsBody.affectedByGravity = false
        node.physicsBody.jointWith = RESpring(
            jointAt: position,
            forceConstant: forceConstant,
            physicsBody: node.physicsBody)
        node.physicsBody.categoryBitMask = ColliderType.block
        node.physicsBody.collisionBitMask = ColliderType.ball

        return node
    }

    init(blockNode: REShapeNode) {
        self.path = blockNode.path
        self.position = blockNode.position
        self.forceConstant = blockNode.physicsBody.jointWith?.forceConstant ?? 0
    }

    init(blockViewModel: BlockViewModel) {
        self.path = blockViewModel.path
        self.position = blockViewModel.position
        self.forceConstant = blockViewModel.forceConstant
    }
}

extension PlayBlockViewModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.path)
    }
}

extension PlayBlockViewModel: Equatable {
    static func == (lhs: PlayBlockViewModel, rhs: PlayBlockViewModel) -> Bool {
        lhs.path == rhs.path
    }
}
