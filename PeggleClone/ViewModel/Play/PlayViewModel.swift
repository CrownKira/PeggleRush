//
//  PlayViewModel.swift
//  PeggleClone
//
//  Created by Kyle キラ on 8/2/22.
//

import UIKit

final class PlayViewModel {

    let userDefaults = UserDefaults.standard
    let gravity = UserDefaults.standard.double(forKey: "gameGravity")
    let topSafeAreaOffset = 24.0
    let topPaletteOffset = 100.0
    let wallThickness = 50.0

    var boardViewModel: ObservableObject<PlayBoardViewModel?> = ObservableObject(nil)
    var cannonViewModel = CannonViewModel()
    var bucketViewModel: ObservableObject<BucketViewModel?> = ObservableObject(nil)
    var spookyBallNodes = [RESceneNode]()
    var ballNode: RESceneNode?
    var bucketNode: RESceneNode?
    var blockNodes = [REShapeNode]()
    var scene: REScene?

    var collisionContact: ObservableObject<REPhysicsContact?> = ObservableObject(nil)
    var activatedPowerup: ObservableObject<Powerup?> = ObservableObject(nil)
    var isSpookyModeOn: Bool {
        !spookyBallNodes.isEmpty
    }
    var isBoardViewModelLoaded: Bool {
        boardViewModel.value != nil
    }
    var isBallLaunched = false

    init(boardViewModel: PlayBoardViewModel?) {
        self.boardViewModel.value = boardViewModel
    }

}

// MARK: - Collision Handlers

extension PlayViewModel: REPhysicsContactDelegate {

    func shouldBodiesCollide(contact: REPhysicsContact) -> Bool {
        let collisionCheckBits = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        if collisionCheckBits == ColliderType.ball | ColliderType.bucket {
            let contactX = contact.contactNormal.dx
            let contactY = contact.contactNormal.dy

            let isEntrance = contactX == 0 && contactY == -1

            return !isEntrance
        }

        return true
    }

    func didBegin(_ contact: REPhysicsContact) {
        collisionContact.value = contact

        let collisionCheckBits = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        if collisionCheckBits == ColliderType.ball | ColliderType.peg {
            let centerOfPeg = contact.bodyA.categoryBitMask
            == ColliderType.peg
            ? contact.bodyA.node?.center
            : contact.bodyB.node?.center

            guard let boardViewModel = boardViewModel.value, let centerOfPeg = centerOfPeg else {
                return
            }

            guard let pegViewModel = boardViewModel.getPegViewModel(at: centerOfPeg) else {
                return
            }

            activatePowerup(pegViewModel: pegViewModel, contact: contact)
            boardViewModel.setPegToLit(at: centerOfPeg)
        }
    }

    private func activatePowerup(pegViewModel: PlayPegViewModel,
                                 contact: REPhysicsContact) {
        switch pegViewModel.pegType {
        case .purple:
            let shouldActivateSpookyBall = !pegViewModel.isLit
            if shouldActivateSpookyBall {
                activatedPowerup.value = .spookyBall

                enqueueSpookyBallNode()
            }
        case .green:
            let shouldExertForce = !pegViewModel.isLit

            if shouldExertForce {
                activatedPowerup.value = .kaboom

                let explosionMultiplier = userDefaults.double(forKey: "explosionMultiplier")
                let impulse = contact.contactNormal.multiply(with: explosionMultiplier)
                ballNode?.physicsBody.applyImpulse(impulse)
            }
        default:
            break
        }
    }

    private func enqueueSpookyBallNode() {
        guard let ballViewModel = cannonViewModel.ballViewModel.value else {
            return
        }

        spookyBallNodes.append(ballViewModel.spookySceneNode)
    }

    private func dequeueSpookyBallNode() -> RESceneNode {
        let spookyBallNode = spookyBallNodes.removeFirst()
        _ = scene?.addNode(spookyBallNode)
        return spookyBallNode
    }

}

// MARK: - Scene Update Handlers

extension PlayViewModel: RESceneDelegate {

    func didUpdate(newState: REState) {
        updateBallViewModel()
        updateBucketViewModel()
        updateBlockViewModels()
        updateBucketNode()
    }

    func didEnd(finalState: REState) {}

    private func updateBlockViewModels() {
        var newBlockViewModels = [CGPoint: PlayBlockViewModel]()

        blockNodes.forEach { blockNode in
            newBlockViewModels[blockNode.position] = PlayBlockViewModel(blockNode: blockNode)
        }

        boardViewModel.value?.blockViewModels.value = newBlockViewModels
    }

    private func updateBallViewModel() {
        guard isBallLaunched else {
            return
        }

        guard let ballNode = ballNode,
              let boardViewModel = boardViewModel.value else {
                  return
              }

        let ballViewModel = BallViewModel(ballNode: ballNode)
        cannonViewModel.ballViewModel.value = ballViewModel

        clearPathForBall()

        let isBallOutOfBounds = ballNode.position.y > boardViewModel.contentHeight.value
        if isBallOutOfBounds {
            reloadCannonWithNewBall(didBallEnterBucket: false)
        }
    }

    private func clearPathForBall() {
        guard let ballNode = ballNode,
              let boardViewModel = boardViewModel.value else {
                  return
              }

        // Removes nearby pegs if ball starts to idle
        let minVy = userDefaults.double(forKey: "ballMinimumVelocityY")
        let minAy = userDefaults.double(forKey: "ballMinimumAcceralationY")

        // Checks magnitude of net acceleration:
        let netAccelerationY = abs(ballNode.physicsBody.acceleration.dy)

        if ballNode.physicsBody.velocity.dy < minVy,
           netAccelerationY < minAy {
            boardViewModel.setPegToPop(near: ballNode.center)
        }
    }

    private func reloadCannonWithNewBall(didBallEnterBucket: Bool) {
        if isSpookyModeOn {
            ballNode = dequeueSpookyBallNode()
        } else {
            updateStatesAfterRelaod(didBallEnterBucket: didBallEnterBucket)
            resetBallNode()
        }
    }

    private func updateStatesAfterRelaod(didBallEnterBucket: Bool) {
        guard let boardViewModel = boardViewModel.value else {
            return
        }

        isBallLaunched = false
        cannonViewModel.reload(
            boundWidth: boardViewModel.width)
        boardViewModel.updateBoardStates(didBallEnterBucket: didBallEnterBucket)
    }

    private func resetBallNode() {
        guard let boardViewModel = boardViewModel.value else {
            return
        }

        ballNode?.physicsBody.isDynamic = false
        ballNode?.physicsBody.velocity = CGVector()
        ballNode?.position = CGPoint(
            x: boardViewModel.width / 2 - BallViewModel.defaultRadius,
            y: BallViewModel.defaultRadius * -1)
    }

    private func updateBucketViewModel() {
        guard let ballViewModel = cannonViewModel.ballViewModel.value,
              let bucketNode = bucketNode else {
                  return
              }

        let bucketViewModel = BucketViewModel(bucketNode: bucketNode)
        if ballViewModel.enters(bucketViewModel: bucketViewModel) {
            bucketViewModel.containsBall = true
            reloadCannonWithNewBall(didBallEnterBucket: true)
        }
        self.bucketViewModel.value = bucketViewModel
    }

    private func updateBucketNode() {
        reflectBucketNode()
    }

    private func reflectBucketNode() {
        guard let bucketNode = bucketNode,
              let bucketViewModel = bucketViewModel.value,
              let boardViewModel = boardViewModel.value  else {
                  return
              }

        // Reverses bucket velocity when it hits the wall
        let leftLimit = 0.0
        let rightLimit = boardViewModel.width - bucketViewModel.size.width
        let positionX = bucketNode.position.x

        if positionX >= rightLimit || positionX <= leftLimit {
            bucketNode.physicsBody.velocity = bucketNode.physicsBody.velocity.multiply(
                with: -1)
        }
    }

}
