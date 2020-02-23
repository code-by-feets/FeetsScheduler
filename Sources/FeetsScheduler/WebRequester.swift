//
//  WebRequester.swift
//  hadashi_irc
//
//  Created by Feets on 18/01/20.
//

import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public final class WebRequester {
        public static let standard = WebRequester()
        private init() { }
        
        public func request(_ url: URL) {
                let request = URLRequest(url: url)
                let session = URLSession.shared
                
                session.dataTask(with: request) { data, response, error in
                        print("Called \(url)")
                }.resume()
        }
}
