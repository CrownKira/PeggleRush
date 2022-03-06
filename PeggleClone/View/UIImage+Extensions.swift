//
//  UIImage+Extensions.swift
//  PeggleClone
//
//  Created by Kyle キラ on 23/1/22.
//

import UIKit

extension UIImage {

    func mergeWith(topImage: UIImage) -> UIImage {
        let bottomImage = self

        UIGraphicsBeginImageContext(size)

        let areaSize = CGRect(x: 0, y: 0, width: bottomImage.size.width, height: bottomImage.size.height)
        bottomImage.draw(in: areaSize)

        topImage.draw(in: areaSize, blendMode: .normal, alpha: 1.0)

        let mergedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        if mergedImage != nil {
            return mergedImage!
        }

        return UIImage()
    }

}
