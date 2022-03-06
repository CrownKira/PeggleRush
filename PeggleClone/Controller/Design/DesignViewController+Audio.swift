//
//  DesignViewController+Audio.swift
//  PeggleClone
//
//  Created by Kyle キラ on 27/2/22.
//

import UIKit

extension DesignViewController {
    func playBackgroundMusic() {
        let artist = SoundArtist.artist
        artist.stopAllMusicPlayers()

        if let player = artist.designMusicPlayer {
            player.prepareToPlay()
            player.numberOfLoops = -1
            player.play()
        }
    }

    func playBoardSoundEffect() {
        let artist = SoundArtist.artist

        if let player = artist.boardSoundPlayer {
            player.play()
        }
    }
}
