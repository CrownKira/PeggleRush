//
//  PlayViewController+Extensions.swift
//  PeggleClone
//
//  Created by Kyle キラ on 27/2/22.
//

import UIKit

// MARK: - Setup Recognizers

extension PlayViewController {

    func addUIPanRecognizer(to viewToInteract: UIView, action: Selector?) {
        let UIPanRecognizer = UIPanGestureRecognizer(target: self, action: action)
        viewToInteract.isUserInteractionEnabled = true
        viewToInteract.addGestureRecognizer(UIPanRecognizer)
    }

    func addUITapRecognizer(to viewToInteract: UIView, action: Selector?) {
        let UITapRecognizer = UITapGestureRecognizer(target: self, action: action)
        UITapRecognizer.numberOfTouchesRequired = 1
        UITapRecognizer.numberOfTouchesRequired = 1
        viewToInteract.isUserInteractionEnabled = true
        viewToInteract.addGestureRecognizer(UITapRecognizer)
    }

    @objc func boardViewTapped(_ sender: UITapGestureRecognizer) {
        viewModel.launchBall()
    }

    @objc func itemPanned(_ sender: UIPanGestureRecognizer) {

        switch sender.state {
        case .changed:
            let translation = sender.translation(in: view)
            viewModel.rotateCannon(panTranslation: translation)
            sender.setTranslation(CGPoint.zero, in: view)

        default:
            break
        }
    }

}

// MARK: - Particles Renderers

extension PlayViewController {

    func emitParticles(around center: CGPoint) {
        rainbowParticleEmitter?.emit(
            at: center,
            for: 3, direction: .pi * 2, range: .pi * 2)
    }

    func emitTrailParticles(at center: CGPoint) {
        rainbowParticleEmitter?.emit(
            at: center, for: 0.1,
            direction: .pi * 2, range: .pi * 2,
            birthRate: 0.1, velocity: 5)
    }

    func emitParticlesUpwards(at center: CGPoint) {
        rainbowParticleEmitter?.emit(
            at: center, for: 0.1,
            direction: .pi * 2, range: .pi * 2,
            birthRate: 5, velocity: 30)
    }

}

// MARK: - Alerts

extension PlayViewController {
    func showLoseMessage() {
        Alert.showConfirmWithoutCancel(
            title: "You Lose",
            message: "It seems like there are no balls left :(", vc: self) {[weak self] _ in
                self?.dismiss(animated: true, completion: nil)
        }
    }

    func showWinMessage() {
        Alert.showConfirmWithoutCancel(
            title: "You Win",
            message: "Congrats!", vc: self) {[weak self]_ in
                self?.dismiss(animated: true, completion: nil)
        }
    }
}
