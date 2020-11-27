//
//  AppDelegate.swift
//  EvernymApp
//
//  Created by Volkov Alexander on 10/4/20.
//  Copyright © 2020 Volkov Alexander. All rights reserved.
//

import UIKit
import vcx
import SwiftyJSON

/// https://github.com/hyperledger/indy-sdk/blob/master/vcx/wrappers/python3/vcx/state.py
enum ConnectionState: Int {
    case Undefined = 0,
    Initialized = 1,
    OfferSent = 2,
    RequestReceived = 3,
    Accepted = 4,
    Unfulfilled = 5,
    Expired = 6,
    Revoked = 7,
    Redirected = 8,
    Rejected = 9
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var sdkApi: ConnectMeVcx!
    var sdkInited = false
    
    func trySdk() {
        print()
        print("Trying SDK:")
        //        let json = """
        //{"profileUrl": "https://robohash.org/234","recipientKeys": ["8CNTANvyS6um8tzi9DJVxwqbaCSPwCiKjTkivo2NUWig"],"@type": "did:sov:BzCbsNYhMrjHiqZDTUASHg;spec/connections/1.0/invitation","label": "rel01","serviceEndpoint": "http://vas.pps.evernym.com:80/agency/msg","routingKeys": ["8CNTANvyS6um8tzi9DJVxwqbaCSPwCiKjTkivo2NUWig","ExPFLx4uNjF9jRQJV7XxAt8MfuXJENgbgA1qNmWznsRZ"],"@id": "366aae34-395f-49ec-9e77-7bc89b0ba8fd"}
        //"""
        
        // this configuration is from another example and it also works
//        let provisionConfig = """
//            {
//              "agency_url": "http://13.125.5.122:8080",
//              "agency_did": "VsKV7grR1BUE29mG2Fm2kX",
//              "agency_verkey": "Hezce2UWMZ3wUhVkh2LfKSs8nDzWwzs2Win7EzNN3YaR",
//              "wallet_name": "alice_wallet",
//              "wallet_key": "123",
//              "payment_method": "null",
//              "enterprise_seed": "000000000000000000000000Trustee1",
//              "protocol_type": "4.0"
//            }
//            """
// universal-identity-api.herokuapp.com
//        http://vas.pps.evernym.com:80
        
        
//        let provisionConfig =
//"""
//{
//    "agency_url": "http://agency.pps.evernym.com",
//    "agency_did": "3mbwr7i85JNSL3LoNQecaW",
//    "agency_verkey": "2WXxo6y1FJvXWgZnoYUP5BJej2mceFrqBDNPE3p6HDPf",
//    "poolConfig": \(genesisJson?.rawString() ?? ""),
//    "payment_method": "sov",
//    "protocol_type": "3.0"
//}
//"""
        // 1. The configuration
        /// 1.1. Generate wallet key
        var walletKey = "bJpg7bZHyhx8AptaGijcZTptVBUagM7SAKNwrY0q5cQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
        let walletName = "Topcoder-Dev"
//        var keyData = Data(count: 128)
//        let result = keyData.withUnsafeMutableBytes {
//            SecRandomCopyBytes(kSecRandomDefault, 32, $0.baseAddress!)
//        }
//        if result == errSecSuccess {
//            walletKey = keyData.base64EncodedString()
//            print("Wallet key generated successfully")
//        } else {
//            print("Problem generating random bytes")
//        }
        
        
        let provisionConfig = """
        {
        "agency_url": "https://agency.pstg.evernym.com",
        "agency_did": "LqnB96M6wBALqRZsrTTwda",
        "agency_verkey": "BpDPZHLbJFu67sWujecoreojiWZbi2dgf4xnYemUzFvB",
        "wallet_name": "\(walletName)",
        "wallet_key": "\(walletKey)"
        }
        """
        
//        let genesisJson = JSON.resource(named: "genesis", ext: "json")
//        let provisionConfig = """
//    {
//      "agency_url": "http://agency.pps.evernym.com",
//      "agency_did": "3mbwr7i85JNSL3LoNQecaW",
//      "agency_verkey": "2WXxo6y1FJvXWgZnoYUP5BJej2mceFrqBDNPE3p6HDPf",
//      "poolConfig": \(genesisJson?.rawString() ?? ""),
//        "wallet_name": "\(walletName)",
//        "wallet_key": \(walletKey),
//      "payment_method": "sov",
//      "protocol_type": "3.0"
//    }
//"""
        //    poolConfig: [content of genesis pool file],
        let genesisFilePath = Bundle.main.path(forResource: "genesis", ofType: "txn")
        
        // 2. Taken from invitation URL (should be scanned)
        let inviteDetails = """
{
  "profileUrl": "https://robohash.org/234",
  "recipientKeys": ["Gw9sPetWnyh2hkpY8m7uL7qgGedk9pFAj1u7sV3nMK2W"],
  "@type": "did:sov:BzCbsNYhMrjHiqZDTUASHg;spec/connections/1.0/invitation",
  "label": "rel01",
  "serviceEndpoint": "http://vas.pps.evernym.com:80/agency/msg",
  "routingKeys": [
    "Gw9sPetWnyh2hkpY8m7uL7qgGedk9pFAj1u7sV3nMK2W",
    "ExPFLx4uNjF9jRQJV7XxAt8MfuXJENgbgA1qNmWznsRZ"
  ],
  "@id": "a60ee33b-3edc-47da-9adc-ae772678baaf"
}
"""
        // Prepare config
        print(provisionConfig)
        sdkApi.agentProvisionAsync(provisionConfig) { (error, config) in
            self.printError(error)
            print("agentProvisionAsync was successful: \(config!)\n")
            var jsonConfig = try! JSON(data: config!.data(using: .utf8)!)
            jsonConfig["institution_name"].string = "Topcoder LLC"
            jsonConfig["institution_logo_url"].string = "http://robohash.org/234"
            jsonConfig["genesis_path"].string = genesisFilePath
            let jsonConfigStr = jsonConfig.rawString()!
            print("Updated json: ", jsonConfigStr)
            
//            let jsonConfigStr = provisionConfig
            // Initialize SDK
            self.sdkApi.initWithConfig(jsonConfigStr) { (error) in
                self.printError(error)
                print("initWithConfig was successful!\n")
                
                // Create connection
                self.sdkApi.connectionCreate(withInvite: "rel01", inviteDetails: inviteDetails) { (error, connectionHandle) in
                    self.printError(error)
                    print("connectionCreate: inviteDetails was successful!")
                    print("connectionHandle: \(connectionHandle)")
                    let handle = VcxHandle(truncatingIfNeeded: connectionHandle)
                    
//                    self.sdkApi.connectionConnect(handle, connectionType: "{\"use_public_did\":true}") { (error, inviteDetails) in
//                        self.printError(error)
//                        print("connectionConnect:connectionType was successful!")
//                        print("delay...")
//                        sleep(4)
//
//                        self.sdkApi.connectionUpdateState(connectionHandle) { (error, state) in
//                            self.printError(error)
//                            print("connectionUpdateState was successful!: \(ConnectionState(rawValue: state)!)")
//
                            
                            // Get offers
                            self.sdkApi.credentialGetOffers(handle) { (error, offers) in
                                self.printError(error)
                                
                                print("Credential offers: ", offers)
                                if let offers = offers {
                                    // Extranct an offers from string offers
                                    let jsonOffers = try! JSON(data: offers.data(using: .utf8)!)
                                    print(jsonOffers)
                                }
                            }
                            
//                        }
//                    }
//                    self.sdkApi.connectionGetState(connectionHandle) { (error, state) in
//                        if let error = error { print("ERROR: \(error)") }
//                        let connectionState = ConnectionState(rawValue: state)
//                        print("state: \(String(describing: connectionState))")
//
//                    }
                }
            }
        }
    }

    func printError(_ error: Error?) {
        if  error != nil && (error as NSError?)?.code != 0 { print("ERROR: \(String(describing: error))") }
    }
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        sdkApi = ConnectMeVcx()
//        trySdk()
        CMConfig.initialize()
        return true
    }


}

extension JSON {
    
    /// Get JSON from resource file
    public static func resource(named name: String, ext: String) -> JSON? {
        guard let resourceUrl = Bundle.main.url(forResource: name, withExtension: ext) else {
            fatalError("Could not find resource \(name)")
        }
        
        // create data from the resource content
        var data: Data
        do {
            data = try Data(contentsOf: resourceUrl, options: Data.ReadingOptions.dataReadingMapped) as Data
        } catch let error {
            print("ERROR: \(error)")
            return nil
        }
        // reading the json
        return try? JSON(data: data)
    }
}
