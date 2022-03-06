//
//  BoardCollectionViewCell.swift
//  PeggleClone
//
//  Created by Kyle キラ on 22/1/22.
//

import UIKit

class BoardCollectionViewCell: UICollectionViewCell {

    @IBOutlet private var boardImageView: UIImageView!
    @IBOutlet private var boardLabel: UILabel!

    var boardViewModel = BoardViewModel(board: nil) {
        didSet {
            if let boardImage = boardViewModel.imageView {
                boardImageView.image = boardImage
            } else {
                boardImageView.image = BoardViewModel.backgroundImage
            }

            boardLabel.text = boardViewModel.name.value
        }
    }

}
