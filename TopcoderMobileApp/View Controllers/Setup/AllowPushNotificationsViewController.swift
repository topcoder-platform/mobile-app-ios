//
//  AllowPushNotificationsViewController.swift
// TopcoderMobileApp
//
//  Created by Volkov Alexander on 12/27/20.
//  Copyright © 2020 Volkov Alexander. All rights reserved.
//

import UIKit
import SwiftEx83

class AllowPushNotificationsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.darkGray.alpha(alpha: 0.5)
    }
    
    @IBAction func notNowAction(_ sender: Any) {
        closeModal()
    }
    
    @IBAction func allowAction(_ sender: Any) {
        closeModal()
        DispatchQueue.main.async {
            UserDefaults.askedApn = true
            AppDelegate.requestUserNotificationAuthorization()
        }
    }
    
    private func closeModal() {
        self.dismissViewControllerToSide(self, side: .bottom, nil)
    }
    
}
