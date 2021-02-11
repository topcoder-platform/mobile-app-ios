//
//  AuthenticaionUtil.swift
//  EvernymApp
//
//  Created by Volkov Alexander on 1/31/21.
//  Copyright © 2021 Volkov Alexander. All rights reserved.
//

import Foundation
import Keychain83
import Auth0
import SwiftEx83
import SwiftyJSON

/// Utility that helps handle authentication and store credentials (will be in future; current just stores the differences between the user roles)
class AuthenticationUtil {
    
    static var keychain = Keychain(service: "EvernumApp")
    
    static func isAuthenticated() -> Bool {
        return UserDefaults.isAuthenticated && credentialsManager.hasValid()
    }
    
    // Create an instance of the credentials manager for storing credentials
    static let credentialsManager = CredentialsManager(authentication: Auth0.authentication())
    
    // save tokens
    static func processCredentials(credentials: Credentials) {
        credentialsManager.store(credentials: credentials)
        keychain["credentials"] = credentials.toString()
        UserDefaults.isAuthenticated = true
    }
    
    /// Clean credentials
    static func cleanUp() {
        keychain["credentials"] = nil
        UserDefaults.isAuthenticated = false
    }
}

extension Credentials {
    
    /// Converts to JSON string
    func toString() -> String {
        var dic: [String: Any] = [:]
        if let v = self.accessToken { dic["accessToken"] = v }
        if let v = self.tokenType { dic["tokenType"] = v }
        if let v = self.refreshToken { dic["refreshToken"] = v }
        if let v = self.expiresIn { dic["expiresIn"] = Date.isoFormatter.string(from: v) }
        if let v = self.idToken { dic["idToken"] = v }
        if let v = self.scope { dic["scope"] = v }
        let json = JSON(dic)
        return json.rawString() ?? "{}"
    }
    
    /// Parse JSON string
    static func from(string: String) -> Credentials {
        let json = JSON(parseJSON: string)
        let accessToken = json["accessToken"].string
        let tokenType = json["tokenType"].string
        let refreshToken = json["refreshToken"].string
        let expiresIn = Date.isoFormatter.date(from: json["expiresIn"].stringValue)
        let idToken = json["idToken"].string
        let scope = json["scope"].string
        return Credentials(accessToken: accessToken, tokenType: tokenType, idToken: idToken, refreshToken: refreshToken, expiresIn: expiresIn, scope: scope)
    }
}
