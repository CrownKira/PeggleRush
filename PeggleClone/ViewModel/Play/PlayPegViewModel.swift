//
//  PlayPegViewModel.swift
//  PeggleClone
//
//  Created by Kyle キラ on 30/1/22.
//

import UIKit

final class PlayPegViewModel: ShapeCircle {
    static let bluePegImage: UIImage = #imageLiteral(resourceName: "peg-blue")
    static let orangePegImage: UIImage = #imageLiteral(resourceName: "peg-orange")
    static let greenPegImage: UIImage = #imageLiteral(resourceName: "peg-green")
    static let purplePegImage: UIImage = #imageLiteral(resourceName: "peg-purple")

    static let litBluePegImage: UIImage = #imageLiteral(resourceName: "peg-blue-glow")
    static let litOrangePegImage: UIImage = #imageLiteral(resourceName: "peg-orange-glow")
    static let litGreenPegImage: UIImage = #imageLiteral(resourceName: "peg-green-glow")
    static let litPurplePegImage: UIImage = #imageLiteral(resourceName: "peg-purple-glow")
    static let nodeName = "peg"

    var radius = PegViewModel.defaultRadius
    var position: CGPoint
    var pegType: PegType
    var isLit = false
    var isPowerupRendered = false
    var shouldPopPrematurely = false
    var sceneNodeId: Int?
    var sceneNode: RESceneNode {
        let node = RESceneNode(
            name: PlayPegViewModel.nodeName,
            position: position,
            anchorPoint: CGPoint(x: 0.5, y: 0.5),
            physicsBody: REPhysicsCircleBody(
                radius: radius),
            size: size)

        node.physicsBody.categoryBitMask = ColliderType.peg

        return node
    }

    var image: UIImage {
        switch pegType {
        case .blue:
            return isLit ? PlayPegViewModel.litBluePegImage : PlayPegViewModel.bluePegImage
        case .orange:
            return isLit ? PlayPegViewModel.litOrangePegImage : PlayPegViewModel.orangePegImage
        case .green:
            return isLit ? PlayPegViewModel.litGreenPegImage : PlayPegViewModel.greenPegImage
        case .purple:
            return isLit ? PlayPegViewModel.litPurplePegImage : PlayPegViewModel.purplePegImage
        }
    }

    init(pegViewModel: PegViewModel) {
        self.position = pegViewModel.position
        self.pegType = pegViewModel.pegType
        self.radius = pegViewModel.radius
    }

    init(center: CGPoint, pegType: PegType = .blue) {
        self.position = CGPoint(
            x: center.x - radius,
            y: center.y - radius)
        self.pegType = pegType
    }

    func setPosition(_ position: CGPoint) {
        self.position = position
    }

    func setCenter(_ center: CGPoint) {
        self.position = CGPoint(
            x: center.x - radius,
            y: center.y - radius)
    }

}

extension PlayPegViewModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.position.x)
        hasher.combine(self.position.y)
    }
}

extension PlayPegViewModel: Equatable {
    static func == (lhs: PlayPegViewModel, rhs: PlayPegViewModel) -> Bool {
        lhs.position == rhs.position
    }
}
