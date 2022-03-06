//
//  CannonStatus.swift
//  PeggleClone
//
//  Created by Kyle キラ on 13/2/22.
//

import UIKit

struct CannonStatus {
    let position: CGPoint
    let size: CGSize
    var center: CGPoint {
        let x = position.x + size.width / 2
        let y = position.y + size.height / 2
        return CGPoint(x: x, y: y)
    }
}
