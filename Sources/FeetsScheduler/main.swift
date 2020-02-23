import Foundation
import NIO
import WebSocketKit

// Declare

var bluey = Bluey()
var world = World()
bluey.world = world

// WebSocket

var client: WebSocket?
let loopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 1)

func processMessage(_ data: PSRedemptionMessage.PSRedemptionMessageData) {
        var tmpButton: UpDeckButton?
        var tmpOffset: Int? {
                switch data.redemption.reward.title.first! {
                case "🍎":
                        return 80
                case "🥤":
                        return 85
                case "🍽":
                        return 90
                case "🧦":
                        return 95
                default:
                        return nil
                }
        }
        
        guard let offset = tmpOffset else { return }
        
        if let input = data.redemption.userInput, let number = Int(input) ,let state = Bluey.FeetState(rawValue: number), bluey.feetState != state, let button = UpDeckButton(rawValue: number + offset) {
                tmpButton = button
        }
        
        if let button = tmpButton {
                WebRequester.standard.request(button.url)
        }
}

func decode(string: String?, data: Data?) {
        let decoder = JSONDecoder()
        let data = string != nil ? string!.data(using: .utf8)! : data!
        if let message = try? decoder.decode(PSMessage.self, from: data) {
                print("Message: \(message.data.topic) - \(message.data.message)")
                do {
                        let redemptionMessage = try decoder.decode(PSRedemptionMessage.self, from: message.data.message.data(using: .utf8)!)
                        print("Redemption")
                        processMessage(redemptionMessage.data)
                } catch {
                        print("JSON error: \(error)")
                }
        } else if let response = try? decoder.decode(PSResponse.self, from: data) {
                print("Response")
                if !response.error.isEmpty { print("WebSocket response error: \(response.error)") }
        } else if let simpleMessage = try? decoder.decode(PSSimpleMessage.self, from: data) {
                print("Simple: \(simpleMessage)")
                switch simpleMessage.type {
                case "RECONNECT":
                        exit(0)
                default:
                        print("<- WebSocket: \(simpleMessage.type)")
                }
        } else {
                print("Received … something?")
        }
}

var timerCounts = [
        "weather": 0,
        "blink": 0,
        "eyes": 0,
        "feet": 0,
        "mood": 0,
        "hunger_bar": 0,
        "happiness_bar": 0,
        "face": 0
]

var timerFunctions = [
        "blink": Bluey.blink,
        "eyes": Bluey.moveEyes,
        "feet": Bluey.moveFeet,
        "hunger_bar": bluey.updateHunger,
        "happiness_bar": bluey.updateHappiness
]

var blueyUpdatingFunctions = [
        "mood": Bluey.updateStats,
        "face": Bluey.updateFace,
]

var worldUpdatingFunctions = [
        "weather": World.updateWeather
]

let timerFireCounts = [
        "blink": 5,
        "eyes": 10,
        "feet": 3,
        "hunger_bar": 1,
        "happiness_bar": 1,
        "mood": 60,
        "face": 1,
        "weather": 300
]

let _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
        timerCounts.keys.forEach { key in
                let value = timerCounts[key]!
                timerCounts[key] = value + 1
                
                if timerCounts[key] == timerFireCounts[key] {
                        timerCounts[key] = 0
                        if let function = timerFunctions[key] { function() }
                        else if let function = blueyUpdatingFunctions[key] {
                                bluey = function(bluey)
                                bluey.world = world
                        }
                        else if let function = worldUpdatingFunctions[key] { world = function(world) }
                }
        }
}

loopGroup.next().execute {
        print("Connecting…")
        
        let future = WebSocket.connect(to: Configuration.pubSubURL, on: loopGroup, onUpgrade: { webSocket in
                print("Connected")
                client = webSocket
                
                guard let client = client else { return }
                
                loopGroup.next().scheduleRepeatedTask(initialDelay: .seconds(0), delay: .seconds(10)) { task in
                        client.send(PSSimpleMessage(type: "PING").jsonString()!)
                        print("Ping")
                }
                
                print("Sending listen message…")
                guard let listenMessage = PSListen(data: PSListen.PSListenData(topics: Configuration.topics, authToken: Configuration.authToken)).jsonString() else { exit(0) }
                client.send(listenMessage)
                print("Sent listen message")
                
                client.onText { ws, string in
                        decode(string: string, data: nil)
                }
                
                client.onBinary { ws, buf in
                        var buffer = buf
                        guard let data = buffer.readData(length: buf.readableBytes) else { return }
                        decode(string: nil, data: data)
                }
        })
        
        future.whenFailure { error in
                print("Future error: \(error)")
                loopGroup.shutdownGracefully { _ in
                        print("Shutting down")
                }
        }
}

RunLoop.current.run()

