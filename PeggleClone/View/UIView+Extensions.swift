//
//  UIView+Extensions.swift
//  PeggleClone
//
//  Created by Kyle キラ on 23/1/22.
//

import UIKit

extension UIView {

    func takeScreenshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)

        drawHierarchy(in: self.bounds, afterScreenUpdates: true)

        let image = UIGraphicsGetImageFromCurrentImageContext()

        UIGraphicsEndImageContext()

        if image != nil {
            return image!
        }

        return UIImage()
    }

    /*
     Taken from:
     https://stackoverflow.com/questions/26815263/setting-a-rotation-point-for-cgaffinetransformmakerotation-swift
     */
    func setAnchorPoint(anchorPoint: CGPoint) {

        var newPoint = CGPoint(
            x: self.bounds.size.width * anchorPoint.x,
            y: self.bounds.size.height * anchorPoint.y)
        var oldPoint = CGPoint(
            x: self.bounds.size.width * self.layer.anchorPoint.x,
            y: self.bounds.size.height * self.layer.anchorPoint.y)

        newPoint = newPoint.applying(self.transform)
        oldPoint = oldPoint.applying(self.transform)

        var position: CGPoint = self.layer.position

        position.x -= oldPoint.x
        position.x += newPoint.x

        position.y -= oldPoint.y
        position.y += newPoint.y

        self.layer.position = position
        self.layer.anchorPoint = anchorPoint
    }

    public var viewWidth: CGFloat {
        self.frame.size.width
    }

    public var viewHeight: CGFloat {
        self.frame.size.height
    }
}
