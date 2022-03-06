//
//  BlockDataManager.swift
//  PeggleClone
//
//  Created by Kyle キラ on 6/2/22.
//

import UIKit
import CoreData

class BlockDataManager {

    private let mainContext: NSManagedObjectContext

    init(mainContext: NSManagedObjectContext = CoreDataStack.shared.mainContext) {
        self.mainContext = mainContext
    }

    func createBlock(board: Board, forceConstant: Double, corners: [CGPoint] = []) throws -> Block? {
        guard corners.count > 2 else {
            return nil
        }

        let corners = NSSet(array: corners.map {
            let corner = CornerPoint(context: mainContext)
            corner.x = $0.x
            corner.y = $0.y
            return corner
        })

        let block = Block(context: mainContext)
        block.board = board
        block.addToCorners(corners)
        block.forceConstant = forceConstant

        try mainContext.save()

        return block
    }
}
