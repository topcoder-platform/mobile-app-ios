//
//  AbstractViewController.swift
// TopcoderMobileApp
//
//  Created by Volkov Alexander on 1/30/21.
//  Copyright © 2021 Volkov Alexander. All rights reserved.
//

import UIKit
import SwiftEx83
import MobileWallet

/// Parent view controller for screens using the library
class AbstractViewController: UIViewController {

    internal var initIndicator: ActivityIndicator?

    override func viewDidLoad() {
        NotificationCenter.add(observer: self, selector: #selector(notificationHandler(_:)), name: SdkEvent.ready)
        if !CMConfig.shared.sdkInited {
            showInitIndicator()
        }
    }
    
    /// Show SDK initialization indicator
    internal func showInitIndicator() {
        initIndicator = ActivityIndicator(parentView: self.view).start()
    }
    
    /// Hide SDK initialization indicator
    internal func hideInitIndicator() {
        self.initIndicator?.stop()
        self.initIndicator = nil
    }
    
    @objc func notificationHandler(_ notification: UIKit.Notification) {
        if notification.name.rawValue == SdkEvent.ready.rawValue {
            delay(0.1) { [weak self] in
                self?.initializationComplete()
            }
        }
    }
    
    /// Process initialization completion
    internal func initializationComplete() {
        hideInitIndicator()
    }
}
