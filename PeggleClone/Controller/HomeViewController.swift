//
//  HomeViewController.swift
//  PeggleClone
//
//  Created by Kyle キラ on 21/2/22.
//

import UIKit

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        playBackgroundMusic()
    }

    @IBAction private func designLevelButtonPressed(_ sender: UIButton) {
        playClickSoundEffect()
    }

    @IBAction private func selectLevelButtonPressed(_ sender: UIButton) {
        playClickSound2Effect()
    }
}

extension HomeViewController {
    private func playBackgroundMusic() {
        let artist = SoundArtist.artist
        artist.stopAllMusicPlayers()

        if let player = artist.menuMusicPlayer {
            player.prepareToPlay()
            player.numberOfLoops = -1
            player.play()
        }
    }

    private func playClickSoundEffect() {
        if let player = SoundArtist.artist.clickSoundPlayer {
            player.play()
        }
    }

    private func playClickSound2Effect() {
        if let player = SoundArtist.artist.click2SoundPlayer {
            player.play()
        }
    }
}
