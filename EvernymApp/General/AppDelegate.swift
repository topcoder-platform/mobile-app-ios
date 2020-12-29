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
import SwiftEx83
import Combine
import AppCenter
import AppCenterDistribute

/**
 Most of the code in `AppDelegate` is a working draft. These functionality is moving into the correct place - CMConfig.swift
 */
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var cancellable: AnyCancellable?
    var sdkApi: ConnectMeVcx!
    var sdkInited = false
    
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
        VcxLogger.setDefault(nil)
        sdkApi = ConnectMeVcx()

        cancellable = CMConfig.initialize()
            .sink(receiveCompletion: { completion in
            switch completion {
            case .finished:
                AppDelegate.shared.sdkInited = true
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
