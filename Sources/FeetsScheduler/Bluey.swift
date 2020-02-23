//
//  Bluey.swift
//  FeetsScheduler
//
//  Created by Feets on 20/02/20.
//

import Foundation

struct Bluey {
        var world: World?
        
        // Graphics
        var faceState = FaceState.normal
        var feetState = FeetState.bareFeet
        
        var previousFaceState: FaceState?
        var previousFeetState: FeetState?
        
        // Stats
        var hunger = 5.0
        var happiness = 10.0
        
        // Temperature
        var lastDrink: Drink?
        var temperature: Double {
                self.feetState.temperature + (self.lastDrink?.temperature ?? 2)
        }
        
        // Depletion rate
        var hungerDepletionRate: Double {
                0.1 * (world?.weather.conditions.first?.rawValue ?? 20) / 10
        }
        var happinessDepletionRate: Double {
                let base = (10 - self.hunger) * 0.1
                let temperature: Double = self.temperature * (world?.weather.conditions.first?.rawValue ?? 20.0)
                let temperaturePenalty: Double = {
                        // Cold
                        if temperature <= 6 {
                                if temperature <= 2 { return 3 }
                                else if temperature > 2, temperature <= 4 { return 2 }
                                else { return 1 }
                        } else if temperature >= 140 {
                                if temperature >= 420 { return 3 }
                                else if temperature < 420, temperature >= 280 { return 2 }
                                else { return 1 }
                        } else {
                                return 1
                        }
                }()
                return (base * temperaturePenalty / 4)
        }
        
        // Modifiers
        var hungerMultiplier = 1
        var happinessMultiplier = 1
        var hungerDepletionBlocked = false
        var happinessDepletionBlocked = false
        
        enum FaceState {
                case normal
                case happy
                case sad
                case hungry
                
                var button: UpDeckButton {
                        switch self {
                        case .normal:
                                return UpDeckButton.faceNormal
                        case .happy:
                                return UpDeckButton.faceHappy
                        case .sad:
                                return UpDeckButton.faceSad
                        case .hungry:
                                return UpDeckButton.faceHungry
                        }
                }
        }
        
        enum FeetState : Int {
                case bareFeet = 1
                case socks = 2
                case slippers = 3
                
                var temperature: Double {
                        switch self {
                        case .bareFeet: return 1
                        case .socks: return 2
                        case .slippers: return 3
                        }
                }
        }
        
        enum Drink {
                case chilledWater
                case juice
                case grownUpDrink
                
                var temperature: Double {
                        switch self {
                        case .chilledWater: return 1
                        case .juice: return 2
                        case .grownUpDrink: return 3
                        }
                }
        }
}

extension Bluey {
        static func blink() {
                WebRequester.standard.request(UpDeckButton.eyesBlink.url)
        }

        static func moveEyes() {
                if let direction = [UpDeckButton.eyesUpLeft, UpDeckButton.eyesUpMid, UpDeckButton.eyesUpRight, UpDeckButton.eyesMidLeft, UpDeckButton.eyesMidMid, UpDeckButton.eyesMidRight, UpDeckButton.eyesDownLeft, UpDeckButton.eyesDownMid, UpDeckButton.eyesDownRight].randomElement() {
                        WebRequester.standard.request(direction.url)
                        print("Updated eyes: direction = \(direction)")
                }
        }

        static func moveFeet() {
                if let direction = [UpDeckButton.feetLeft, UpDeckButton.feetIn, UpDeckButton.feetOut, UpDeckButton.feetRight].randomElement() {
                        WebRequester.standard.request(direction.url)
                        print("Updated feet: direction = \(direction)")
                }
        }
        
        func updateHunger() {
                let ceilHunger = bluey.hunger.rounded(.up)
                if let button = UpDeckButton(rawValue: 40 + Int(ceilHunger)) {
                        WebRequester.standard.request(button.url)
                }
        }
        
        func updateHappiness() {
                let ceilHappiness = bluey.happiness.rounded(.up)
                if let button = UpDeckButton(rawValue: 50 + Int(ceilHappiness)) {
                        WebRequester.standard.request(button.url)
                }
        }
        
        static func updateFace(onBluey bluey: Bluey) -> Bluey {
                var newBluey = bluey
                newBluey.faceState = {
                        var faceState = FaceState.normal
                        
                        if bluey.hunger < 3 { faceState = FaceState.hungry }
                        
                        if bluey.happiness < 3 { faceState = FaceState.sad }
                        else if bluey.happiness > 7 { faceState = FaceState.happy }
                        
                        return faceState
                }()
                
                if newBluey.previousFaceState != newBluey.faceState {
                        newBluey.previousFaceState = newBluey.faceState
                        WebRequester.standard.request(newBluey.faceState.button.url)
                        return newBluey
                } else {
                        return bluey
                }
        }
        
        static func updateStats(onBluey bluey: Bluey) -> Bluey {
                var newBluey = bluey
                
                newBluey.hunger = bluey.hunger - (!bluey.hungerDepletionBlocked ? bluey.hungerDepletionRate : 0.0)
                newBluey.happiness = bluey.happiness - (!bluey.happinessDepletionBlocked ? bluey.happinessDepletionRate : 0.0)
                
                if newBluey.hunger > 10 { newBluey.hunger = 10 }; if newBluey.hunger <= 0 { newBluey.hunger = 0.1 }
                if newBluey.happiness > 10 { newBluey.happiness = 10 }; if newBluey.happiness <= 0 { newBluey.happiness = 0.1 }
                
                print("Satiety: \(newBluey.hunger) • Happiness: \(newBluey.happiness)")
                
                return newBluey
        }
}
