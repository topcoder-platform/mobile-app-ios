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
import Combine

enum SdkEvent: String {
    case ready
}

typealias VcxUtil = CMConfig

/// Utility used for configuration
class CMConfig {
    
    enum Environment: Int {
        case sandbox = 0, production = 1, staging = 2, demo = 3
    }
    
    static let environment: Environment = .staging
    static let walletName = "Topcoder-Dev-Real"
    
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
            // sandbox
            "0": [ // taken from https://github.com/sovrin-foundation/connector-app/blob/master/app/store/config-store.js
                "agencyUrl": "http://52.25.123.226",
                "agencyDid": "Nv9oqGX57gy15kPSJzo2i4",
                "agencyVerKey": "CwpcjCc6MtVNdQgwoonNMFoR6dhzmRXHHaUCRSrjh8gj"
            ],
            // production
            "1": [
                "agencyUrl": "https://agency.evernym.com",
                "agencyDid": "DwXzE7GdE5DNfsrRXJChSD",
                "agencyVerKey": "844sJfb2snyeEugKvpY7Y4jZJk9LT6BnS6bnuKoiqbip"
            ],
            // staging
            "2": [
                "agencyUrl": "https://agency.pstg.evernym.com",
                "agencyDid": "LqnB96M6wBALqRZsrTTwda",
                "agencyVerKey": "BpDPZHLbJFu67sWujecoreojiWZbi2dgf4xnYemUzFvB"
            ],
            // demo
            "3": [
                "agencyUrl": "https://agency.pps.evernym.com",
                "agencyDid": "3mbwr7i85JNSL3LoNQecaW",
                "agencyVerKey": "2WXxo6y1FJvXWgZnoYUP5BJej2mceFrqBDNPE3p6HDPf",
            ],
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
        
//         TODO If you used a key, then uncomment next line and copy it there, then launch the app once, it will store the key in a kaychain
//        do {
////            let existingKey = "<put key here>"
//            let existingKey = "bJpg7bZHyhx8AptaGijcZTptVBUagM7SAKNwrY0q5cQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
//            keychain[key] = existingKey
//            return existingKey
//        }

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
            return "pool_transactions_genesis_SANDBOX_4"
        case .staging:
            return "pool_transactions_genesis_STAG_4"
        case .demo:
            return "pool_transactions_genesis_DEMO_4"
        case .production:
            return "pool_transactions_genesis_PROD_4"
        }
    }
    
    static func genesisFile(environment: Environment) -> String {
        switch environment {
        case .sandbox:
            return sandboxPoolTxnGenesisDef1
        case .staging:
            return stagingPoolTxnGenesisDef1
        case .demo:
            return demoPoolTxnGenesisDef
        case .production:
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
    static func initialize() -> Future<Void, Error> {
        return Future { promise in
            guard let sdkApi = (UIApplication.shared.delegate as? AppDelegate)?.sdkApi else { promise(.failure("ERROR: no sdkAPI")); return }
            let agencyConfig = getAgencyConfig()
            print("Agency config \(agencyConfig)")
            print("sdkApi.agentProvisionAsync...")
            sdkApi.agentProvisionAsync(agencyConfig) { (error, oneTimeInfo) in
                if let nsError = error as NSError?, nsError.code == 1075 {
                    promise(.failure(nsError))
                    print("ERROR: 1075 WalletAccessFailed: The `wallet_name` already exist, but you provided different `wallet_key`. Use the same `wallet_key` once it's generated for the first time.")
                    return
                }
                guard !printError(label: "agentProvisionAsync", error, promise: promise) else { return }
                
                print("Success: agentProvisionAsync: oneTimeInfo: \(String(describing: oneTimeInfo))")
                let config = CMConfig.vsxConfig(oneTimeInfo: oneTimeInfo)
                print("Updated config: \(config!))")
                print("sdkApi.initWithConfig...")
                sdkApi.initWithConfig(config) { (error) in
                    guard !printError(label: "initWithConfig", error, promise: promise) else { return }
                    
                    (UIApplication.shared.delegate as? AppDelegate)?.sdkInited = true
                    print("######## VCX Config Successful! :) #########")
                    NotificationCenter.post(SdkEvent.ready)
                    promise(.success(()))
                }
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
//                "protocol_version": "2",
//                "protocol_type": "3.0",
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
    func connect(withInviteDetails inviteDetails: JSON) -> Future<Int, Error> {
        return Future { promise in
            guard let sdkApi = (UIApplication.shared.delegate as? AppDelegate)?.sdkApi else { promise(.failure("ERROR: no sdkAPI")); return }
            let inviteLabel = inviteDetails["label"].stringValue /// TODO may be `@id` field should be used
            
            // Create connection
            sdkApi.connectionCreate(withInvite: inviteLabel, inviteDetails: inviteDetails.rawString() ?? "") { (error, connectionHandle) in
                guard !CMConfig.printError(label: "connectionCreate:withInvite", error, promise: promise) else { return }
                print("connectionCreate:inviteDetails was successful!")
                print("connectionHandle: \(connectionHandle)")
                //            let handle = VcxHandle(truncatingIfNeeded: connectionHandle)
                promise(.success(connectionHandle))
            }
        }
    }
    
    func connectionDids(handle: Int) -> Future<(String, String), Error> {
        return Future { promise in
            guard let sdkApi = (UIApplication.shared.delegate as? AppDelegate)?.sdkApi else { promise(.failure("ERROR: no sdkAPI")); return }
//            let handle = VcxHandle(truncatingIfNeeded: handle)
            sdkApi.connectionGetPwDid(handle) { (error, pwdid) in
                guard !CMConfig.printError(label: "connectionGetPwDid", error, promise: promise) else { return }
                
                sdkApi.connectionGetTheirPwDid(handle) { (error, theidDid) in
                    guard !CMConfig.printError(label: "connectionGetPwDid", error, promise: promise) else { return }
                    promise(.success(((pwdid ?? "-"), (theidDid ?? "-"))))
                }
            }
        }
    }
    
    /// Need to wait >4 seconds after connection is established
    /// - Parameters:
    ///   - handle: the handle
    ///   - callback: the callback to call when connection is done/fails
    func connect(handle: Int) -> Future<Void, Error> {
        return Future { promise in
            guard let sdkApi = (UIApplication.shared.delegate as? AppDelegate)?.sdkApi else { promise(.failure("ERROR: no sdkAPI")); return }
            // Connect
            let handle = VcxHandle(truncatingIfNeeded: handle)
            sdkApi.connectionConnect(handle, connectionType: "{\"use_public_did\":true}") { (error, _) in
                guard !CMConfig.printError(label: "connectionConnect:handle", error, promise: promise) else { return }
                print("connectionConnect:handle was successful!")
                promise(.success(()))
            }
        }
    }
    
    func connectionGetState(handle: Int) -> Future<Int, Error> {
        return Future { promise in
            guard let sdkApi = (UIApplication.shared.delegate as? AppDelegate)?.sdkApi else { promise(.failure("ERROR: no sdkAPI")); return }
            sdkApi.connectionGetState(Int(handle)) { (error, state) in
                guard !CMConfig.printError(label: "connectionGetState", error, promise: promise) else { return }
                print("connectionGetState was successful (state=\(state))!")
                promise(.success(state))
            }
        }
    }
    
    func connectionUpdateState(handle: Int) -> Future<Int, Error> {
        return Future { promise in
            guard let sdkApi = (UIApplication.shared.delegate as? AppDelegate)?.sdkApi else { promise(.failure("ERROR: no sdkAPI")); return }
            sdkApi.connectionUpdateState(Int(handle)) { (error, state) in
                guard !CMConfig.printError(label: "connectionUpdateState", error, promise: promise) else { return }
                print("connectionUpdateState was successful (state=\(state))!")
                promise(.success(state))
            }
        }
    }
    
    func connectionSerialize(handle: Int) -> Future<String, Error> {
        return Future { promise in
            guard let sdkApi = (UIApplication.shared.delegate as? AppDelegate)?.sdkApi else { promise(.failure("ERROR: no sdkAPI")); return }
            sdkApi.connectionSerialize(Int(handle)) { (error, serializedConnection) in
                guard !CMConfig.printError(label: "connectionSerialize", error, promise: promise) else { return }
                print("connectionSerialize was successful!")
                promise(.success(serializedConnection!))
            }
        }
    }
    
    func connectionDeserialize(serializedConnection: String) -> Future<Int, Error> {
        return Future { promise in
            guard let sdkApi = (UIApplication.shared.delegate as? AppDelegate)?.sdkApi else { promise(.failure("ERROR: no sdkAPI")); return }
            sdkApi.connectionDeserialize(serializedConnection) { (error, handle) in
                guard !CMConfig.printError(label: "connectionDeserialize", error, promise: promise) else { return }
                print("connectionDeserialize was successful!")
                promise(.success(handle))
            }
        }
    }
    
    func connectionRelease(handle: Int) {
        guard let sdkApi = (UIApplication.shared.delegate as? AppDelegate)?.sdkApi else { return }
        sdkApi.connectionRelease(handle)
    }
    
    // MARK: - Credentials
    
    func credentialGetOffers(connectionHandle: Int) -> Future<String, Error> {
        return Future { promise in
            guard let sdkApi = (UIApplication.shared.delegate as? AppDelegate)?.sdkApi else { promise(.failure("ERROR: no sdkAPI")); return }
            let handle = VcxHandle(truncatingIfNeeded: connectionHandle)
            sdkApi.credentialGetOffers(handle) { (error, offers) in
                guard !CMConfig.printError(label: "credentialGetOffers", error, promise: promise) else { return }
                print("credentialGetOffers was successful!")
                promise(.success(offers!))
            }
        }
    }
    
    func credentialCreateWithOffer(sourceId: String, credentialOffer: String) -> Future<Int, Error> {
        return Future { promise in
            guard let sdkApi = (UIApplication.shared.delegate as? AppDelegate)?.sdkApi else { promise(.failure("ERROR: no sdkAPI")); return }
            sdkApi.credentialCreate(withOffer: sourceId, offer: credentialOffer) { error, credentialHandle in
                guard !CMConfig.printError(label: "credentialCreate", error, promise: promise) else { return }
                print("credentialGetOffers was successful!")
                promise(.success(credentialHandle))
            }
        }
    }
    
    func credentialSendRequest(credentialHandle: Int, connectionHandle: Int, paymentHandle: Int) -> Future<String, Error> {
        return Future { promise in
            guard let sdkApi = (UIApplication.shared.delegate as? AppDelegate)?.sdkApi else { promise(.failure("ERROR: no sdkAPI")); return }
            sdkApi.credentialSendRequest(credentialHandle, connectionHandle: VcxHandle(truncatingIfNeeded: connectionHandle), paymentHandle: vcx_payment_handle_t(paymentHandle)) { error in
                guard !CMConfig.printError(label: "credentialSendRequest", error, promise: promise) else { return }
                print("credentialSendRequest was successful!")
                promise(.success(""))
            }
        }
    }
    
    func credentialUpdateState(credentialHandle: Int) -> Future<Int, Error> {
        return Future { promise in
            guard let sdkApi = (UIApplication.shared.delegate as? AppDelegate)?.sdkApi else { promise(.failure("ERROR: no sdkAPI")); return }
            sdkApi.credentialUpdateState(credentialHandle) { error, state in
                guard !CMConfig.printError(label: "credentialUpdateState", error, promise: promise) else { return }
                print("credentialUpdateState was successful!")
                promise(.success(state))
            }
        }
    }
    
    func credentialRelease(credentialHandle: Int) -> Int {
        guard let sdkApi = (UIApplication.shared.delegate as? AppDelegate)?.sdkApi else { return -1 }
        return Int(sdkApi.connectionRelease(credentialHandle))
    }
    
    // MARK: -
    
    /// Prints error if presented
    /// - Parameters:
    ///   - label: the label, e.g. the method or API name
    ///   - error: the error
    /// - Returns: true - if error found
    static func printError<O>(label: String, _ error: Error?, promise: Future<O, Error>.Promise) -> Bool {
        if error != nil && (error as NSError?)?.code != 0 { print("ERROR [\(label)]: \(String(describing: error))"); promise(.failure(error!));return true }
        return false
    }
}
