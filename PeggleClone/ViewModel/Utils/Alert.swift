//
//  Alert.swift
//  PeggleClone
//
//  Created by Kyle キラ on 23/1/22.
//

import UIKit

struct AlertStatus {
    let title: String
    let message: String
}

class Alert {

    class func showGenericError(vc: UIViewController) {
        showBasic(title: "Please try again", message: "An unknown error has occurred", vc: vc)
    }

    class func showBasic(title: String, message: String, vc: UIViewController) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        vc.present(alert, animated: true)
    }

    class func showConfirmWithoutCancel(
        title: String, message: String,
        vc: UIViewController, handler: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: handler))
        vc.present(alert, animated: true)
    }

    class func showConfirm(title: String, message: String, vc: UIViewController, handler: ((UIAlertAction) -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: handler))
        vc.present(alert, animated: true)
    }

    class func showLoading(vc: UIViewController) {

        let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)

        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating()

        alert.view.addSubview(loadingIndicator)
        vc.present(alert, animated: true, completion: nil)
    }}
