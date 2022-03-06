//
//  PegViewModel.swift
//  PeggleClone
//
//  Created by Kyle キラ on 30/1/22.
//

import UIKit

final class PegViewModel: ShapeCircle {

    static let bluePegImage: UIImage = #imageLiteral(resourceName: "peg-blue")
    static let orangePegImage: UIImage = #imageLiteral(resourceName: "peg-orange")
    static let greenPegImage: UIImage = #imageLiteral(resourceName: "peg-green")
    static let purplePegImage: UIImage = #imageLiteral(resourceName: "peg-purple")
    static let defaultRadius = UserDefaults.standard.double(forKey: "pegRadius")
    static var defaultDiameter: Double {
        defaultRadius * 2
    }

    private let pegDataManager = PegDataManager()

    var maxWidth: Double = 500.0
    var rotationAngle: Double = 0
    var radius = defaultRadius
    var position: CGPoint
    var pegType: PegType
    var size: CGSize {
        CGSize(width: diameter, height: diameter)
    }
    var image: UIImage {
        switch pegType {
        case .blue:
            return PegViewModel.bluePegImage
        case .orange:
            return PegViewModel.orangePegImage
        case .green:
            return PegViewModel.greenPegImage
        case .purple:
            return PegViewModel.purplePegImage
        }
    }

    init(peg: Peg) {
        self.position = CGPoint(
            x: peg.x - radius,
            y: peg.y - radius)
        self.radius = peg.radius

        switch peg {
        case is OrangePeg:
            self.pegType = .orange
        case is GreenPeg:
            self.pegType = .green
        case is PurplePeg:
            self.pegType = .purple
        default:
            self.pegType = .blue
        }
    }

    init(center: CGPoint, pegType: PegType = .blue, radius: Double = PegViewModel.defaultRadius) {
        self.position = CGPoint(
            x: center.x - radius,
            y: center.y - radius)

        self.pegType = pegType
        self.radius = radius
    }

    init(frame: CGRect, pegType: PegType = .blue) {
        self.position = frame.origin
        self.radius = frame.width / 2
        self.pegType = pegType
    }

}

// MARK: - Interface: CoreData

extension PegViewModel {

    func setPosition(_ position: CGPoint) {
        self.position = position
    }

    func setCenter(_ center: CGPoint) {
        self.position = CGPoint(
            x: center.x - radius,
            y: center.y - radius)
    }

    func save(board: Board) throws {
        try _ = pegDataManager.createPeg(
            board: board,
            pegType: pegType,
            radius: radius,
            rotation: rotationAngle,
            point: CGPoint(x: center.x, y: center.y))
    }
}

extension PegViewModel: BoardItemViewModel {

    func setRotationAngle(_ angle: Double) {
        self.rotationAngle = angle
    }

    func rotate(to angle: Double) {
        self.rotationAngle = angle
    }

    func resize(to width: Double) {
        self.radius = width / 2
    }
}

extension PegViewModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.position.x)
        hasher.combine(self.position.y)
    }
}

extension PegViewModel: Equatable {
    static func == (lhs: PegViewModel, rhs: PegViewModel) -> Bool {
        lhs.position == rhs.position
    }
}
