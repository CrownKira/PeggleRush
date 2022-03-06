//
//  SoundArtist.swift
//  PeggleClone
//
//  Created by Kyle キラ on 27/2/22.
//

import AVFoundation

class SoundArtist {
    static let artist = SoundArtist()

    private let menuMusicFileName = "MenuMusic"
    private let designMusicFileName = "DesignMusic"
    private let gameMusicFileName = "GameMusic"
    private let winSoundFileName = "GameWinSound"
    private let loseSoundFileName = "GameOverSound"
    private let cannonSoundFileName = "CannonSound"
    private let pegSoundFileName = "PegSound"
    private let bucketSoundFileName = "BucketSound"
    private let blockSoundFileName = "BlockSound"
    private let explodeSoundFileName = "ExplodeSound"
    private let clickSoundFileName = "ClickSound"
    private let click2SoundFileName = "Click2Sound"
    private let boardSoundFileName = "BoardSound"
    private let spookySoundFileName = "SpookySound"

    private var musicPlayers = [AVAudioPlayer?]()
    private var soundPlayers = [AVAudioPlayer?]()

    var menuMusicPlayer: AVAudioPlayer?
    var designMusicPlayer: AVAudioPlayer?
    var gameMusicPlayer: AVAudioPlayer?
    var winSoundPlayer: AVAudioPlayer?
    var loseSoundPlayer: AVAudioPlayer?
    var cannonSoundPlayer: AVAudioPlayer?
    var pegSoundPlayer: AVAudioPlayer?
    var blockSoundPlayer: AVAudioPlayer?
    var bucketSoundPlayer: AVAudioPlayer?
    var explodeSoundPlayer: AVAudioPlayer?
    var clickSoundPlayer: AVAudioPlayer?
    var click2SoundPlayer: AVAudioPlayer?
    var boardSoundPlayer: AVAudioPlayer?
    var spookySoundPlayer: AVAudioPlayer?

    private init() {
        menuMusicPlayer = createAudioPlayer(fileName: menuMusicFileName)
        designMusicPlayer = createAudioPlayer(fileName: designMusicFileName)
        gameMusicPlayer = createAudioPlayer(fileName: gameMusicFileName)
        winSoundPlayer = createAudioPlayer(fileName: winSoundFileName)
        loseSoundPlayer = createAudioPlayer(fileName: loseSoundFileName)
        cannonSoundPlayer = createAudioPlayer(fileName: cannonSoundFileName)
        pegSoundPlayer = createAudioPlayer(fileName: pegSoundFileName)
        blockSoundPlayer = createAudioPlayer(fileName: blockSoundFileName)
        bucketSoundPlayer = createAudioPlayer(fileName: bucketSoundFileName)
        explodeSoundPlayer = createAudioPlayer(fileName: explodeSoundFileName)
        clickSoundPlayer = createAudioPlayer(fileName: clickSoundFileName)
        click2SoundPlayer = createAudioPlayer(fileName: click2SoundFileName)
        boardSoundPlayer = createAudioPlayer(fileName: boardSoundFileName)
        spookySoundPlayer = createAudioPlayer(fileName: spookySoundFileName)

        musicPlayers.append(contentsOf: [
            menuMusicPlayer,
            designMusicPlayer,
            gameMusicPlayer
        ])

        soundPlayers.append(contentsOf: [
            winSoundPlayer,
            loseSoundPlayer,
            cannonSoundPlayer,
            pegSoundPlayer,
            blockSoundPlayer,
            bucketSoundPlayer,
            explodeSoundPlayer,
            clickSoundPlayer,
            click2SoundPlayer,
            boardSoundPlayer
        ])

    }

    func stopAllMusicPlayers() {
        for player in musicPlayers {
            player?.stop()
        }
    }

    func stopAllSoundPlayers() {
        for player in soundPlayers {
            player?.stop()
        }
    }

    private func createAudioPlayer(fileName: String) -> AVAudioPlayer? {
        let audioPath = Bundle.main.path(forResource: fileName, ofType: "mp3")
        guard let path = audioPath else {
            return nil
        }

        do {
            let player = try AVAudioPlayer(contentsOf: NSURL(fileURLWithPath: path) as URL)
            return player
        } catch {
            return nil
        }
    }
}
