//
//  PlayViewModel+Extensions.swift
//  PeggleClone
//
//  Created by Kyle キラ on 27/2/22.
//

import UIKit

// MARK: - Setup Scene

extension PlayViewModel {

    private func updateStatesAfterUnload() {
        isBallLaunched = true
        cannonViewModel.unload()
    }

    private func setBallNodeToLaunch() {
        let speed = userDefaults.double(forKey: "ballLaunchSpeed")
        ballNode?.physicsBody.isDynamic = true
        ballNode?.physicsBody.velocity = CGVector(
            dx: speed * sin(cannonViewModel.rotationAngle.value * -1),
            dy: speed * cos(cannonViewModel.rotationAngle.value * -1))
    }

    func launchBall() {
        guard !isBallLaunched else {
            return
        }

        if scene == nil {
            createAndSimulateNewScene()
        } else {
            setBallNodeToLaunch()
        }

        updateStatesAfterUnload()
    }

    func createAndSimulateNewScene() {
        guard let boardViewModel = boardViewModel.value else {
            return
        }

        // Loads the first ball into cannon
        cannonViewModel.reload(boundWidth: boardViewModel.width)

        // Creates and simulate scene
        let scene = createScene()
        scene.simulate { _ in false }
        self.scene = scene
    }

    private func createScene() -> REScene {
        let scene = REScene()

        setupScene(scene: scene)
        setupBallNode(scene: scene)
        setupPegNodes(scene: scene)
        setupWallNodes(scene: scene)
        setupBucketNode(scene: scene)
        setupBlockNodes(scene: scene)

        return scene
    }

    private func setupScene(scene: REScene) {
        scene.delegate = self
        scene.contactDelegate = self
        scene.physicsWorld.gravity = gravity
    }

    private func setupBlockNodes(scene: REScene) {
        guard let blockViewModels = boardViewModel.value?.blockViewModels.value else {
            return
        }

        for blockViewModel in blockViewModels.values {
            let blockNode = blockViewModel.sceneNode
            blockViewModel.sceneNodeId = scene.addNode(blockNode)
            self.blockNodes.append(blockNode)
        }
    }

    private func setupBallNode(scene: REScene) {
        guard let ballViewModel = cannonViewModel.ballViewModel.value else {
            return
        }

        let ballNode = ballViewModel.sceneNode
        _ = scene.addNode(ballNode)
        self.ballNode = ballNode

        setBallNodeToLaunch()
    }

    private func setupPegNodes(scene: REScene) {
        guard let pegViewModels = boardViewModel.value?.pegViewModels.value else {
            return
        }

        for pegViewModel in pegViewModels.values {
            let pegNode = pegViewModel.sceneNode
            pegViewModel.sceneNodeId = scene.addNode(pegNode)
        }
    }

    private func setupWallNodes(scene: REScene) {
        guard let boardViewModel = boardViewModel.value else {
            return
        }

        let leftWallNode = createWallSceneNode(wallDirection: .left, bounds: boardViewModel.bounds)
        _ = scene.addNode(leftWallNode)
        let rightWallNode = createWallSceneNode(wallDirection: .right, bounds: boardViewModel.bounds)
        _ = scene.addNode(rightWallNode)
        let topWallNode = createWallSceneNode(wallDirection: .top, bounds: boardViewModel.bounds)
        _ = scene.addNode(topWallNode)
    }

    private func setupBucketNode(scene: REScene) {
        guard let bucketViewModel = bucketViewModel.value else {
            return
        }

        let bucketNode = bucketViewModel.sceneNode
        let speed = userDefaults.double(forKey: "bucketSpeed")
        bucketNode.physicsBody.velocity = CGVector(dx: speed, dy: 0)
        _ = scene.addNode(bucketNode)
        self.bucketNode = bucketNode
    }

    private func createWallSceneNode(wallDirection: WallDirection, bounds: CGRect) -> RESceneNode {

        let wallSize: CGSize
        let wallPosition: CGPoint
        let name: String

        switch wallDirection {
        case .top:
            name = "wallTop"
            wallPosition = CGPoint(
                x: 0,
                y: -wallThickness - topPaletteOffset - topSafeAreaOffset)
            wallSize = CGSize(width: bounds.width, height: wallThickness)
        case .left:
            name = "wallLeft"
            wallPosition = CGPoint(
                x: -wallThickness,
                y: -topPaletteOffset - topSafeAreaOffset)
            wallSize = CGSize(
                width: wallThickness,
                height: bounds.height + topPaletteOffset + topSafeAreaOffset)
        case .right:
            name = "wallRight"
            wallPosition = CGPoint(
                x: bounds.width,
                y: -topPaletteOffset - topSafeAreaOffset)
            wallSize = CGSize(
                width: wallThickness,
                height: bounds.height + topPaletteOffset + topSafeAreaOffset)
        }

        let node = RESceneNode(
            name: name,
            position: wallPosition,
            anchorPoint: CGPoint(x: 0.5, y: 0.5),
            physicsBody: REPhysicsRectBody(size: wallSize),
            size: wallSize
        )

        node.physicsBody.categoryBitMask = ColliderType.wall
        return node
    }
}

// MARK: - Interface

extension PlayViewModel {

    private func setupBucketViewModel(boardViewModel: PlayBoardViewModel) {
        let positionY = boardViewModel.contentHeight.value - BucketViewModel.defaultSize.height

        if bucketViewModel.value == nil {
            bucketViewModel.value = BucketViewModel(
                position: CGPoint(
                    x: boardViewModel.width / 2,
                    y: positionY))
        }

        guard let bucketViewModel = bucketViewModel.value else {
            return
        }

        bucketViewModel.position.y = max(
            bucketViewModel.position.y,
            positionY)
        self.bucketViewModel.value = { bucketViewModel }()
    }

    func setPlayBoardViewModelBounds(_ bounds: CGRect) {
        boardViewModel.value?.setBounds(bounds)

        if let boardViewModel = boardViewModel.value {
            setupBucketViewModel(boardViewModel: boardViewModel)
        }
    }

    func getContentOffset() -> CGPoint {
        guard let ballViewModel = cannonViewModel.ballViewModel.value,
              let boardViewModel = boardViewModel.value else {
                  return CGPoint()
              }

        var offsetY = ballViewModel.center.y - boardViewModel.height / 2
        offsetY = max(offsetY, 0)
        offsetY = min(offsetY, boardViewModel.contentHeight.value - boardViewModel.height)

        return CGPoint(x: 0, y: offsetY)
    }

    func getCannonImage() -> UIImage {
        cannonViewModel.image
    }

    func removePeg(at center: CGPoint) {
        let removedPegViewModel = boardViewModel.value?.removePeg(at: center)
        if let nodeId = removedPegViewModel?.sceneNodeId {
            _ = scene?.removeNode(forId: nodeId)
        }
    }

    func removeBlock(at position: CGPoint) {
        let removedBlockViewModel = boardViewModel.value?.removePeg(at: position)
        if let nodeId = removedBlockViewModel?.sceneNodeId {
            _ = scene?.removeNode(forId: nodeId)
        }
    }

    func rotateCannon(panTranslation: CGPoint) {
        let currAngle: Double = self.cannonViewModel.rotationAngle.value

        let diff = userDefaults.double(forKey: "cannonRotationOffset")
        let quarterAngle: Double = (.pi / 2)

        let angleToRotate = quarterAngle * (panTranslation.x / diff)
        let newAngle = currAngle + (angleToRotate * -1)

        if newAngle < quarterAngle, newAngle > -quarterAngle {
            self.cannonViewModel.rotationAngle.value = newAngle
        }
    }

}

// MARK: - Interface: Binders

extension PlayViewModel {

    func bindToBallViewModel(_ listener: @escaping(BallViewModel?) -> Void) {
        self.cannonViewModel.ballViewModel.bind(listener, notifyInitialValue: false)
    }

    func bindToGameStats(_ listener: @escaping(GameStats) -> Void) {
        self.boardViewModel.value?.gameStats.bind(listener)
    }

    func bindToBucketViewModel(_ listener: @escaping(BucketViewModel?) -> Void) {
        self.bucketViewModel.bind(listener)
    }

    func bindToContentHeight(_ listener: @escaping(Double) -> Void) {
        self.boardViewModel.value?.contentHeight.bind(listener)
    }

    func bindToRotationAngle(_ listener: @escaping(Double) -> Void) {
        self.cannonViewModel.rotationAngle.bind(listener)
    }

    func bindToPegViewModels(_ listener: @escaping([CGPoint: PlayPegViewModel]) -> Void) {
        self.boardViewModel.value?.pegViewModels.bind(listener)
    }

    func bindToBlockViewModels(_ listener: @escaping([CGPoint: PlayBlockViewModel]) -> Void) {
        self.boardViewModel.value?.blockViewModels.bind(listener)
    }

}
