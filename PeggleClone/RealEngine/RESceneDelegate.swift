//
//  RESceneDelegate.swift
//  PeggleClone
//
//  Created by Kyle キラ on 13/2/22.
//

import UIKit

protocol RESceneDelegate: AnyObject {

    func didUpdate(newState: REState)
    func didEnd(finalState: REState)

}
