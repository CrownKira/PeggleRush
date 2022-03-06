//
//  ValidationError.swift
//  PeggleClone
//
//  Created by Kyle キラ on 21/2/22.
//

import UIKit

enum ValidationError: Error {
    case invalidContentHeight
    case invalidItemLocation
    case invalidBlockShape
    case invalidAngle
    case invalidSize
    case noItemSelected
}
