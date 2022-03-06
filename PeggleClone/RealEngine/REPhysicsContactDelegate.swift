//
//  REPhysicsContactDelegate.swift
//  PeggleClone
//
//  Created by Kyle キラ on 13/2/22.
//

import UIKit

protocol REPhysicsContactDelegate: AnyObject {

    func didBegin(_ contact: REPhysicsContact)
    func shouldBodiesCollide(contact: REPhysicsContact) -> Bool

}
