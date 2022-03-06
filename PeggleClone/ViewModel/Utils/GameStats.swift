//
//  GameStats.swift
//  PeggleClone
//
//  Created by Kyle キラ on 24/2/22.
//

import UIKit

struct GameStats {
    let orangePegsLeft: Int
    let orangePegsTotal: Int
    let ballsLeft: Int
    let ballsTotal: Int
    let scoreTotal: Int

    init() {
        self.orangePegsLeft = 0
        self.orangePegsTotal = 0
        self.ballsLeft = 0
        self.ballsTotal = 0
        self.scoreTotal = 0
    }

    init(orangePegsTotal: Int,
         ballsTotal: Int) {
        self.orangePegsLeft = orangePegsTotal
        self.orangePegsTotal = orangePegsTotal
        self.ballsLeft = ballsTotal
        self.ballsTotal = ballsTotal
        self.scoreTotal = 0
    }

    init(
        orangePegsLeft: Int,
        orangePegsTotal: Int,
        ballsLeft: Int,
        ballsTotal: Int,
        scoreTotal: Int) {
            self.orangePegsLeft = orangePegsLeft
            self.orangePegsTotal = orangePegsTotal
            self.ballsLeft = ballsLeft
            self.ballsTotal = ballsTotal
            self.scoreTotal = scoreTotal
        }
}
