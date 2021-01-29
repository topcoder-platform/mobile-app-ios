//
//  Keychain.swift
//  MobileWalletExample
//
//  Created by Volkov Alexander on 1/29/21.
//  Copyright © 2021 Topcoder. All rights reserved.
//

import Foundation
import Security

/// Simple Keychain utility
open class Keychain {
    
    public enum KeychainError: Error {
        case noPassword
        case unexpectedData
        case other(status: OSStatus)
    }
    
    /// the service anme
    private let service: String
    
    /// the callback used to provide additional configuration for the queries used to add/update/get/delete the values to/from the kaychain
    public var queryConfiguration: ((NSDictionary)->(NSDictionary))?
    
    /// Initializer with service. Used to initialize Keychain for `kSecClassGenericPassword` class.
    public init(service: String) {
        self.service = service
    }
    
    /// Initializer for classes other than `kSecClassGenericPassword`
    public convenience init() {
        self.init(service: "General")
    }
    
    /// subscript
    ///
    /// - Parameter key: the key
    public subscript(key: String) -> String? {
        get {
            return getGenericPassword(key)
        }
        set {
            if let value = newValue {
                setGenericPassword(value, key: key)
            } else {
                removeGenericPassword(key)
            }
        }
    }
    
    // MARK: - kSecClassGenericPassword
    
    /// Set value
    ///
    /// - Parameters:
    ///   - value: the value
    ///   - key: the key
    public func setGenericPassword(_ value: String, key: String) {
        if let _ = getGenericPassword(key) {
            updateGenericPassword(key: key, value: value)
        }
        else {
            addGenericPassword(key: key, value: value)
        }
    }
    
    /// Remove value for given key
    ///
    /// - Parameter key: the key
    public func removeGenericPassword(_ key: String) {
        var query = [kSecClass: kSecClassGenericPassword,
                     kSecAttrService: service,
                     kSecAttrAccount: key] as NSDictionary
        if let queryConfiguration = queryConfiguration {
            query = queryConfiguration(query)
        }
        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess && status != errSecItemNotFound {
            print("ERROR: Keychain.remove: \(status)")
        }
    }
    
    /// Store value
    ///
    /// - Parameters:
    ///   - key: the key
    ///   - value: the value
    public func addGenericPassword(key: String, value: String) {
        if let secret = value.data(using: String.Encoding.utf8, allowLossyConversion: false) {
            var query = [kSecClass: kSecClassGenericPassword,
                         kSecAttrService: service,
                         kSecAttrAccount: key,
                         kSecValueData: secret] as NSDictionary
            if let queryConfiguration = queryConfiguration {
                query = queryConfiguration(query)
            }
            let status = SecItemAdd(query, nil)
            if status != errSecSuccess {
                print("ERROR: Keychain.store: \(status)")
            }
        }
    }
    
    /// Update value
    ///
    /// - Parameters:
    ///   - key: the key
    ///   - value: the value
    public func updateGenericPassword(key: String, value: String) {
        if let secret = value.data(using: String.Encoding.utf8, allowLossyConversion: false) {
            var query = [kSecClass: kSecClassGenericPassword,
                         kSecAttrService: service,
                         kSecAttrAccount: key] as NSDictionary
            if let queryConfiguration = queryConfiguration {
                query = queryConfiguration(query)
            }
            let status = SecItemUpdate(query, [kSecValueData: secret, kSecAttrSynchronizable: kCFBooleanFalse!] as CFDictionary)
            if status != errSecSuccess {
                print("ERROR: Keychain.update: \(status)")
            }
        }
    }
    
    /// Get value
    ///
    /// - Parameters:
    ///   - key: the key
    private func getGenericPassword(_ key: String) -> String? {
        var query = [kSecClass: kSecClassGenericPassword,
                     kSecAttrService: service,
                     kSecAttrAccount: key,
                     kSecReturnData: true] as NSDictionary
        if let queryConfiguration = queryConfiguration {
            query = queryConfiguration(query)
        }
        var data: CFTypeRef? = nil
        let status = SecItemCopyMatching(query, &data)
        if status != errSecSuccess && status != errSecItemNotFound {
            print("ERROR: Keychain.get: \(status)")
        }
        
        if let data = data as? Data,
            let value = String(bytes: data, encoding: .utf8), status == errSecSuccess {
            return value
        }
        return nil
    }
    
    /// Check if value exists in the keychain for given key
    ///
    /// - Parameters:
    ///   - key: the key
    public func existsGenericPassword(_ key: String) -> Bool {
        var query = [kSecClass: kSecClassGenericPassword,
                     kSecAttrService: service,
                     kSecAttrAccount: key] as NSDictionary
        if let queryConfiguration = queryConfiguration {
            query = queryConfiguration(query)
        }
        let status = SecItemCopyMatching(query, nil)
        return status != noErr
    }
}
