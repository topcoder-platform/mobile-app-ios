//
//  UserDefaultsExtensions.swift
//  EvernymApp
//
//  Created by Volkov Alexander on 12/26/20.
//  Copyright © 2020 Volkov Alexander. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    /// Keys for storing data in UserDefaults
    public struct Key {
        public static let setupCompleted = "setupCompleted"
        public static let useBiometrics = "useBiometrics"
        public static let askedApn = "askedApn"
        public static let isAuthenticated = "isAuthenticated"
    }
    
    /// true - if authenticated
    static public var isAuthenticated: Bool {
        get {
            UserDefaults.standard.bool(forKey: Key.isAuthenticated)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Key.isAuthenticated)
            UserDefaults.standard.synchronize()
        }
    }
    
    /// true - if setup completed
    static public var setupCompleted: Bool {
        get {
            UserDefaults.standard.bool(forKey: Key.setupCompleted)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Key.setupCompleted)
            UserDefaults.standard.synchronize()
        }
    }
    
    /// true - if user selected to use Biometrics
    static public var useBiometrics: Bool {
        get {
            UserDefaults.standard.bool(forKey: Key.useBiometrics)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Key.useBiometrics)
            UserDefaults.standard.synchronize()
        }
    }
    
    static public var askedApn: Bool {
        get {
            UserDefaults.standard.bool(forKey: Key.askedApn)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Key.askedApn)
            UserDefaults.standard.synchronize()
        }
    }
}
