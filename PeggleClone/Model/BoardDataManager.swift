//
//  BoardDataManager.swift
//  PeggleClone
//
//  Created by Kyle キラ on 6/2/22.
//

import UIKit
import CoreData

class BoardDataManager {

    private let mainContext: NSManagedObjectContext

    init(mainContext: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.mainContext = mainContext
    }

    func createBoard(name: String, image: Data,
                     boundsSize: CGSize,
                     contentHeight: Double,
                     pegs: NSSet = [], isPreloaded: Bool = false) throws -> Board? {
        let board = Board(context: mainContext)

        board.isPreloaded = isPreloaded
        board.lastSavedAt = Date()
        board.name = name
        board.image = image
        board.addToPegs(pegs)
        board.width = boundsSize.width
        board.height = boundsSize.height
        board.contentHeight = contentHeight

        try mainContext.save()

        return board
    }

    func deleteBoard(_ board: Board) throws {
        let objectID = board.objectID

        if let boardInContext = try? mainContext.existingObject(with: objectID) {

            mainContext.delete(boardInContext)
            try mainContext.save()
        }
    }

    func updateBoard(
        _ board: Board, name: String, image: Data,
        boundsSize: CGSize, contentHeight: Double, pegs: NSSet = []) throws {

            board.lastSavedAt = Date()
            board.name = name
            board.image = image
            board.addToPegs(pegs)
            board.width = boundsSize.width
            board.height = boundsSize.height
            board.contentHeight = contentHeight

            try mainContext.save()
        }

    func addPegsToBoard(_ board: Board, pegs: NSSet) throws {
        board.addToPegs(pegs)

        try mainContext.save()
    }

    func removePegsFromBoard(_ board: Board, pegs: NSSet) throws {
        board.removeFromPegs(pegs)
        try mainContext.save()
    }

    func resetPegs(_ board: Board) throws {
        board.pegs = []
        try mainContext.save()
    }

    func resetBlocks(_ board: Board) throws {
        board.blocks = []
        try mainContext.save()
    }

    func fetchBoard(withName name: String) throws -> Board? {
        let fetchRequest = Board.fetchRequest() as NSFetchRequest<Board>
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)

        let boards = try mainContext.fetch(fetchRequest)

        return boards.first
    }

    func fetchPreloadedBoards(includesPendingChanges: Bool) throws -> [Board] {

        let fetchRequest = Board.fetchRequest() as NSFetchRequest<Board>

        // Sorts by last saved at in descending order
        let sortByLastSaved = NSSortDescriptor(key: "lastSavedAt", ascending: false)
        fetchRequest.sortDescriptors = [sortByLastSaved]

        fetchRequest.predicate = NSPredicate(
            format: "isPreloaded == true")

        fetchRequest.includesPendingChanges = includesPendingChanges

        let boards = try mainContext.fetch(fetchRequest)

        return boards
    }

    func fetchBoards(includesPendingChanges: Bool) throws -> [Board] {

        let fetchRequest = Board.fetchRequest() as NSFetchRequest<Board>

        // Sorts by last saved at in descending order
        let sortByLastSaved = NSSortDescriptor(key: "lastSavedAt", ascending: false)
        fetchRequest.sortDescriptors = [sortByLastSaved]

        fetchRequest.predicate = NSPredicate(
            format: "isPreloaded == false")

        fetchRequest.includesPendingChanges = includesPendingChanges

        let boards = try mainContext.fetch(fetchRequest)

        return boards
    }

    func getFetchedTemplatesController(
        delegate: NSFetchedResultsControllerDelegate ) throws -> NSFetchedResultsController<Board> {
            let fetchRequest = Board.fetchRequest() as NSFetchRequest<Board>

            // Sorts by last saved at in descending order
            let sortByLastSaved = NSSortDescriptor(key: "lastSavedAt", ascending: false)
            fetchRequest.sortDescriptors = [sortByLastSaved]

            fetchRequest.predicate = NSPredicate(
                format: "isPreloaded == true")

            fetchRequest.includesPendingChanges = false

            let fetchedResultsController = NSFetchedResultsController(
                fetchRequest: fetchRequest,
                managedObjectContext: mainContext,
                sectionNameKeyPath: nil, cacheName: nil)

            fetchedResultsController.delegate = delegate

            try fetchedResultsController.performFetch()

            return fetchedResultsController
        }

    // Runs after every unsuccessful save
    func removeUnsavedChanges() {
        mainContext.rollback()
    }
}
