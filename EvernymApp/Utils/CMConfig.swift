//
//  CMConfig.swift
//  EvernymApp
//
//  Created by Volkov Alexander on 11/22/20.
//  Copyright © 2020 Volkov Alexander. All rights reserved.
//

import UIKit
import SwiftyJSON

/// Utility used for configuration
class CMConfig {
    
    enum Environment: Int {
        case sandbox = 0, production = 1, staging = 2
    }
    
    static let environment: Environment = .staging
    static let walletName = "Topcoder-Dev28"
    
    static func getAgencyConfig() -> String {
        let walletKey = getWalletKey()
        let configs = [
            "1": [
                "agencyUrl": "https://agency.evernym.com",
                "agencyDid": "DwXzE7GdE5DNfsrRXJChSD",
                "agencyVerKey": "844sJfb2snyeEugKvpY7Y4jZJk9LT6BnS6bnuKoiqbip"
            ],
            "2": [
                "agencyUrl": "https://agency.pstg.evernym.com",
                "agencyDid": "LqnB96M6wBALqRZsrTTwda",
                "agencyVerKey": "BpDPZHLbJFu67sWujecoreojiWZbi2dgf4xnYemUzFvB"
            ]
        ]
        
        let index = environment.rawValue.description
        let agencyUrl = configs[index]?["agencyUrl"] ?? ""
        let agencyDid = configs[index]?["agencyDid"] ?? ""
        let agencyVerKey = configs[index]?["agencyVerKey"] ?? ""
        return
"""
        {
        "agency_url": "\(agencyUrl)",
        "agency_did": "\(agencyDid)",
        "agency_verkey": "\(agencyVerKey)",
        "wallet_name": "\(walletName)",
        "wallet_key": "\(walletKey)"
        }
"""
    }
    
    static func getWalletKey() -> String {
        var walletKey=""
        var keyData = Data(count: 128)
        let result = keyData.withUnsafeMutableBytes {
            SecRandomCopyBytes(kSecRandomDefault, 32, $0.baseAddress!)
        }
        if result == errSecSuccess {
            walletKey = keyData.base64EncodedString()
            print("Wallet key generated successfully")
        } else {
            print("Problem generating random bytes")
        }
        return walletKey
    }
    
    // MARK: - Genesis file for server node
    
    static func genesisFileName(environment: Environment) -> String {
        switch environment {
        case .sandbox:
            return "pool_transactions_genesis_DEMO"
        case .staging:
            return "pool_transactions_genesis_STAG"
        default:
            return "pool_transactions_genesis_PROD"
        }
    }
    
    static func genesisFile(environment: Environment) -> String {
        switch environment {
        case .staging:
            return stagingPoolTxnGenesisDef
        // Default is Production genesis file:
        default:
            return productionPoolTxnGenesisDef
        }
    }
    
    static func genesisFilePath() -> String {
        var documentsDirectory: String!
        let paths: [AnyObject] = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true) as [AnyObject];
        if paths.count > 0 {
            if let pathString = paths[0] as? NSString {
                documentsDirectory = pathString as String
            }
        }
        
        let filePath = "\(documentsDirectory!)/\(CMConfig.genesisFileName(environment: environment))"
        
        if !FileManager.default.fileExists(atPath: filePath) {
            let fileData = CMConfig.genesisFile(environment: environment).data(using: .utf8)!
            let success = FileManager.default.createFile(atPath: filePath, contents: fileData, attributes: nil)
            if !success {
                print("error while creating pool transaction genesis file")
                return ""
            }
        }

        print("Creating pool transaction genesis file was successful: \(filePath)")
        return filePath
    }
    
    // MARK: - JSON config helper methods
    
    static func updateJSONConfig(jsonConfig: String, withValues values: [String: String]) -> String {
        var jsonConfig = try! JSON(data: jsonConfig.data(using: .utf8)!)
        for (k,v) in values {
            jsonConfig[k].string = v
        }
        return jsonConfig.rawString() ?? ""
    }
    
    // MARK: - VCX Init
        static func initialize() {
            guard let sdkApi = (UIApplication.shared.delegate as? AppDelegate)?.sdkApi else { print("ERROR: no sdkAPI"); return }
        
    // TODO no such method    [sdkApi initSovToken];
        
            let agencyConfig = getAgencyConfig()
            print("Agency config \(agencyConfig)")
        
            sdkApi.agentProvisionAsync(agencyConfig) { (error, oneTimeInfo) in
                guard !printError(error) else { return }
                
                let keychainVcxConfig: NSMutableDictionary = [kSecClass: kSecClassGenericPassword,
                             kSecAttrAccessible: kSecAttrAccessibleWhenUnlocked,
                             kSecAttrType: "vcxConfig",
                             kSecAttrLabel: walletName
                    ]
                let config = CMConfig.vsxConfig(oneTimeInfo: oneTimeInfo, withKeychainConfig: keychainVcxConfig)
                
                sdkApi.initWithConfig(config) { (error) in
                    guard !printError(error) else { return }
                    
                    (UIApplication.shared.delegate as? AppDelegate)?.sdkInited = true
                    print("######## VCX Config Successful! :) #########")
                }
            }
        }
    
    static func vsxConfig(oneTimeInfo: String?, withKeychainConfig keychainVcxConfig: NSMutableDictionary) -> String? {
        var vcxConfig: String!
        if let oneTimeInfo = oneTimeInfo {
            vcxConfig = updateJSONConfig(jsonConfig: oneTimeInfo, withValues: [
                "genesis_path": genesisFilePath(),
                "institution_logo_url": "https://robothash.com/logo.png",
                "institution_name": "real institution name",
                "pool_name": "7e96cbb3b0a1711f3b843af3cb28e31dcmpool",
                "protocol_version": "2"
            ])
            if SecItemCopyMatching(keychainVcxConfig as CFDictionary, nil) == noErr {
                //We can update the keychain item.
                let attributesToUpdate = NSMutableDictionary()
                attributesToUpdate[kSecValueData] = vcxConfig.data(using: .utf8)!
                let sts: OSStatus = SecItemUpdate(keychainVcxConfig, attributesToUpdate);
                if sts != errSecSuccess {
                    print("Error Code while updating vcxConfig: \(sts)")
                }
                else {
                    print("Success: updating vcxConfig")
                }
            }
            else {
                keychainVcxConfig[kSecValueData] = vcxConfig.data(using: .utf8)!
                let sts: OSStatus = SecItemAdd(keychainVcxConfig, nil);
                if sts != errSecSuccess {
                    print("Error Code while adding new vcxConfig: \(sts)")
                }
                else {
                    print("Success: adding new vcxConfig")
                }
                
            }
            return vcxConfig
        }
        else {
            // Get vcxConfig from secure keychain storage: https://www.andyibanez.com/using-ios-keychain/
            keychainVcxConfig[kSecReturnData] = kCFBooleanTrue;
            keychainVcxConfig[kSecReturnAttributes] = kCFBooleanTrue;
            var result: CFTypeRef!
            let status = SecItemCopyMatching(keychainVcxConfig as CFDictionary, &result)
            if status == noErr {
                let resultDict: NSDictionary = result as! NSDictionary
                let vcxConfigData = resultDict[kSecValueData] as! Data
                vcxConfig = String(data: vcxConfigData, encoding: .utf8)
            } else {
                print("Error Code while finding vcxConfig: \(status)")
            }
            return vcxConfig
        }
    }
    
    /// Prints error if presented
    /// - Parameter error: the error
    /// - Returns: true - if error found
    static func printError(_ error: Error?) -> Bool {
        if error != nil && (error as NSError?)?.code != 0 { print("ERROR: \(String(describing: error))"); return true }
        return false
    }
}