//
//  CMConfig+Wallet.swift
//  EvernymApp
//
//  Created by Volkov Alexander on 1/30/21.
//  Copyright © 2021 Volkov Alexander. All rights reserved.
//

import Foundation
import MobileWallet

let kWalletName = "walletName"
let kWalletKey = "walletKey"

extension CMConfig {
    
    /// Setup custom wallet name/key. Once `.initialize()` (or `.getAgencyConfig()`,  or `.getWalletKey()`) is called, the key will be stored in the keychain (internally), but not wallet name.
    /// - Parameters:
    ///   - walletName: the name
    ///   - walletKey: the key
    func setup(walletName: String, walletKey: String) {
        self.walletName = walletName
        self.walletKey = walletKey
        
        // Save in the keychain
        self.keychain[kWalletName] = walletName
        self.keychain[kWalletKey] = walletKey
    }
    
    /// Setup wallet. Generates wallet name/key if needed, and setup it in this utility.
    /// - Parameter force: true - will regenerate the wallet, false - will try to reuse previously generated wallet.
    func setupWallet(force: Bool = false) {
        if let name = self.keychain[kWalletName],
            let key = self.keychain[kWalletKey], !force {
            self.walletName = name
            self.walletKey = key
        }
        else {
            // Generate wallet name and key and save for future
            let name = "Topcoder-Dev-" + UUID().uuidString
            print("Wallet name generated: \(name)")
            do {
                self.walletName = name
                let key = self.getWalletKey() // depend on previous line
            // }
                setup(walletName: name, walletKey: key)
            }
        }
    }
}
