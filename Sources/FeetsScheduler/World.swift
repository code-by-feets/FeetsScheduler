//
//  World.swift
//  FeetsScheduler
//
//  Created by Feets on 20/02/20.
//

import Foundation

struct World {
        // Weather
        var weather = Weather()
        
        // Stream condition
        var state = State.normal
        
        struct Weather {
                // Conditions
                var conditions: [Condition] = []
                
                mutating func updateConditions() {
                        if !self.conditions.isEmpty {
                                self.conditions.removeFirst(1)
                        }
                        
                        while self.conditions.count < 3 {
                                if let condition = Condition.allCases.randomElement() {
                                        self.conditions.append(condition)
                                }
                        }
                }
                
                // Init
                init() {
                        updateConditions()
                        print(self.conditions)
                }
                
                enum Condition : Double, CaseIterable {
                        case cold = 1
                        case fine = 20
                        case hot = 70
                }
        }
        
        enum State {
                case normal
                case blurry
                case flooded
                case smashed
                case upsideDown
        }
}

extension World {
        static func updateWeather(onWorld world: World) -> World {
                var newWorld = world
                newWorld.weather.updateConditions()
                return newWorld
        }
}
