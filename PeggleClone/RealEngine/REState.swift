//
//  REState.swift
//  PeggleClone
//
//  Created by Kyle キラ on 8/2/22.
//

import UIKit

// Encapsulates the state of the scene
final class REState {

    var nodes = [Int: RESceneNode]()
    var timeElapsed: Double

    init(nodes: [Int: RESceneNode], timeElapsed: Double) {
        self.nodes = nodes
        self.timeElapsed = timeElapsed
    }

}
