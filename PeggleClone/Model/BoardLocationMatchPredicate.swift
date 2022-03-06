//
//  BoardLocationMatchPredicate.swift
//  PeggleClone
//
//  Created by Kyle キラ on 30/1/22.
//

import UIKit

class BoardLocationMatchPredicate: NSCompoundPredicate {

    convenience init(board: Board, location: CGPoint) {

        var predicates = [NSPredicate]()
        predicates.append(NSPredicate(format: "board == %@", board))
        predicates.append(NSPredicate(format: "x == %lf", location.x))
        predicates.append(NSPredicate(format: "y == %lf", location.y))

        self.init(type: .and, subpredicates: predicates)
    }

    override init(type: NSCompoundPredicate.LogicalType, subpredicates: [NSPredicate]) {
        super.init(type: type, subpredicates: subpredicates)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
