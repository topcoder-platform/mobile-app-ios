//
//  Configuration.swift
//  EvernymApp
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
}
