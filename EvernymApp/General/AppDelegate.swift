//
//  AppDelegate.swift
//  EvernymApp
//
//  Created by Volkov Alexander on 10/4/20.
//  Copyright © 2020 Volkov Alexander. All rights reserved.
//

import UIKit
import SwiftyJSON
import SwiftEx83
import Combine
import AppCenter
import AppCenterDistribute
import MobileWallet

enum SdkEvent: String {
    case ready
}

/**
 All previous code (`CMConfig`, etc.) moved into separate library https://github.com/topcoder-platform/mobile-wallet .
 If you need to check working version before the library added, then check code before https://github.com/topcoder-platform/evernym-tc-wallet/issues/25 was merged
 */
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var cancellable: AnyCancellable?
    
    /// the device token for push notifications
    static var deviceToken: String?
    /// true - if device token was requested, false - else
    static var tokenRequested = false
    
    static var shared: AppDelegate!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        AppDelegate.shared = self
        
        // AppCenter
        #if !DEBUG
        Distribute.updateTrack = .private
        AppCenter.start(withAppSecret: Configuration.appCenterSecret, services: [Distribute.self])
        #endif
        
        // VCX
        // Configure wallet (UNCOMMENT .staging or .demo)
        // If you launched with another configuration, then use `CMConfig.shared.setupWallet(force: true)` to regenerate the wallet for another configuration.
        do { // .staging
            CMConfig.shared.environment = .staging
            CMConfig.shared.setupWallet()
            CMConfig.shared.poolName = "7e96cbb3b0a1711f3b843af3cb28e31dcmpool"
        }
//        do { // .demo
//            CMConfig.shared.environment = .demo
//            CMConfig.shared.setupWallet()
//        }
        
        
        
        /************ Configuration used for  for debugging (DONT UNCOMMENT IT) ************/
        // For use in MobilbeWalletExample
//        do {
//            CMConfig.shared.environment = .staging
//            CMConfig.shared.walletName = "Topcoder-Dev-Real"
//            CMConfig.shared.walletKey = "bJpg7bZHyhx8AptaGijcZTptVBUagM7SAKNwrY0q5cQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
//            CMConfig.shared.poolName = "7e96cbb3b0a1711f3b843af3cb28e31dcmpool"
//        }
        
        // For use in the app
//        do {
//            CMConfig.shared.environment = .staging
//            CMConfig.shared.setup(walletName: "Topcoder-Dev-Real-App", walletKey: "WM+k4d4XynyQ1bUQUt611MMimKFV9DJu9DTmIWt8srMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=")
//            CMConfig.shared.poolName = "7e96cbb3b0a1711f3b843af3cb28e31dcmpool"
//        }
//        do {
//            CMConfig.shared.environment = .demo
//            CMConfig.shared.setup(walletName: "Topcoder-Dev-2", walletKey: "nB5cs1+25cLeD5mbXcLWAiLTiHvVQKpE9Nb4IMD7J3IAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=")
//        }
        /*\\\\\\\\\\\\\\\\\\\\\\\ Values for debugging //////////////// */
        
        
                
        // Initialize
        cancellable = CMConfig.shared.initialize()
            .sink(receiveCompletion: { completion in
            switch completion {
            case .finished:
                NotificationCenter.post(SdkEvent.ready)
            case .failure(let error):
                showError(errorMessage: error.localizedDescription)
            }
        }, receiveValue: { _ in })
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
