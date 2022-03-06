//
//  CannonViewModel.swift
//  PeggleClone
//
//  Created by Kyle キラ on 8/2/22.
//

import UIKit

final class CannonViewModel {

    private static let loadedImage: UIImage = #imageLiteral(resourceName: "cannon-loaded")
    private static let unloadedImage: UIImage = #imageLiteral(resourceName: "cannon-rest")

    var ballViewModel: ObservableObject<BallViewModel?> = ObservableObject(nil)
    var rotationAngle: ObservableObject<Double> = ObservableObject(0)
    var isLoaded = true
    var image: UIImage {
        isLoaded ? CannonViewModel.loadedImage : CannonViewModel.unloadedImage
    }

    func reload(boundWidth: Double) {
        isLoaded = true
        ballViewModel.value = BallViewModel(
            center: CGPoint(x: boundWidth / 2, y: 0))
    }

    func unload() {
        isLoaded = false
    }

}
