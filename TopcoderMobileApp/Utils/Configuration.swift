//
//  Configuration.swift
// TopcoderMobileApp
//
//  Created by Volkov Alexander on 12/11/20.
//  Copyright © 2020 Volkov Alexander. All rights reserved.
//

import Foundation

/// App configuration from `configuration.plist`
class Configuration {
    
    /// `configuration_<ENV>.plist` content. ENV is set in Info.plist
    var dict = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "configuration", ofType: "plist")!)
    
    /// singleton
    static let shared = Configuration()
    
    static var appCenterSecret: String {
        return shared.dict!["APP_CENTER_SECRET"] as! String
    }
    
    /// URL used to open challenges list
    static var urlChallenges: String {
        return shared.dict!["URL_CHALLENGES"] as! String
    }
    
    /// URL used to open login form in embeded web view
    static var urlLogin: String {
        return shared.dict!["URL_LOGIN"] as! String
    }
    
    /// the endpoint for APN token
    static var apnEndpoint: String {
        return shared.dict!["APN_ENDPOINT"] as! String
    }
}
