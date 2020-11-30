//
//  KeychainUtil.swift
//  EvernymApp
//
//  Created by Volkov Alexander on 11/29/20.
//  Copyright © 2020 Volkov Alexander. All rights reserved.
//

import Foundation

class KeychainUtil {
    
    // TODO implement `vcxConfig` and `walletKey` storage
    
//    /// Store value
//    ///
//    /// - Parameters:
//    ///   - key: the key
//    ///   - value: the value
//    func store(key: String, value: String) {
//        if let secret = value.data(using: String.Encoding.utf8, allowLossyConversion: false) {
//            let query = [kSecClass: kSecClassGenericPassword,
//                         kSecAttrService: service,
//                         kSecAttrAccount: key,
//                         kSecValueData: secret] as NSDictionary
//            let status = SecItemAdd(query, nil)
//            if status != errSecSuccess {
//                print("ERROR: Keychain.store: \(status)")
//            }
//        }
//    }
//    
//    /// Update value
//    ///
//    /// - Parameters:
//    ///   - key: the key
//    ///   - value: the value
//    func update(key: String, value: String) {
//        if let secret = value.data(using: String.Encoding.utf8, allowLossyConversion: false) {
//            let query = [kSecClass: kSecClassGenericPassword,
//                         kSecAttrService: service,
//                         kSecAttrAccount: key,
//                         kSecValueData: secret] as NSDictionary
//            let status = SecItemUpdate(query, [String(kSecValueData):value, String(kSecAttrSynchronizable):kCFBooleanFalse] as CFDictionary)
//            if status != errSecSuccess {
//                print("ERROR: Keychain.update: \(status)")
//            }
//        }
//    }
//    
//    func exists(key: String, value: String) -> Bool {
//    }
}
