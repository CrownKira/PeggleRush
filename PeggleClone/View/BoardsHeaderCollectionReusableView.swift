//
//  BoardsHeaderCollectionReusableView.swift
//  PeggleClone
//
//  Created by Kyle キラ on 22/2/22.
//

import UIKit

class BoardsHeaderCollectionReusableView: UICollectionReusableView {
    @IBOutlet private var categoryTitleLabel: UILabel!

    var categoryTitle: String = "" {
        didSet {
            categoryTitleLabel.text = categoryTitle
        }
    }
}
