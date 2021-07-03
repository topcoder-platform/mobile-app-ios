//
//  LoginViewController.swift
//  TopcoderMobileApp
//
//  Created by Volkov Alexander on 7/2/21.
//  Copyright © 2021 Volkov Alexander. All rights reserved.
//

import UIKit
import Auth0
import SwiftEx83
import Amplify

/// Login screen
class LoginViewController: UIViewController {

    private var initialOpening: Bool = true
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if initialOpening {
            initialOpening = false
            
            // If setup completed, then move to Pin Code enter.
            if UserDefaults.setupCompleted {
                openCodeEnterScreen()
            }
            else {
                LoginViewController.tryLogin() { [weak self] success in
                    if success {
                        self?.openApnRequestScreen()
                    }
                }
            }
        }
    }
    
    static func tryLogin(callback: @escaping (Bool)->()) {
        Auth0
            .webAuth()
//            .redirectURL(URL(string: "https://accounts-auth0.topcoder.com?appUrl=http://www.topcoder.com/")!)
            .scope("openid profile")
//            .audience("https://accounts-auth0.topcoder.com/userinfo")
            .audience("https://topcoder-dev.auth0.com/userinfo")
            .start { result in
                switch result {
                case .failure(let error):
                    
                    // Handle the error
                    print("Error: \(error)")
                    showError(errorMessage: error.localizedDescription)
                    callback(false)
                case .success(let credentials):
                    
                    // Save credentials
                    print("Credentials: \(credentials)")
                    AuthenticationUtil.processCredentials(credentials: credentials)
                    
                    // Event
                    Amplify.Analytics.tryRecord(event: BasicAnalyticsEvent(name: "App", properties: ["event_action": "Login"]))
                    callback(true)
                }
                
            }
    }
    
    static func tryLogout(callback: @escaping ()->()) {
        Auth0
            .webAuth()
            .clearSession(federated: false) { result in
                if result {
                    AuthenticationUtil.cleanUp()
                }
                callback()
            }
    }
    
    /// Login completed
    private func loginCompleted() {
        
        // TMP dodo
        //        let url = URL(string: "https://accounts-auth0.topcoder.com/userinfo")!
        //        webView.load(URLRequest(url: url))
        //
        
        openApnRequestScreen()
    }
    
    private func openApnRequestScreen() {
        guard !UserDefaults.askedApn else { return }
        guard let vc = create(AllowPushNotificationsViewController.self) else { return }
        vc.modalPresentationStyle = .fullScreen
        vc.dismissNormally = true
        vc.completion = { [weak self] in
            self?.openCodeEnterScreen()
        }
        self.present(vc, animated: true, completion: nil)
    }
    
    private func openCodeEnterScreen() {
        let vc = self.create(AuthenticationViewController.self)!
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
}
