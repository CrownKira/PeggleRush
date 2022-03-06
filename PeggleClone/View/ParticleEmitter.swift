//
//  ParticleEmitter.swift
//  PeggleClone
//
//  Created by Kyle キラ on 23/2/22.
//

import UIKit

class ParticleEmitter {
    struct Config {
        static let lifetime: Float = 5.0
        static let birthRate: Float = 3.0
        static let scale: CGFloat = 0.01
        static let velocity: CGFloat = 30.0
    }

    var view: UIView
    var particleImage: UIImage
    var colors: [UIColor] = [
        .systemRed,
        .systemBlue,
        .systemOrange,
        .systemGreen,
        .systemPink,
        .systemYellow,
        .systemPurple
    ]

    init?(on view: UIView, particleImage: UIImage?) {
        guard let particleImage = particleImage else {
            return nil
        }

        self.view = view
        self.particleImage = particleImage
    }

    func emit(
        at position: CGPoint, for ti: TimeInterval,
        direction: CGFloat, range: CGFloat,
        birthRate: Float = Config.birthRate,
        velocity: CGFloat = Config.velocity
    ) {
        let emitterLayer = CAEmitterLayer()
        emitterLayer.emitterPosition = position

        let cells: [CAEmitterCell] = colors.compactMap {
            let cell = CAEmitterCell()

            cell.emissionLongitude = direction
            cell.emissionRange = range
            cell.color = $0.cgColor
            cell.contents = particleImage.cgImage
            cell.birthRate = birthRate
            cell.velocity = velocity

            cell.lifetime = Config.lifetime
            cell.scale = Config.scale

            return cell
        }

        emitterLayer.emitterCells = cells
        view.layer.addSublayer(emitterLayer)
        emitterLayer.stop(afterTimeInterval: ti)
    }
}
