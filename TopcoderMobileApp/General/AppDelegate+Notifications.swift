//
//  AppDelegate+Notifications.swift
// TopcoderMobileApp
//
//  Created by Volkov Alexander on 12/27/20.
//  Copyright © 2020 Volkov Alexander. All rights reserved.
//

import UIKit
import SwiftEx83
import UserNotifications

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // MARK: User Notification Center
    
    /// Request/check authorization for push notifications and schedule reminders
    static func requestUserNotificationAuthorization(provisional: Bool = false) {
        let options: UNAuthorizationOptions = provisional ? [.alert, .sound, .badge, .providesAppNotificationSettings, .provisional] : [.alert, .sound, .badge, .providesAppNotificationSettings]
        UNUserNotificationCenter.current().requestAuthorization(options: options, completionHandler: { (granted, error) in
            DispatchQueue.main.async {
                if let error = error, UIApplication.shared.applicationState == .active {
                    showError(errorMessage: error.localizedDescription)
                    return
                }
                if granted {
                    if UIApplication.shared.applicationState == .active && !AppDelegate.tokenRequested && AppDelegate.deviceToken == nil {
                        AppDelegate.tokenRequested = true
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
                else {
                    deviceToken = nil
                }
            }
        })
    }
    
    // MARK: - Remote
    
    /// Send POST /user with device token when registered for remote push notifications
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        print("application: didRegisterForRemoteNotificationsWithDeviceToken: \(token)")
        AppDelegate.deviceToken = token
        AppDelegate.tokenRequested = false
        
        API.registerApn(token: token)
            .subscribe(onNext: { _ in
                print("Token registered")
                return
            }, onError: { error in
                showError(errorMessage: error.localizedDescription)
            }).disposed(by: rx.disposeBag)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("ERROR: \(error)")
    }
    
    // Handle silent Push Notifications
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // TODO process APN
        print("application:didReceiveRemoteNotification userInfo=\(userInfo)")
        completionHandler(.noData)
    }
}
