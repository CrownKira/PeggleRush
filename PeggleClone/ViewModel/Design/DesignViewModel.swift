//
//  DesignViewModel.swift
//  PeggleClone
//
//  Created by Kyle キラ on 6/2/22.
//

import UIKit
import CoreData

final class DesignViewModel {

    var boardViewModel: ObservableObject<BoardViewModel?> = ObservableObject(nil)
    var selectedButton: ObservableObject<ButtonType> = ObservableObject(.blue)
    var boardNameText: String
    var hasChanges = false
    var isBoardViewModelLoaded: Bool {
        boardViewModel.value != nil
    }
    var isEraseButtonSelected: Bool {
        selectedButton.value == ButtonType.erase
    }

    init(boardViewModel: BoardViewModel?) {
        self.boardViewModel.value = boardViewModel
        self.boardNameText = boardViewModel?.name.value ?? ""
        setupBinders()
    }

}

// MARK: - Interface

extension DesignViewModel {

    private func setupBinders() {
        self.boardViewModel.value?.name.bind(setDirty, notifyInitialValue: false)
        self.boardViewModel.value?.image.bind(setDirty, notifyInitialValue: false)
        self.boardViewModel.value?.pegViewModels.bind(setDirty, notifyInitialValue: false)
    }

    private func setDirty(_: Any) {
        hasChanges = true
    }

    func setBoardContentHeight(_ contentHeight: Double) throws {
        try boardViewModel.value?.setContentHeight(contentHeight)
    }

    func setBoardViewModelBounds(_ bounds: CGRect) {
        boardViewModel.value?.setBounds(bounds)
    }

    func setSelectedBoardItem(boardItem: BoardItemViewModel) {
        if isEraseButtonSelected {
            if let pegViewModel = (boardItem as? PegViewModel) {
                removePeg(at: pegViewModel.center)
            }

            if let blockViewModel = (boardItem as? BlockViewModel) {
                removeBlock(at: blockViewModel.position)
            }
        }

        boardViewModel.value?.selectedItem.value = boardItem
    }

    func setSelectedButton(tag: Int) {
        guard let buttonType = ButtonType(rawValue: tag) else {
            return
        }

        selectedButton.value = buttonType
    }

    func getDeleteAlertText(from errorCode: NSInteger) -> AlertStatus {

        switch errorCode {
        default:
            return AlertStatus(
                title: "Please try again",
                message: "An unknown error has occurred")
        }
    }

    func getSaveAlertText(from errorCode: NSInteger) -> AlertStatus {

        switch errorCode {
        case NSManagedObjectConstraintMergeError:
            return AlertStatus(
                title: "Please try a different name",
                message: "A board with that name already exists")
        case NSValidationStringTooShortError:
            return AlertStatus(
                title: "Name too short",
                message: "Board name should be at least 3 characters")
        case NSValidationStringTooLongError:
            return AlertStatus(
                title: "Name too long",
                message: "Board name should be no more than 50 characters")
        default:
            return AlertStatus(
                title: "Please try again",
                message: "An unknown error has occurred")
        }
    }

    func getItemPanned() -> ItemPanned? {
        boardViewModel.value?.itemPanned.value
    }

    func getBlockCornerPanned() -> BlockCornerPanned? {
        boardViewModel.value?.blockCornerPanned.value
    }

    func getBlockCornerPannedOrigin() -> CGPoint? {
        boardViewModel.value?.blockCornerPanned.value?.origin
    }

    func getBlockCornerPannedOriginPath() -> CGPath? {
        boardViewModel.value?.blockCornerPanned.value?.blockViewModel.path
    }

    func hasValidPegLocation(pegFrame: CGRect) -> Bool {
        boardViewModel.value?.hasValidPegLocation(pegFrame: pegFrame) ?? false
    }

}

// MARK: - Interface: BoardViewModel

extension DesignViewModel {

    func setItemPanned(_ itemPanned: ItemPanned) {
        self.boardViewModel.value?.itemPanned.value = itemPanned
    }

    func setBlockCornerPanned(_ blockCornerPanned: BlockCornerPanned) {
        self.boardViewModel.value?.blockCornerPanned.value = blockCornerPanned
    }

    func setBoardViewModelName(_ name: String) {
        self.boardViewModel.value?.setName(name)
    }

    func setBoardViewModelImage(_ image: Data) {
        self.boardViewModel.value?.setImage(image)
    }

    func rotateSelectedItem(to angle: Double) throws {
        try self.boardViewModel.value?.rotateSelectedItem(to: angle)
    }

    func resizeSelectedItem(to width: Double) throws {
        try self.boardViewModel.value?.resizeSelectedItem(to: width)
    }

    func addItem(to center: CGPoint) {

        guard let boardViewModel = boardViewModel.value else {
            return
        }

        if let pegType = PegType(rawValue: selectedButton.value.rawValue) {
            guard boardViewModel.isValidNewPegCenter(
                center) else {
                    return
                }

            boardViewModel.addPeg(to: center, pegType: pegType)
        }

        if selectedButton.value == .triangle {
            let defaultTrianglePath = CGPath.createIsoscelesTriangle(
                at: center, size: BlockViewModel.defaultSize)

            guard boardViewModel.hasValidBlockPath(defaultTrianglePath, excludedBlockViewModel: nil) else {
                return
            }

            boardViewModel.addBlock(path: defaultTrianglePath)
        }
    }

    func removePeg(at location: CGPoint) {
        _ = boardViewModel.value?.removePeg(at: location)
    }

    func removeBlock(at location: CGPoint) {
        _ = boardViewModel.value?.removeBlock(at: location)
    }

    func updatePeg(from initialLocation: CGPoint, to finalLocation: CGPoint) {
        boardViewModel.value?.updatePeg(from: initialLocation, to: finalLocation)
    }

    func updateBlock(from initialLocation: CGPoint, to newPath: CGPath) {
        boardViewModel.value?.updateBlock(from: initialLocation, to: newPath)
    }

    func updateBlockToPannedShape() throws {
        do {
            try boardViewModel.value?.updateBlockToPannedShape()
        } catch ValidationError.invalidBlockShape {
            boardViewModel.value?.refreshBoardItems()
            throw ValidationError.invalidBlockShape
        } catch ValidationError.invalidSize {
            boardViewModel.value?.refreshBoardItems()
            throw ValidationError.invalidSize
        }
    }

    func updateItemToPannedLocation() throws {
        try boardViewModel.value?.updateItemToPannedLocation()
    }

    func reset() {
        boardViewModel.value?.reset()
    }

    func delete() throws {
        try boardViewModel.value?.delete()
    }

    func save() throws {
        try boardViewModel.value?.save()
    }
}

// MARK: - Interface: Binders

extension DesignViewModel {

    func bindToSelectedBoardItemViewModel(_ listener: @escaping(BoardItemViewModel?) -> Void) {
        self.boardViewModel.value?.selectedItem.bind(listener)
    }

    func bindToBoardSaveStatus(_ listener: @escaping(Bool) -> Void) {
        self.boardViewModel.value?.isBoardNew.bind(listener)
    }

    func bindToPegViewModels(_ listener: @escaping([CGPoint: PegViewModel]) -> Void) {
        self.boardViewModel.value?.pegViewModels.bind(listener)
    }

    func bindToBlockViewModels(_ listener: @escaping([CGPoint: BlockViewModel]) -> Void) {
        self.boardViewModel.value?.blockViewModels.bind(listener)
    }

    func bindToContentHeight(_ listener: @escaping(Double?) -> Void) {
        self.boardViewModel.value?.contentHeight.bind(listener)
    }

    func bindToItemPanned(_ listener: @escaping(ItemPanned?) -> Void) {
        self.boardViewModel.value?.itemPanned.bind(listener)
    }

    func bindToBlockCornerPanned(_ listener: @escaping(BlockCornerPanned?) -> Void) {
        self.boardViewModel.value?.blockCornerPanned.bind(listener)
    }
}
