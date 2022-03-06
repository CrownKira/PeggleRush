//
//  ColliderType.swift
//  PeggleClone
//
//  Created by Kyle キラ on 13/2/22.
//

import UIKit

struct ColliderType {
    static let ball: UInt32 = 0x1 << 0
    static let peg: UInt32 = 0x1 << 1
    static let wall: UInt32 = 0x1 << 2
    static let cannon: UInt32 = 0x1 << 3
    static let bucket: UInt32 = 0x1 << 4
    static let block: UInt32 = 0x1 << 5
}
