//
//  BoardItemViewModel.swift
//  PeggleClone
//
//  Created by Kyle キラ on 25/2/22.
//

import UIKit

protocol BoardItemViewModel {
    var maxWidth: Double { get set }
    var rotationAngle: Double { get set }

    func resize(to width: Double)
    func rotate(to angle: Double)
}
