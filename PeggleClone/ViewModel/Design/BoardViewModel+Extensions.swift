//
//  BoardViewModel+Extensions.swift
//  PeggleClone
//
//  Created by Kyle キラ on 27/2/22.
//

import UIKit

// MARK: - Interface

extension BoardViewModel {

    func setBounds(_ bounds: CGRect) {

        if contentHeight.value == nil {
            contentHeight.value = bounds.height
        }

        if self.width != bounds.width
            || self.height != bounds.height {
            updatePegPositions(in: bounds)
            updateBlockPositions(in: bounds)
            updateContentHeight(in: bounds)
        }

        self.width = bounds.width
        self.height = bounds.height
    }

    func setContentHeight(_ contentHeight: Double) throws {

        guard isValidContentHeight(contentHeight) else {
            throw ValidationError.invalidContentHeight
        }

        self.contentHeight.value = contentHeight
    }

    func rotateSelectedItem(to angle: Double) throws {
        if let selectedBlock = (selectedItem.value as? BlockViewModel) {
            let newPath = selectedBlock.path.rotate(to: angle)
            if !hasValidBlockPath(newPath, excludedBlockViewModel: selectedBlock) {
                throw ValidationError.invalidAngle
            }
        }

        selectedItem.value?.rotate(to: angle)
        refreshBoardItems()
    }

    func resizeSelectedItem(to width: Double) throws {

        if let selectedBlock = (selectedItem.value as? BlockViewModel) {
            let newPath = selectedBlock.path.resized(to: width)

            if !hasValidBlockPath(newPath, excludedBlockViewModel: selectedBlock) {
                throw ValidationError.invalidSize
            }
        }

        if let selectedPeg = (selectedItem.value as? PegViewModel) {
            let newPegFrame = CGRect(
                origin: selectedPeg.frame.origin,
                size: CGSize(
                    width: width,
                    height: width))

            if !hasValidPegLocation(pegFrame: newPegFrame, excludedPegViewModel: selectedPeg) {
                throw ValidationError.invalidSize
            }

        }

        selectedItem.value?.resize(to: width)
        refreshBoardItems()
    }

    func refreshBoardItems() {
        refreshPegViewModels()
        refreshBlockViewModels()
    }

    private func refreshPegViewModels() {
        var newPegViewModels = [CGPoint: PegViewModel]()
        for (_, pegViewModel) in pegViewModels.value {
            newPegViewModels[pegViewModel.center] = pegViewModel
        }
        pegViewModels.value = newPegViewModels
    }

    private func refreshBlockViewModels() {
        var newBlockViewModels = [CGPoint: BlockViewModel]()
        for (_, blockViewModel) in blockViewModels.value {
            newBlockViewModels[blockViewModel.position] = blockViewModel
        }
        blockViewModels.value = newBlockViewModels
    }

    private func isValidContentHeight(_ contentHeight: Double) -> Bool {
        for (position, pegViewModel) in pegViewModels.value {
            let bottomY = position.y + pegViewModel.size.height / 2
            if bottomY > contentHeight {
                return false
            }
        }

        return true
    }

    private func updateContentHeight(in newBounds: CGRect) {
        guard let height = height, let contentHeight = contentHeight.value else {
            return
        }

        let newHeight = newBounds.height
        let heightRatio = newHeight / height

        self.contentHeight.value = heightRatio * contentHeight
    }

    private func updateBlockPositions(in newBounds: CGRect) {
        guard let width = width, let height = height else {
            return
        }

        var newBlockViewModels = [CGPoint: BlockViewModel]()

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
        guard let width = width, let height = height else {
            return
        }

        var newPegViewModels = [CGPoint: PegViewModel]()

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

    func hasValidPegLocation(pegFrame: CGRect, excludedPegViewModel: PegViewModel? = nil) -> Bool {

        guard let bounds = bounds else {
            return false
        }

        let pegViewModels = pegViewModels.value
        let blockViewModels = blockViewModels.value

        let pegViewModel = PegViewModel(frame: pegFrame)

        let pegsDoNotOverlap = pegViewModels.allSatisfy {
            let isItself = $0.value == excludedPegViewModel
            let noIntersectionsWithOther = !pegViewModel.intersects(withCircle: $0.value)
            return isItself || noIntersectionsWithOther
        }

        let pegNotIntersectingBlocks = blockViewModels.allSatisfy {
            !pegViewModel.intersects(withShape: $0.value)
        }

        let pegWithinBounds = bounds.contains(pegFrame)

        return pegsDoNotOverlap
        && pegWithinBounds
        && pegNotIntersectingBlocks
    }

    func hasValidBlockPath(
        _ blockPath: CGPath,
        excludedBlockViewModel: BlockViewModel?) -> Bool {

            guard let bounds = bounds else {
                return false
            }

            let pegViewModels = pegViewModels.value
            let blockViewModels = blockViewModels.value

            let blockViewModel = BlockViewModel(path: blockPath)
            let blockWithinBounds = bounds.contains(blockPath.boundingBox)

            let blockNotIntersectingPegs = pegViewModels.allSatisfy {
                !blockViewModel.intersects(withCircle: $0.value)
            }

            let blocksDoNotOverlap = blockViewModels.allSatisfy {

                let isItself = $0.value == excludedBlockViewModel
                let noIntersectionWithOther =  !blockViewModel.intersects(withShape: $0.value)

                return isItself || noIntersectionWithOther
            }

            return blockWithinBounds
            && blockNotIntersectingPegs
            && blocksDoNotOverlap
        }

    func isValidNewPegCenter(_ center: CGPoint) -> Bool {

        let pegFrameToCheck = CGRect(
            x: center.x - PegViewModel.defaultRadius,
            y: center.y - PegViewModel.defaultRadius,
            width: PegViewModel.defaultDiameter,
            height: PegViewModel.defaultDiameter)

        return hasValidPegLocation(pegFrame: pegFrameToCheck, excludedPegViewModel: nil)
    }

    func updateBlockToPannedShape() throws {

        guard let blockCornerPanned = blockCornerPanned.value else {
            return
        }

        let newPath = blockCornerPanned.newPath
        let blockViewModel = blockCornerPanned.blockViewModel

        guard hasValidBlockPath(newPath, excludedBlockViewModel: blockViewModel) else {
            throw ValidationError.invalidBlockShape
        }

        guard blockCornerPanned.newPath.boundingBox.width < blockViewModel.maxWidth else {
            throw ValidationError.invalidSize
        }

        updateBlock(from: blockCornerPanned.blockViewModel.position, to: newPath)

        selectedItem.value = nil
    }

    func updateItemToPannedLocation() throws {
        guard let itemPanned = itemPanned.value else {
            return
        }
        if let pegViewModel = (itemPanned.viewModel as? PegViewModel) {

            guard hasValidPegLocation(
                pegFrame: itemPanned.pegView.frame,
                excludedPegViewModel: pegViewModel
            ) else {
                throw ValidationError.invalidItemLocation
            }

            updatePeg(
                from: CGPoint(
                    x: pegViewModel.center.x,
                    y: pegViewModel.center.y),
                to: CGPoint(
                    x: itemPanned.location.x + pegViewModel.radius,
                    y: itemPanned.location.y + pegViewModel.radius),
                radius: pegViewModel.radius
            )
        }

        if let blockViewModel = (itemPanned.viewModel as? BlockViewModel) {

            let newPath = blockViewModel.path.translateTo(position: itemPanned.location)

            guard hasValidBlockPath(newPath, excludedBlockViewModel: blockViewModel) else {
                throw ValidationError.invalidItemLocation
            }

            updateBlock(from: blockViewModel.position, to: newPath)
        }

        selectedItem.value = nil
    }

    func save() throws {
        guard let boundsSize = boundsSize,
              let contentHeight = contentHeight.value else {
                  return
              }

        do {
            if !isPreloaded, let board = board {
                // If board exists, updates the board
                // Resets the board first
                try boardDataManager.resetPegs(board)
                try boardDataManager.resetBlocks(board)

                // then Adds the current pegs to board
                try pegViewModels.value.values.forEach {
                    try $0.save(board: board)
                }

                try blockViewModels.value.values.forEach {
                    try $0.save(board: board)
                }

                try boardDataManager.updateBoard(
                    board, name: name.value,
                    image: image.value,
                    boundsSize: boundsSize, contentHeight: contentHeight)

            } else {
                // Otherwise, creates a new board
                guard let newBoard = try boardDataManager.createBoard(
                    name: name.value,
                    image: image.value,
                    boundsSize: boundsSize,
                    contentHeight: contentHeight) else {
                        return
                    }

                // Saves the peg one by one to the new board
                try pegViewModels.value.values.forEach {
                    try $0.save(board: newBoard)
                }

                try blockViewModels.value.values.forEach {
                    try $0.save(board: newBoard)
                }
                self.board = newBoard
            }

            self.isBoardNew.value = false
        } catch {
            boardDataManager.removeUnsavedChanges()
            throw error
        }
    }
}
