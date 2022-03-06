//
//  ShapeViewModel.swift
//  PeggleClone
//
//  Created by Kyle キラ on 30/1/22.
//

import UIKit

final class BlockViewModel: Shape {

    static let cornerImage = #imageLiteral(resourceName: "peg-orange-glow")
    static let defaultSize = CGSize(width: 150, height: 150)
    static let cornerRadius = 20.0
    static var cornerSize: CGSize {
        CGSize(width: cornerRadius * 2, height: cornerRadius * 2)
    }

    private var blockDataManager = BlockDataManager()
    var maxWidth: Double = 500.0
    var forceConstant: Double = 50
    var rotationAngle: Double = 0
    var cornerOrigins: [CGPoint] {
        points.map {
            CGPoint(
                x: $0.x - BlockViewModel.cornerRadius,
                y: $0.y - BlockViewModel.cornerRadius)
        }
    }
    var cornerFrames: [CGRect] {
        cornerOrigins.map {
            CGRect(origin: $0, size: BlockViewModel.cornerSize)
        }
    }
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

    init(block: Block) {
        let corners: [CGPoint] = block.corners?.compactMap {
            guard let corner = ($0 as? CornerPoint) else {
                return nil
            }
            return CGPoint(x: corner.x, y: corner.y)
        } ?? []
        self.path = CGPath.createPath(using: corners)
        self.position = self.path.boundingBox.origin
        self.forceConstant = block.forceConstant
    }

    init(path: CGPath) {
        self.path = path
        self.position = path.boundingBox.origin
    }
}

// MARK: - Interface

extension BlockViewModel {
    func getNearestCorner(to pointB: CGPoint) -> CGPoint? {
        var nearestCorner: CGPoint?
        var minDist = Double.infinity

        for point in points {
            let dist = point.getDist(to: pointB)
            if dist < minDist {
                minDist = dist
                nearestCorner = point
            }
        }

        return nearestCorner
    }
}

// MARK: - Interface: CoreData

extension BlockViewModel {

    func save(board: Board) throws {
        try _ = blockDataManager.createBlock(
            board: board,
            forceConstant: forceConstant,
            corners: path.getPathElementsPoints())
    }
}

extension BlockViewModel: BoardItemViewModel {

    func setRotationAngle(_ angle: Double) {
        self.rotationAngle = angle
    }

    func rotate(to angle: Double) {
        self.rotationAngle = angle
    }

    func resize(to width: Double) {
        let scaleFactor = width / path.boundingBox.width
        resize(by: scaleFactor)
    }

    func resize(by scaleFactor: Double) {
        let newBoundingRect = CGRect(
            origin: position,
            size: CGSize(
                width: path.boundingBox.width * scaleFactor,
                height: path.boundingBox.height * scaleFactor))
        resize(to: newBoundingRect)
    }

    func resize(to rect: CGRect) {
        path = path.resized(to: rect)
    }
}

extension BlockViewModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.path)
    }
}

extension BlockViewModel: Equatable {
    static func == (lhs: BlockViewModel, rhs: BlockViewModel) -> Bool {
        lhs.path == rhs.path
    }
}
