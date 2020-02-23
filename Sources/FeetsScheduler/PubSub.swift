//
//  PubSub.swift
//  hadashi_irc
//
//  Created by Feets on 11/02/20.
//

import Foundation

public protocol JSONCodable : Codable {
        func jsonData() -> Data?
}

extension JSONCodable {
        public func jsonData() -> Data? {
                return try? JSONEncoder().encode(self)
        }
        
        public func jsonString() -> String? {
                if let data = self.jsonData() {
                        return String(data: data, encoding: .utf8)
                } else { return nil }
        }
}

public struct PSSimpleMessage : JSONCodable {
        let type: String
}

public struct PSListen : JSONCodable {
        public let type: String
        public let nonce: String
        public let data: PSListenData
        
        public struct PSListenData : Codable {
                public let topics: [String]
                public let authToken: String
                
                enum CodingKeys: String, CodingKey {
                        case topics
                        case authToken = "auth_token"
                }
        }
        
        public init(data: PSListenData) {
                self.type = "LISTEN"
                self.nonce = {
                        let possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
                        return (1...18).reduce("") { result, _ in
                                return "\(result)\(possible.randomElement()!)"
                        }
                }()
                self.data = data
        }
}

public struct PSResponse : JSONCodable {
        public let type: String
        public let nonce: String?
        public let error: String
}

public struct PSMessage : JSONCodable {
        public let type: String
        public let data: PSMessageData
        
        public struct PSMessageData : Codable {
                public let topic: String
                public let message: String
        }
}

public struct PSRedemptionMessage : JSONCodable {
        public let type: String
        public let data: PSRedemptionMessageData
        
        public struct PSRedemptionMessageData : Codable {
                public let timestamp: String
                public let redemption: Redemption
                
                public struct Redemption : Codable {
                        public let id: String
                        public let user: RedemptionUser
                        public let channelID: String
                        public let redemptionDate: String
                        public let reward: Reward
                        public let userInput: String?
                        public let status: String
                        
                        public struct RedemptionUser : Codable {
                                public let id: String
                                public let login: String
                                public let displayName: String
                                
                                enum CodingKeys: String, CodingKey {
                                        case id
                                        case login
                                        case displayName = "display_name"
                                }
                        }
                        
                        public struct Reward : Codable {
                                public let id: String
                                public let channelID: String
                                public let title: String
                                public let prompt: String
                                public let cost: Int
                                public let userInputRequired: Bool
                                public let subOnly: Bool
                                public let image: ImageContainer?
                                public let defaultImage: ImageContainer
                                public let backgroundColor: String
                                public let enabled: Bool
                                public let paused: Bool
                                public let inStock: Bool
                                public let limit: RedemptionLimit
                                public let skipRequestQueue: Bool
                                
                                public struct ImageContainer : Codable {
                                        let image1URL: String
                                        let image2URL: String
                                        let image4URL: String
                                        
                                        enum CodingKeys: String, CodingKey {
                                                case image1URL = "url_1x"
                                                case image2URL = "url_2x"
                                                case image4URL = "url_4x"
                                        }
                                }
                                
                                public struct RedemptionLimit : Codable {
                                        let enabled: Bool
                                        let maximumPerStream: Int
                                        
                                        enum CodingKeys: String, CodingKey {
                                                case enabled = "is_enabled"
                                                case maximumPerStream = "max_per_stream"
                                        }
                                }
                                
                                enum CodingKeys: String, CodingKey {
                                        case id
                                        case channelID = "channel_id"
                                        case title
                                        case prompt
                                        case cost
                                        case userInputRequired = "is_user_input_required"
                                        case subOnly = "is_sub_only"
                                        case image
                                        case defaultImage = "default_image"
                                        case backgroundColor = "background_color"
                                        case enabled = "is_enabled"
                                        case paused = "is_paused"
                                        case inStock = "is_in_stock"
                                        case limit = "max_per_stream"
                                        case skipRequestQueue = "should_redemptions_skip_request_queue"
                                }
                        }
                        
                        enum CodingKeys: String, CodingKey {
                                case id
                                case user
                                case channelID = "channel_id"
                                case redemptionDate = "redeemed_at"
                                case reward
                                case userInput = "user_input"
                                case status
                        }
                }
        }
}
