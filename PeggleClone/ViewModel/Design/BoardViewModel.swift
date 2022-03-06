//
//  BoardViewModel.swift
//  PeggleClone
//
//  Created by Kyle キラ on 30/1/22.
//

import UIKit

final class BoardViewModel {

    static let backgroundImage: UIImage  = #imageLiteral(resourceName: "background")
    static var backgroundImageData: Data {
        backgroundImage.pngData() ?? Data()
    }

    let boardDataManager = BoardDataManager()
    let userDefaults = UserDefaults.standard
    var board: Board? {
        didSet {
            self.isPreloaded = false
        }
    }

    lazy var imageView = {
        UIImage(data: image.value)
    }()

    var selectedItem: ObservableObject<BoardItemViewModel?> = ObservableObject(nil)
    var itemPanned: ObservableObject<ItemPanned?> = ObservableObject(nil)
    var blockCornerPanned: ObservableObject<BlockCornerPanned?> = ObservableObject(nil)
    var isBoardNew = ObservableObject<Bool>(true)
    var isPreloaded: Bool
    var width: Double?
    var height: Double?
    var contentHeight: ObservableObject<Double?>
    var name: ObservableObject<String>
    var image: ObservableObject<Data>
    var pegViewModels: ObservableObject<[CGPoint: PegViewModel]> = ObservableObject([:])
    var blockViewModels: ObservableObject<[CGPoint: BlockViewModel]> = ObservableObject([:])
    var orangePegViewModels: [PegViewModel] {
        let pegViewModels = pegViewModels.value.values
        return pegViewModels.filter {
            $0.pegType == .orange
        }
    }
    var bounds: CGRect? {
        guard let contentBoundsSize = contentBoundsSize else {
            return nil
        }

        return CGRect(origin: CGPoint(), size: contentBoundsSize)
    }
    var contentBoundsSize: CGSize? {
        guard let width = width,
              let contentHeight = contentHeight.value else {
            return nil
        }

        return CGSize(width: width, height: contentHeight)
    }
    var boundsSize: CGSize? {
        guard let width = width,
                let height = height else {
            return nil
        }

        return CGSize(width: width, height: height)
    }

    init(board: Board?) {
        if board != nil {
            self.isBoardNew.value = false
        }

        self.board = board
        let defaultBoardName = userDefaults.string(forKey: "CreateNewBoardText") ?? ""
        self.name = ObservableObject(board?.name ?? defaultBoardName)
        self.image = ObservableObject(board?.image ?? BoardViewModel.backgroundImageData)
        self.isPreloaded = board?.isPreloaded ?? true
        self.width = board?.width
        self.height = board?.height
        self.contentHeight = ObservableObject(board?.contentHeight)

        board?.pegs?.forEach { [weak self] peg in
            guard let peg = peg as? Peg else {
                return
            }
            let pegViewModel = PegViewModel(peg: peg)

            self?.pegViewModels.value[pegViewModel.center] = pegViewModel

        }

        board?.blocks?.forEach { [weak self] block in
            guard let block = block as? Block else {
                return
            }
            let blockViewModel = BlockViewModel(block: block)

            self?.blockViewModels.value[blockViewModel.position] = blockViewModel
        }
    }

}

// MARK: - Interface: CoreData

extension BoardViewModel {

    func setName(_ name: String) {
        self.name.value = name
    }

    func setImage(_ image: Data) {
        self.image.value = image
    }

    func addPeg(to center: CGPoint, pegType: PegType, radius: Double = PegViewModel.defaultRadius) {
        let pegViewModelToAdd = PegViewModel(center: center, pegType: pegType, radius: radius)
        pegViewModels.value[center] = pegViewModelToAdd
    }

    func removePeg(at center: CGPoint) -> PegViewModel? {
        let pegViewModelToRemove = pegViewModels.value.removeValue(forKey: center)
        return pegViewModelToRemove
    }

    func updatePeg(
        from initialLocation: CGPoint,
        to finalLocation: CGPoint,
        radius newRadius: Double = PegViewModel.defaultRadius) {

            let pegViewModelToUpdate = removePeg(at: initialLocation)

            if let pegViewModelToUpdate = pegViewModelToUpdate {

                addPeg(to: finalLocation, pegType: pegViewModelToUpdate.pegType, radius: newRadius)
            }
        }

    func addBlock(path: CGPath) {
        let blockViewModelToAdd = BlockViewModel(path: path)
        blockViewModels.value[blockViewModelToAdd.position] = blockViewModelToAdd
    }

    func removeBlock(at position: CGPoint) -> BlockViewModel? {
        let blockViewModelToRemove = blockViewModels.value.removeValue(forKey: position)
        return blockViewModelToRemove
    }

    func updateBlock(from initialLocation: CGPoint, to newPath: CGPath) {

        let blockViewModelToUpdate = removeBlock(at: initialLocation)

        if blockViewModelToUpdate != nil {
            addBlock(path: newPath)
        }
    }

    func reset() {
        pegViewModels.value.removeAll()
        blockViewModels.value.removeAll()
    }

    func delete() throws {
        guard let board = board else {
            return
        }

        try boardDataManager.deleteBoard(board)
    }
}
