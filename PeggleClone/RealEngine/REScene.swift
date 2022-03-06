//
//  REScnee.swift
//  PeggleClone
//
//  Created by Kyle キラ on 8/2/22.
//

import UIKit

/*
 A physics simulator, where the initial state can be input,
 and upon running the simulation, the internal state will
 be continuously updated and a callback that exposes this
 internal state is sent to the delegate to perform necessary actions.
 */
final class REScene {

    weak var delegate: RESceneDelegate?
    weak var contactDelegate: REPhysicsContactDelegate?

    private var nextId = 0
    private var displayLink: CADisplayLink?
    private var startTime: Date?
    private var timeElapsed = 0.0
    private var conditionToEnd: ((_: REState) -> Bool)?
    private var nodes: [Int: RESceneNode] = [:]
    private var dynamicNodes: [Int: RESceneNode] = [:]
    private var currState: REState {
        REState(nodes: nodes, timeElapsed: timeElapsed)
    }

    var physicsWorld = REPhysicsWorld()

    func addNode(_ node: RESceneNode) -> Int {
        node.scene = self
        nodes[nextId] = node

        // Keeps track of nodes of dynamic bodies
        if node.physicsBody.isDynamic {
            dynamicNodes[nextId] = node
        }

        // Increments ID
        let temp = nextId
        nextId += 1
        return temp
    }

    func removeNode(forId nodeId: Int) -> RESceneNode? {
        nodes.removeValue(forKey: nodeId)
    }

    func simulate(conditionToEnd: @escaping (_: REState) -> Bool) {
        // Cleans up previous display link
        stopDisplayLink()

        // Sets up display link
        let displayLink = CADisplayLink(target: self, selector: #selector(displayLinkDidFire))
        displayLink.add(to: .main, forMode: .default)
        self.displayLink = displayLink

        self.conditionToEnd = conditionToEnd
        startTime = Date()
    }

    private func stopDisplayLink() {
        displayLink?.invalidate()
        displayLink = nil
    }

    @objc private func displayLinkDidFire() {
        guard let startTime = startTime,
              let conditionToEnd = conditionToEnd else {
                  return
              }

        // Checks if state fulfil condition to end
        if conditionToEnd(currState) {
            stopDisplayLink()
            delegate?.didEnd(finalState: currState)
        }

        // Updates time elapsed
        timeElapsed = Date().timeIntervalSince(startTime)
        simulatePhysics()
        delegate?.didUpdate(newState: currState)
    }

    private func simulatePhysics() {
        for node in nodes.values {
            updateDynamicNodeState(node)
        }
    }

    // Resolves collision impulse and get acceleration
    private func getNetAcceleration(node: RESceneNode, frameRate: Double) -> CGVector {

        guard node.physicsBody.isDynamic else {
            return CGVector()
        }

        let collisionAcceleration = getAccelerationFromCollisions(node: node, frameRate: frameRate)
        let gravitationalAcceleration = getGravitationalAcceleration(node: node)
        let externalAcceleration = getExternalAcceleration(node: node)
        let springAcceleration = getSpringAcceleration(node: node)

        var netAcceleration = collisionAcceleration.sum(with: gravitationalAcceleration)
        netAcceleration = netAcceleration.sum(with: externalAcceleration)
        netAcceleration = netAcceleration.sum(with: springAcceleration)

        return netAcceleration
    }

    private func getSpringAcceleration(node: RESceneNode) -> CGVector {
        guard let spring = node.physicsBody.jointWith,
              let displacement = spring.displacement else {
                  return CGVector()
              }

        let velocity = node.physicsBody.velocity
        let force = displacement.multiply(with: -spring.forceConstant)
        let dampingForce = velocity.multiply(with: -spring.dampingFactor)
        let netForce = force.sum(with: dampingForce)
        let netAcceleration = netForce.multiply(with: 1 / node.physicsBody.mass)

        return netAcceleration
    }

    private func getExternalAcceleration(node: RESceneNode) -> CGVector {
        let externalAcceleration = node.physicsBody.externalForce.multiply(
            with: 1 / node.physicsBody.mass)
        node.physicsBody.externalForce = CGVector()

        return externalAcceleration
    }

    private func getGravitationalAcceleration(node: RESceneNode) -> CGVector {
        if node.physicsBody.affectedByGravity {
            return CGVector(dx: 0, dy: physicsWorld.gravity)
        }
        return CGVector()
    }

    private func getAccelerationFromCollisions(node: RESceneNode, frameRate: Double) -> CGVector {
        var acceleration = CGVector()

        for nodeB in nodes.values {
            acceleration = acceleration.sum(
                with: getAccelerationComponent(
                    node: node, nodeB: nodeB, frameRate: frameRate))
        }

        return acceleration
    }

    private func getAccelerationComponent(node: RESceneNode, nodeB: RESceneNode, frameRate: Double) -> CGVector {
        let nodesWillCollide = node.physicsBody.collisionBitMask
        == node.physicsBody.collisionBitMask | nodeB.physicsBody.categoryBitMask
        let dt = 1 / frameRate

        guard node != nodeB, nodesWillCollide,
              let contact = node.physicsBody.getContact(
                with: nodeB.physicsBody,
                in: self) else {
                    return CGVector()
                }

        let shouldBodiesCollide = (contactDelegate?.shouldBodiesCollide(contact: contact)) ?? true
        guard shouldBodiesCollide else {
            return CGVector()
        }

        // Tells delegate about this contact if contactTestBitMask is set
        let checkBits = node.physicsBody.contactTestBitMask
        | nodeB.physicsBody.categoryBitMask
        if node.physicsBody.contactTestBitMask == checkBits {
            contactDelegate?.didBegin(contact)
        }

        let newAMagnitude = contact.collisionImpulse / (node.physicsBody.mass * dt)
        let newA = contact.contactNormal.multiply(with: newAMagnitude)

        return newA
    }

    // Update node state from influence of gravity and collision
    private func updateDynamicNodeState(_ node: RESceneNode) {
        guard let displayLink = displayLink else {
            return
        }

        let frameRate = 1 / (displayLink.targetTimestamp - displayLink.timestamp)
        node.physicsBody.frameRate = frameRate
        node.physicsBody.acceleration = getNetAcceleration(node: node, frameRate: frameRate)

        // acceleration
        let ax = node.physicsBody.acceleration.dx
        let ay = node.physicsBody.acceleration.dy

        // time interval
        let dt: Double = 1 / frameRate

        // position
        let x = node.position.x
        let y = node.position.y

        // velocity
        let vx = node.physicsBody.velocity.dx
        let vy = node.physicsBody.velocity.dy

        // Updates position
        let diffX = vx * dt + (1 / 2) * ax * pow(dt, 2)
        let diffY = vy * dt + (1 / 2) * ay * pow(dt, 2)
        let newX = diffX + x
        let newY = diffY + y
        node.position = CGPoint(x: newX, y: newY)

        // Updates velocity
        let newVx = vx + ax * dt
        let newVy = vy + ay * dt
        node.physicsBody.velocity = CGVector(dx: newVx, dy: newVy)
    }
}
