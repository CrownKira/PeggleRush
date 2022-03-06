//
//  CAEmitterLayer+Extensions.swift
//  PeggleClone
//
//  Created by Kyle キラ on 23/2/22.
//

import UIKit

extension CAEmitterLayer {
    func pause() {
        self.speed = 0
        self.lifetime = 0
        self.timeOffset = convertTime(CACurrentMediaTime(), from: self)
    }

    func stop(afterTimeInterval ti: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + ti) { [weak self] in
            self?.birthRate = 0
            self?.removeFromSuperlayer(afterTimeInterval: 2.0)
        }
    }

    private func removeFromSuperlayer(afterTimeInterval ti: TimeInterval) {
        DispatchQueue.main.asyncAfter(deadline: .now() + ti) { [weak self] in
            self?.removeFromSuperlayer()
        }
    }
}
