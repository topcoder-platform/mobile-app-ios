//
//  CMConfig.swift
//  EvernymApp
//
//  Created by Volkov Alexander on 11/22/20.
//  Copyright © 2020 Volkov Alexander. All rights reserved.
//

import Foundation
import vcx
import Combine

typealias VcxUtil = CMConfig

/**
 Utility used for configuration
 ```
 VcxLogger.setDefault(nil)
 
 CMConfig.shared.environment = .staging
 CMConfig.shared.walletName = "My Wallet"
 // CMConfig.shared.walletKey = "...<put key here if you are using the same key on other device>"
 // CMConfig.shared.poolName = "<put pool name if you know it>"
 var cancellable: AnyCancellable? = CMConfig.shared.initialize()
    .sink(receiveCompletion: { completion in
        switch completion {
        case .finished:
            // Can be used further. Notify UI that library is ready
        case .failure(let error):
            // Process initialization error
        }
    }, receiveValue: { _ in })
```
*/
open class CMConfig {
    
    public enum Environment: Int {
        case sandbox = 0, production = 1, staging = 2, demo = 3
        
        public var config: Dictionary<String, String> {
            switch self {
            case .sandbox:
                return [ // taken from https://github.com/sovrin-foundation/connector-app/blob/master/app/store/config-store.js
                    "agencyUrl": "http://52.25.123.226",
                    "agencyDid": "Nv9oqGX57gy15kPSJzo2i4",
                    "agencyVerKey": "CwpcjCc6MtVNdQgwoonNMFoR6dhzmRXHHaUCRSrjh8gj"
                ]
            case .production:
                return [
                    "agencyUrl": "https://agency.evernym.com",
                    "agencyDid": "DwXzE7GdE5DNfsrRXJChSD",
                    "agencyVerKey": "844sJfb2snyeEugKvpY7Y4jZJk9LT6BnS6bnuKoiqbip"
                ]
            case .staging:
                return [
                    "agencyUrl": "https://agency.pstg.evernym.com",
                    "agencyDid": "LqnB96M6wBALqRZsrTTwda",
                    "agencyVerKey": "BpDPZHLbJFu67sWujecoreojiWZbi2dgf4xnYemUzFvB"
                ]
            case .demo:
                return [
                    "agencyUrl": "https://agency.pps.evernym.com",
                    "agencyDid": "3mbwr7i85JNSL3LoNQecaW",
                    "agencyVerKey": "2WXxo6y1FJvXWgZnoYUP5BJej2mceFrqBDNPE3p6HDPf",
                ]
            }
        }
    }
    
    /// the shared instance
    public static var shared = CMConfig()
    
    /// the environment to use
    public var environment: Environment = .staging
    // Custom config used for initialization. Ignores `.environment` value.
    public var customConfig: Dictionary<String, String>?
    
    
    // Configuration
    /// the wallet name
    public var walletName = "Topcoder-Dev-Real"
    /// the wallet key. If nil, then library will try to restore the key from Keychain. If it's missing, then will generate new key
    public var walletKey: String?
    /// the pool name
    public var poolName: String?
    
    
    // Keychain utility used to store `walletKey` and `vcxConfig`
    public var keychain: Keychain = {
        let util = Keychain(service: "MobileWallet")
        util.queryConfiguration = { query in
            let query = NSMutableDictionary(dictionary: query)
            query[kSecAttrAccessible] = kSecAttrAccessibleWhenUnlocked
            return query
        }
        return util
    }()
    
    public static var sdkApi: ConnectMeVcx = {
        return ConnectMeVcx()
    }()
    
    public var sdkInited = false
    
    public func getAgencyConfig() -> String {
        let config = customConfig ?? environment.config
        let agencyUrl = config["agencyUrl"] ?? ""
        let agencyDid = config["agencyDid"] ?? ""
        let agencyVerKey = config["agencyVerKey"] ?? ""
        
        let walletKey = getWalletKey()
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
    
    /// Get wallet key from the keychain or generate if it's missing.
    /// - Returns: the wallet key
    public func getWalletKey() -> String {
        let key = "walletKey-" + walletName
        // Check if stored in a keychain
        if let walletKey = keychain[key] {
            return walletKey
        }
        else if let walletKey = self.walletKey {
            keychain[key] = walletKey
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
    
    public static func genesisFileName(environment: Environment) -> String {
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
    
    func genesisFilePath() -> String {
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
    
    public func updateJSONConfig(jsonConfig: String, withValues values: [String: Any]) -> String {
        do {
            var json: [String: Any] = try Dictionary.from(string: jsonConfig)
            for (k,v) in values {
                json[k] = v
            }
            return try json.toJson()
        }
        catch {
            print("ERROR in updateJSONConfig(): \(error)")
            return jsonConfig
        }
    }
    
    // MARK: - VCX Init
    
    /// Initialize library. Configure environment, wallet, etc. before calling this method.
    public func initialize() -> Future<Void, Error> {
        return Future { promise in
            let sdkApi = CMConfig.sdkApi
            let agencyConfig = self.getAgencyConfig()
            print("Agency config \(agencyConfig)")
            print("sdkApi.agentProvisionAsync...")
            sdkApi.agentProvisionAsync(agencyConfig) { (error, oneTimeInfo) in
                if let nsError = error as NSError?, nsError.code == 1075 {
                    promise(.failure(nsError))
                    print("ERROR: 1075 WalletAccessFailed: The `wallet_name` already exist, but you provided different `wallet_key`. Use the same `wallet_key` once it's generated for the first time.")
                    return
                }
                guard !CMConfig.printError(label: "agentProvisionAsync", error, promise: promise) else { return }
                
                print("Success: agentProvisionAsync: oneTimeInfo: \(String(describing: oneTimeInfo))")
                let config = self.vsxConfig(oneTimeInfo: oneTimeInfo)
                print("Updated config: \(config!))")
                print("sdkApi.initWithConfig...")
//                let error = sdkApi.vcxInitCore(config) // v0.142
                print("vcxInitCore RESULT: \(String(describing: error))")
                sdkApi.initWithConfig(config) { (error) in
                    guard !CMConfig.printError(label: "initWithConfig", error, promise: promise) else { return }
                    self.sdkInited = true
                    print("######## VCX Config Successful! :) #########")
                    promise(.success(()))
                }
            }
        }
    }
    
    /// Update `oneTimeInfo` with our data and store in a kaychain. If `oneTimeInfo` is nil, then read from the keychain
    /// - Parameter oneTimeInfo: the configuration returned from `agentProvisionAsync`
    public func vsxConfig(oneTimeInfo: String?) -> String? {
        var vcxConfig: String!
        let kkey = "vcxConfig-" + walletName
        if let oneTimeInfo = oneTimeInfo {
            var dic = [
                "genesis_path": genesisFilePath(),
                "institution_logo_url": "https://robothash.com/logo.png",
                "institution_name": "Topcoder LLC",
            ]
            if let poolName = poolName {
                dic["pool_name"] = poolName
            }
            vcxConfig = updateJSONConfig(jsonConfig: oneTimeInfo, withValues: dic)
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
    // See CMConfig+Connection.swift
    
    // MARK: - Credentials
    // See CMConfig+Credentials.swift
    
    // MARK: -
    
    /// Prints error if presented
    /// - Parameters:
    ///   - label: the label, e.g. the method or API name
    ///   - error: the error
    /// - Returns: true - if error found
    public static func printError<O>(label: String, _ error: Error?, promise: Future<O, Error>.Promise) -> Bool {
        if error != nil && (error as NSError?)?.code != 0 { print("ERROR [\(label)]: \(String(describing: error))"); promise(.failure(error!));return true }
        return false
    }
    
    /// Get error code from given error
    /// - Parameter error: the error
    /// - Returns: error code (if not zero) or nil
    public static func getErrorCode(from error: Error?) -> Int? {
        if let _ = error, let code = (error as NSError?)?.code, code != 0 {
            return code
        }
        return nil
    }
}

extension Dictionary {
    
    /// Convert Dictionary to JSON string
    /// - Throws: exception if dictionary cannot be converted to JSON data or when data cannot be converted to UTF8 string
    /// - Returns: JSON string
    public func toJson() throws -> String {
        let data = try JSONSerialization.data(withJSONObject: self)
        if let string = String(data: data, encoding: .utf8) {
            return string
        }
        throw NSError(domain: "Dictionary", code: 1, userInfo: ["message": "Data cannot be converted to .utf8 string"])
    }
    
    /// Convert JSON string to dictionary
    /// - Parameter string: JSON string
    /// - Throws: exception if string cannot be converted to Dictionary or when string cannot be converted to UTF8 data
    /// - Returns: Dictionary
    public static func from(string: String) throws -> [Key: Value] {
        if let data = string.data(using: .utf8) {
            if let dic = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [Key: Value] {
                return dic
            }
            throw NSError(domain: "Dictionary", code: 1, userInfo: ["message": "Cannot parse string to Dictionary"])
        }
        else {
            throw NSError(domain: "Dictionary", code: 1, userInfo: ["message": "String cannot be converted to .utf8 data"])
        }
    }
}
