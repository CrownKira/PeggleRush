//
//  UIViewController+Extensions.swift
//  PeggleClone
//
//  Created by Kyle キラ on 21/2/22.
//

import UIKit

private var aView: UIView?

extension UIViewController {

    func showSpinner() {
        let activityView = UIView(frame: self.view.bounds)
        let activityIndicator = UIActivityIndicatorView(
            style: .large)
        activityIndicator.center = activityView.center
        activityIndicator.startAnimating()
        activityView.addSubview(activityIndicator)
        self.view.addSubview(activityView)
        aView = activityView
    }

    func removeSpinner() {
        aView?.removeFromSuperview()
        aView = nil
    }

}
