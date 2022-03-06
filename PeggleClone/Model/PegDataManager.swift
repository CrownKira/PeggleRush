//
//  PegDataManager.swift
//  PeggleClone
//
//  Created by Kyle キラ on 6/2/22.
//

import UIKit
import CoreData

class PegDataManager {

    private let mainContext: NSManagedObjectContext

    init(mainContext: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.mainContext = mainContext
    }

    func createPeg(board: Board, pegType: PegType, radius: Double,
                   rotation: Double, point: CGPoint) throws -> Peg? {
        let peg: Peg

        switch pegType {
        case .blue:
            peg = BluePeg(context: mainContext)
        case .orange:
            peg = OrangePeg(context: mainContext)
        case .green:
            peg = GreenPeg(context: mainContext)
        case .purple:
            peg = PurplePeg(context: mainContext)
        }

        peg.board = board
        peg.x = point.x
        peg.y = point.y
        peg.radius = radius
        peg.rotation = rotation

        try mainContext.save()

        return peg
    }

    func deletePeg(_ peg: Peg) throws {
        let objectID = peg.objectID

        if let pegInContext = try? mainContext.existingObject(with: objectID) {
            mainContext.delete(pegInContext)
            try mainContext.save()
        }
    }

    func updatePeg(_ peg: Peg, location: CGPoint) throws {
        peg.x = location.x
        peg.y = location.y

        try mainContext.save()
    }

    func fetchPeg(withBoard board: Board, location: CGPoint) throws -> Peg? {
        let fetchRequest = Peg.fetchRequest() as NSFetchRequest<Peg>
        fetchRequest.fetchLimit = 1

        let predicate = BoardLocationMatchPredicate(
            board: board,
            location: location)

        fetchRequest.predicate = predicate

        let pegs = try mainContext.fetch(fetchRequest)

        return pegs.first
    }

    func fetchPegs(includesPendingChanges: Bool) throws -> [Peg] {

        let fetchRequest = Peg.fetchRequest() as NSFetchRequest<Peg>
        fetchRequest.includesPendingChanges = includesPendingChanges

        let pegs = try mainContext.fetch(fetchRequest)

        return pegs

    }
}
