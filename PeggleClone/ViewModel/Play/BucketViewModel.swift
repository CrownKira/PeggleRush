//
//  BucketViewModel.swift
//  PeggleClone
//
//  Created by Kyle キラ on 23/2/22.
//

import UIKit

final class BucketViewModel: ShapeRect {

    static let normalImageTop = #imageLiteral(resourceName: "bucket-top-layer")
    static let normalImage = #imageLiteral(resourceName: "bucket")
    static let scoredImage = #imageLiteral(resourceName: "bucket")
    static let defaultSize = CGSize(width: 100, height: 100)
    static let nodeName = "bucket"

    var image: UIImage {
        containsBall ? BucketViewModel.scoredImage : BucketViewModel.normalImage
    }
    var size = BucketViewModel.defaultSize
    var containsBall = false
    var position: CGPoint
    var frame: CGRect {
        CGRect(origin: position, size: size)
    }
    var sceneNode: RESceneNode {
        let node = RESceneNode(
            name: BucketViewModel.nodeName,
            position: position,
            anchorPoint: CGPoint(x: 0.5, y: 0.5),
            physicsBody: REPhysicsRectBody(size: size),
            size: size
        )

        node.physicsBody.categoryBitMask = ColliderType.bucket
        node.physicsBody.affectedByGravity = false
        node.physicsBody.isDynamic = false

        return node
    }

    init(position: CGPoint) {
        self.position = position
    }

    init(bucketNode: RESceneNode) {
        self.position = bucketNode.position
    }
}
