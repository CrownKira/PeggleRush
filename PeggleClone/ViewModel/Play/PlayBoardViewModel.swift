//
//  PlayBoardViewModel.swift
//  PeggleClone
//
//  Created by Kyle キラ on 30/1/22.
//

import UIKit

final class PlayBoardViewModel {

    private let userDefaults = UserDefaults.standard

    var gameStats = ObservableObject<GameStats>(
        GameStats())
    var pegViewModels: ObservableObject<[CGPoint: PlayPegViewModel]> = ObservableObject([:])
    var blockViewModels: ObservableObject<[CGPoint: PlayBlockViewModel]> = ObservableObject([:])
    var width: Double
    var height: Double
    var contentHeight: ObservableObject<Double>
    var bounds: CGRect {
        CGRect(x: 0, y: 0, width: width, height: contentHeight.value)
    }
    var orangePegViewModels: [PlayPegViewModel] {
        let pegViewModels = pegViewModels.value.values
        return pegViewModels.filter {
            $0.pegType == .orange
        }
    }

    init?(boardViewModel: BoardViewModel) {
        guard let width = boardViewModel.width,
              let height = boardViewModel.height,
              let contentHeight = boardViewModel.contentHeight.value else {
                  return nil
              }

        self.height = height
        self.width = width
        self.contentHeight = ObservableObject(contentHeight)

        boardViewModel.pegViewModels.value.values.forEach { [weak self] pegViewModel in
            let playPegViewModel = PlayPegViewModel(pegViewModel: pegViewModel)

            self?.pegViewModels.value[playPegViewModel.center] = playPegViewModel
        }

        boardViewModel.blockViewModels.value.values.forEach { [weak self] blockViewModel in
            let playBlockViewModel = PlayBlockViewModel(blockViewModel: blockViewModel)

            self?.blockViewModels.value[playBlockViewModel.position] = playBlockViewModel
        }

        self.gameStats.value = GameStats(orangePegsTotal: boardViewModel.orangePegViewModels.count, ballsTotal: 10)
    }
}

// MARK: - Interface

extension PlayBoardViewModel {

    func removePeg(at center: CGPoint) -> PlayPegViewModel? {
        pegViewModels.value.removeValue(forKey: center)
    }

    func removeBlock(at position: CGPoint) -> PlayBlockViewModel? {
        blockViewModels.value.removeValue(forKey: position)
    }

    func setPegToPop(near position: CGPoint) {

        guard let nearestPegViewModel = getNearestPegViewModel(to: position) else {
            return
        }

        nearestPegViewModel.shouldPopPrematurely = true
        pegViewModels.value[nearestPegViewModel.center] = nearestPegViewModel

    }

    private func getNearestPegViewModel(to position: CGPoint) -> PlayPegViewModel? {
        var nearestPegViewModel: PlayPegViewModel?
        var nearestDiff: Double?

        for pegViewModel in pegViewModels.value.values {
            guard pegViewModel.isLit else {
                continue
            }

            let diffX = abs(pegViewModel.center.x - position.x)
            let diffY = abs(pegViewModel.center.y - position.y)
            let diff = diffX + diffY

            guard let currDiff = nearestDiff,
                  nearestPegViewModel != nil else {
                      nearestDiff = diff
                      nearestPegViewModel = pegViewModel
                      continue
                  }

            if diff < currDiff {
                nearestDiff = diff
                nearestPegViewModel = pegViewModel
            }
        }
        return nearestPegViewModel
    }

    func getPegViewModel(at center: CGPoint) -> PlayPegViewModel? {
        pegViewModels.value[center]
    }

    func getBlockViewModel(at position: CGPoint) -> PlayBlockViewModel? {
        blockViewModels.value[position]
    }

    func setPegToLit(at center: CGPoint) {
        guard let pegViewModelToLit = pegViewModels.value[center] else {
            return
        }

        pegViewModelToLit.isLit = true
        pegViewModels.value[center] = pegViewModelToLit

        if pegViewModelToLit.pegType == .green {
            // Explodes and light up other pegs
            let explosionRadius = userDefaults.double(forKey: "explosionRadius")
            setPegsToLit(
                at: center, within: explosionRadius + pegViewModelToLit.radius)
        }
    }

    func setPegsToLit(at center: CGPoint, within radius: Double) {
        let kaboomRegion = Circle(radius: radius, center: center)

        for (centerB, pegViewModel) in pegViewModels.value {
            guard pegViewModel.intersects(withCircle: kaboomRegion) else {
                continue
            }
            if !pegViewModel.isLit {
                setPegToLit(at: centerB)
            }
        }
    }

    func updateBoardStates(didBallEnterBucket: Bool) {
        refreshPegViewModels()
        updateGameStats(didBallEnterBucket: didBallEnterBucket)
    }

    private func updateGameStats(didBallEnterBucket: Bool) {
        let prevGameStats = gameStats.value
        let ballIncrement = didBallEnterBucket ? 0 : -1

        self.gameStats.value = GameStats(
            orangePegsLeft: orangePegViewModels.count,
            orangePegsTotal: prevGameStats.orangePegsTotal,
            ballsLeft: prevGameStats.ballsLeft + ballIncrement,
            ballsTotal: prevGameStats.ballsTotal,
            scoreTotal: 0)
    }

    private func refreshPegViewModels() {
        pegViewModels.value = { pegViewModels.value }()
    }

    func setBounds(_ playBounds: CGRect) {

        if self.width != playBounds.width
            || self.height != playBounds.height {
            updatePegPositions(in: playBounds)
            updateBlockPositions(in: playBounds)
            updateContentHeight(in: playBounds)
        }

        self.width = playBounds.width
        self.height = playBounds.height

        self.contentHeight.value = max(self.contentHeight.value, playBounds.height)
    }

    private func updateContentHeight(in newBounds: CGRect) {

        let newHeight = newBounds.height
        let heightRatio = newHeight / height

        self.contentHeight.value = heightRatio * contentHeight.value
    }

    private func updateBlockPositions(in newBounds: CGRect) {

        var newBlockViewModels = [CGPoint: PlayBlockViewModel]()

        let newWidth = newBounds.width
        let newHeight = newBounds.height
        let widthRatio = newWidth / width
        let heightRatio = newHeight / height

        for (position, blockViewModel) in blockViewModels.value {
            let x = position.x
            let y = position.y

            let newX = widthRatio * x
            let newY = heightRatio * y
            let newPosition = CGPoint(x: newX, y: newY)

            blockViewModel.position = newPosition
            newBlockViewModels[newPosition] = blockViewModel
        }

        blockViewModels.value = newBlockViewModels
    }

    private func updatePegPositions(in newBounds: CGRect) {

        var newPegViewModels = [CGPoint: PlayPegViewModel]()

        let newWidth = newBounds.width
        let newHeight = newBounds.height
        let widthRatio = newWidth / width
        let heightRatio = newHeight / height

        for (center, pegViewModel) in pegViewModels.value {
            let x = center.x
            let y = center.y

            let newX = widthRatio * x
            let newY = heightRatio * y
            let newCenter = CGPoint(x: newX, y: newY)

            pegViewModel.setCenter(newCenter)
            newPegViewModels[newCenter] = pegViewModel
        }

        pegViewModels.value = newPegViewModels
    }
}
