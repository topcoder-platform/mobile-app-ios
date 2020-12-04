//
//  CMConfig.swift
//  EvernymApp
//
//  Created by Volkov Alexander on 11/22/20.
//  Copyright © 2020 Volkov Alexander. All rights reserved.
//

import UIKit
import SwiftyJSON
import Keychain83
import SwiftEx83
import vcx

enum SdkEvent: String {
    case ready
}

/// Utility used for configuration
class CMConfig {
    
    enum Environment: Int {
        case sandbox = 0, production = 1, staging = 2
    }
    
    static let environment: Environment = .staging
    static let walletName = "Topcoder-Dev"
    
    // Keychain utility used to store `walletKey` and `vcxConfig`
    static var keychain: Keychain = {
        let util = Keychain(service: "Evernym")
        util.queryConfiguration = { query in
            let query = NSMutableDictionary(dictionary: query)
            query[kSecAttrAccessible] = kSecAttrAccessibleWhenUnlocked
            return query
        }
        return util
    }()
    
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
// This was removed from config (ObjC example)
//        "agent_seed": null,
//        "enterprise_seed": null,
//        "protocol_type": "3.0"
    }
    
    /// Get wallet key from the keychain or generate if it's missing.
    /// - Returns: the wallet key
    static func getWalletKey() -> String {
        let key = "walletKey-" + walletName
        
        // Check if stored in a keychain
        if let walletKey = keychain[key] {
            return walletKey
        }
        else { // Generate wallet key
            var keyData = Data(count: 128)
            let result = keyData.withUnsafeMutableBytes {
                SecRandomCopyBytes(kSecRandomDefault, 32, $0.baseAddress!)
            }
            var generatedKey = ""
            if result == errSecSuccess {
                generatedKey = keyData.base64EncodedString()
                print("Wallet key generated successfully")
                
                // Store in a keychain
                keychain[key] = generatedKey
            } else {
                print("Problem generating random bytes")
            }
            return generatedKey
        }
    }
    
    // MARK: - Genesis file for server node
    
    static func genesisFileName(environment: Environment) -> String {
        switch environment {
        case .sandbox:
            return "pool_transactions_genesis_DEMO_2"
        case .staging:
            return "pool_transactions_genesis_STAG_2"
        default:
            return "pool_transactions_genesis_PROD_2"
        }
    }
    
    static func genesisFile(environment: Environment) -> String {
        switch environment {
        case .staging:
            return stagingPoolTxnGenesisDef2
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
    
    static func updateJSONConfig(jsonConfig: String, withValues values: [String: Any]) -> String {
        var jsonConfig = try! JSON(data: jsonConfig.data(using: .utf8)!)
        for (k,v) in values {
            jsonConfig[k] = (v is String) ? JSON(v) : (v as! JSON)
        }
        return jsonConfig.rawString() ?? ""
    }
    
    // MARK: - VCX Init
    static func initialize() {
        guard let sdkApi = (UIApplication.shared.delegate as? AppDelegate)?.sdkApi else { print("ERROR: no sdkAPI"); return }
    
// TODO no such method    [sdkApi initSovToken];
    
        let agencyConfig = getAgencyConfig()
        print("Agency config \(agencyConfig)")
        print("sdkApi.agentProvisionAsync...")
        sdkApi.agentProvisionAsync(agencyConfig) { (error, oneTimeInfo) in
            if let nsError = error as NSError?, nsError.code == 1075 {
                print("ERROR: 1075 WalletAccessFailed: The `wallet_name` already exist, but you provided different `wallet_key`. Use the same `wallet_key` once it's generated for the first time.")
                return
            }
            guard !printError(label: "agentProvisionAsync", error) else { return }
            
            print("Success: agentProvisionAsync: oneTimeInfo: \(String(describing: oneTimeInfo))")
            let config = CMConfig.vsxConfig(oneTimeInfo: oneTimeInfo)
            print("Updated config: \(config!))")
            print("sdkApi.initWithConfig...")
            sdkApi.initWithConfig(config) { (error) in
                guard !printError(label: "initWithConfig", error) else { return }
                
                (UIApplication.shared.delegate as? AppDelegate)?.sdkInited = true
                print("######## VCX Config Successful! :) #########")
                NotificationCenter.post(SdkEvent.ready)
            }
        }
    }
    
    /// Update `oneTimeInfo` with our data and store in a kaychain. If `oneTimeInfo` is nil, then read from the keychain
    /// - Parameter oneTimeInfo: the configuration returned from `agentProvisionAsync`
    static func vsxConfig(oneTimeInfo: String?) -> String? {
        var vcxConfig: String!
        let kkey = "vcxConfig-" + walletName
        if let oneTimeInfo = oneTimeInfo {
            // V1: genesis file by file path. This does not work. Something with formatting.
//            let genesisFile = try! String(contentsOf: URL(fileURLWithPath: genesisFilePath()))
//            print(genesisFile)
//            vcxConfig = updateJSONConfig(jsonConfig: oneTimeInfo, withValues: [
//                "poolConfig": genesisFile,
//                "institution_logo_url": "https://robothash.com/logo.png",
//                "institution_name": "real institution name",
//                "pool_name": "7e96cbb3b0a1711f3b843af3cb28e31dcmpool",
//                "protocol_version": "2"
//            ])
            // V2: genesis included
            vcxConfig = updateJSONConfig(jsonConfig: oneTimeInfo, withValues: [
                "genesis_path": genesisFilePath(),
                "institution_logo_url": "https://robothash.com/logo.png",
                "institution_name": "real institution name",
                "pool_name": "7e96cbb3b0a1711f3b843af3cb28e31dcmpool",
                "protocol_version": "2"
            ])
            keychain[kkey] = vcxConfig
            return vcxConfig
        }
        else if let vcxConfig = keychain[kkey] {
            return vcxConfig
        }
        else {
            print("Error Code while finding `\(kkey)`")
            return nil
        }
    }
    
    // MARK: - Connection
    
    /// Connect with given invitation
    /// - Parameters:
    ///   - inviteDetails: the invitation details taken from QR code URL
    ///   - callback: the callback to return a handle after success connection or error
    static func connect(withInviteDetails inviteDetails: JSON, callback: @escaping (Int?, Error?)->()) {
        guard let sdkApi = (UIApplication.shared.delegate as? AppDelegate)?.sdkApi else { print("ERROR: no sdkAPI"); return }
        let inviteLabel = inviteDetails["label"].stringValue /// TODO may be `@id` field should be used
        
        // Create connection
        sdkApi.connectionCreate(withInvite: inviteLabel, inviteDetails: inviteDetails.rawString() ?? "") { (error, connectionHandle) in
            guard !printError(label: "connectionCreate:withInvite", error) else { callback(nil, error);  return }
            print("connectionCreate: inviteDetails was successful!")
            print("connectionHandle: \(connectionHandle)")
//            let handle = VcxHandle(truncatingIfNeeded: connectionHandle)
            callback(connectionHandle, nil)
        }
    }
    
    static func connectionGetState(handle: Int, callback: @escaping (Int?, Error?)->()) {
        guard let sdkApi = (UIApplication.shared.delegate as? AppDelegate)?.sdkApi else { print("ERROR: no sdkAPI"); return }
        sdkApi.connectionGetState(Int(handle)) { (error, state) in
            guard !printError(label: "connectionGetState", error) else { callback(nil, error); return }
            print("connectionGetState was successful (state=\(state))!")
            callback(state, nil)
        }
    }
    
    static func connectionUpdateState(handle: Int, callback: @escaping (Int?, Error?)->()) {
        guard let sdkApi = (UIApplication.shared.delegate as? AppDelegate)?.sdkApi else { print("ERROR: no sdkAPI"); return }
        sdkApi.connectionUpdateState(Int(handle)) { (error, state) in
            guard !printError(label: "connectionUpdateState", error) else { callback(nil, error); return }
            print("connectionUpdateState was successful (state=\(state))!")
            callback(state, nil)
        }
    }
    
    // MARK: -
    
    /// Prints error if presented
    /// - Parameters:
    ///   - label: the label, e.g. the method or API name
    ///   - error: the error
    /// - Returns: true - if error found
    static func printError(label: String, _ error: Error?) -> Bool {
        if error != nil && (error as NSError?)?.code != 0 { print("ERROR [\(label)]: \(String(describing: error))"); return true }
        return false
    }
}
