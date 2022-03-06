//
//  NSManagedObject+Extensions.swift
//  PeggleClone
//
//  Created by Kyle キラ on 23/1/22.
//

import UIKit
import CoreData

extension NSManagedObject {
    var isSaved: Bool {
        !self.objectID.isTemporaryID
    }
}
