//
//  UpDeckButton.swift
//  FeetsScheduler
//
//  Created by Feets on 20/02/20.
//

import Foundation

enum UpDeckButton : Int {
        // Eyes vertical
        case eyesVertUp = 1
        case eyesVertMid = 6
        case eyesVertDown = 11
        
        // Eyes horizontal
        case eyesHorizLeft = 16
        case eyesHorizMid = 17
        case eyesHorizRight = 18
        
        // Eyes, combined
        case eyesUpLeft = 3
        case eyesUpMid = 4
        case eyesUpRight = 5
        case eyesMidLeft = 8
        case eyesMidMid = 9
        case eyesMidRight = 10
        case eyesDownLeft = 13
        case eyesDownMid = 14
        case eyesDownRight = 15
        
        // Eyebrows
        case eyebrowsUp = 21
        case eyebrowsMid = 22
        case eyebrowsDown = 23
        
        // Eyes open/close
        case eyesOpen = 26
        case eyesShut = 27
        case eyesBlink = 30
        
        // Expression
        case faceNormal = 31
        case faceHappy = 32
        case faceSad = 33
        case faceHungry = 34
        
        // Feet position
        case feetLeft = 36
        case feetIn = 37
        case feetOut = 38
        case feetRight = 39
        
        // Position updater
        case eyesPosition = 20
        case eyebrowsPosition = 25
        case faceUpdate = 35
        case feetUpdate = 40
        
        // Hunger
        case hunger1 = 41
        case hunger2 = 42
        case hunger3 = 43
        case hunger4 = 44
        case hunger5 = 45
        case hunger6 = 46
        case hunger7 = 47
        case hunger8 = 48
        case hunger9 = 49
        case hunger10 = 50
        
        // Happiness
        case happiness1 = 51
        case happiness2 = 52
        case happiness3 = 53
        case happiness4 = 54
        case happiness5 = 55
        case happiness6 = 56
        case happiness7 = 57
        case happiness8 = 58
        case happiness9 = 59
        case happiness10 = 60
        
        // Rewards
        case feedChips = 81
        case feedBurger = 82
        case feedIceCream = 83
        case feedWater = 86
        case feedJuice = 87
        case feedDrinkForGrownUps = 88
        case changeToBareFeet = 96
        case changeToSocks = 97
        case changeToSlipper = 98
        
        var url: URL {
                return URL(string: "http://127.0.0.1:10314/xdeck/\(Configuration.deck)/\(self.rawValue)")!
        }
}
