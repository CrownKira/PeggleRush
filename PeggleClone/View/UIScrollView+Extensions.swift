//
//  UIScrollView+Extensions.swift
//  PeggleClone
//
//  Created by Kyle キラ on 22/2/22.
//

import UIKit

extension UIScrollView {
    //https://stackoverflow.com/questions/10976816/how-to-take-screenshot-of-uiscrollview-visible-area/17820462
    var snapshotVisibleArea: UIImage {
        UIGraphicsBeginImageContext(bounds.size)
        UIGraphicsGetCurrentContext()?.translateBy(
            x: -contentOffset.x,
            y: -contentOffset.y)
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        if image != nil {
            return image!
        }

        return UIImage()
    }
}
