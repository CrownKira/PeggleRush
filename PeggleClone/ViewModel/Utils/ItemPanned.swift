//
//  ItemPanned.swift
//  PeggleClone
//
//  Created by Kyle キラ on 13/2/22.
//

import UIKit

struct ItemPanned {
    let origin: CGPoint
    let center: CGPoint
    let pegView: UIView
    let viewModel: BoardItemViewModel
    let location: CGPoint
    let sender: UIPanGestureRecognizer
}
