//
//  PlayViewController+Audio.swift
//  PeggleClone
//
//  Created by Kyle キラ on 27/2/22.
//

import Foundation

extension PlayViewController {
    func playBackgroundMusic() {
        let artist = SoundArtist.artist
        artist.stopAllMusicPlayers()

        if let player = artist.gameMusicPlayer {
            player.prepareToPlay()
            player.numberOfLoops = -1
            player.play()
        }
    }

    func playPegSoundEffect() {
        let artist = SoundArtist.artist

        if let player = artist.pegSoundPlayer {
            player.play()
        }
    }

    func playBlockSoundEffect() {
        let artist = SoundArtist.artist

        if let player = artist.blockSoundPlayer {
            player.play()
        }
    }

    func playBucketSoundEffect() {
        let artist = SoundArtist.artist

        if let player = artist.bucketSoundPlayer {
            player.play()
        }
    }

    func playExplodeSoundEffect() {
        let artist = SoundArtist.artist

        if let player = artist.explodeSoundPlayer {
            player.play()
        }
    }

    func playSpookySoundEffect() {
        let artist = SoundArtist.artist

        if let player = artist.spookySoundPlayer {
            player.play()
        }
    }

    func playWinSoundEffect() {
        let artist = SoundArtist.artist

        if let player = artist.winSoundPlayer {
            player.play()
        }
    }

    func playLoseSoundEffect() {
        let artist = SoundArtist.artist

        if let player = artist.loseSoundPlayer {
            player.play()
        }
    }
}
