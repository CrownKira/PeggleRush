//
//  BoardsViewModel.swift
//  PeggleClone
//
//  Created by Kyle キラ on 6/2/22.
//

import UIKit
import CoreData

final class BoardsViewModel {

    private var boardDataManager = BoardDataManager()
    private var boardViewModels: ObservableObject<[BoardViewModel]> = ObservableObject([])
    private var fetchedTemplatesController: NSFetchedResultsController<Board>?
    private var preloadedBoardViewModels: [BoardViewModel] {
        fetchedTemplatesController?.fetchedObjects?.compactMap {
            BoardViewModel(board: $0)
        } ?? []
    }

    var selectedBoardViewModel: ObservableObject<BoardViewModel?> = ObservableObject(nil)
    var boardViewModelsCount: Int {
        boardViewModels.value.count
    }
    var preloadedBoardViewModelsCount: Int {
        fetchedTemplatesController?.fetchedObjects?.count ?? 0
    }

}

// MARK: - Interface

extension BoardsViewModel {

    func fetchBoardViewModels(for viewController: BoardsViewController) throws {
        fetchedTemplatesController = try boardDataManager.getFetchedTemplatesController(delegate: viewController)

        let boards = try boardDataManager.fetchBoards(includesPendingChanges: false)
        self.boardViewModels.value = boards.compactMap {
            BoardViewModel(board: $0)
        }
    }

    func getSelectedBoardViewModel(for indexPath: IndexPath) {
        self.selectedBoardViewModel.value = getBoardViewModel(for: indexPath)
    }

    func getBoardViewModel(for indexPath: IndexPath) -> BoardViewModel? {
        let section = indexPath.section
        let index = indexPath.row

        if section == 0 {
            return index == 0
            ? BoardViewModel(board: nil)
            : preloadedBoardViewModels[index - 1]
        }

        return boardViewModels.value[index]
    }

    func getBoardViewModelsCount(section: Int) -> Int {
        if section == 0 {
            return preloadedBoardViewModelsCount + 1
        }

        return boardViewModelsCount
    }

    func getAlertText(from errorCode: NSInteger) -> AlertStatus {

        switch errorCode {
        case NSCoreDataError:
            return AlertStatus(
                title: "Please try again",
                message: "The storage is experiencing some problem now. Please try again later.")
        default:
            return AlertStatus(
                title: "Please try again",
                message: "An unknown error has occurred")
        }
    }

    func bindToBoardViewModels(_ listener: @escaping([BoardViewModel]) -> Void) {
        self.boardViewModels.bind(listener)
    }
}
