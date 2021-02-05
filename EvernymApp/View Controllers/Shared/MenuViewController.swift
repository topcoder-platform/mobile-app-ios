//
//  MenuViewController.swift
//  EvernymApp
//
//  Created by Volkov Alexander on 12/26/20.
//  Copyright © 2020 Volkov Alexander. All rights reserved.
//

import UIKit
import SwiftEx83
import UIComponents
import Auth0
import Amplify

/// flag: true - menu is opened, false - else
var MenuViewControllerOpened = false

var MenuSelectedIndex = 0

class MenuViewController: UIViewController {

    @IBOutlet var buttons: [MenuButton]!
    @IBOutlet weak var versionLabel: UILabel!
    
    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        delay(0.3) { [weak self] in
            UIView.animate(withDuration: 0.3, animations: { [weak self] in
                self?.view.backgroundColor = UIColor.black.alpha(alpha: 0.5)
            }, completion: nil)
        }
        updateUI()
    }
    
    /// Update UI
    private func updateUI() {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? ""
        
        versionLabel.text = "version \(version) (build \(build))"
        
        for button in buttons {
            button.isSelected = button.tag == MenuSelectedIndex
        }
    }
    
    @IBAction func swipeLeft(_ sender: Any) {
        self.dismissMenu({})
    }

    @IBAction func buttonAction(_ sender: UIButton) {
        guard MenuSelectedIndex != sender.tag else { dismissMenu {}; return }
        if sender.tag == 4 {
            if AuthenticationUtil.isAuthenticated() {
                self.showAlert("", "The app will logout you from Topcoder") { [weak self] in
                    self?.tryLogout() {
                        self?.dismissMenu {}
                    }
                }
            }
            else {
                self.tryLogin() { [weak self] in
                    self?.dismissMenu {}
                }
            }
            return
        }
        MenuSelectedIndex = sender.tag
        updateUI()
        dismissMenu { [weak self] in
            guard let navVc = Current as? UINavigationController else { return }
            var viewController: UIViewController?
            switch sender.tag {
            case 0:
                guard let vc = self?.create(HomeViewController.self) else { return }
                viewController = vc
            case 1:
                guard let vc = self?.create(ConnectionsViewController.self) else { return }
                viewController = vc
            case 2:
                guard let vc = self?.create(CredentialsViewController.self) else { return }
                viewController = vc
            case 3:
                guard let vc = self?.create(SettingsViewController.self) else { return }
                viewController = vc
            case 4:
                break
            default: break
            }
            guard let vc = viewController else { return }
            navVc.setViewControllers([vc], animated: false)
        }
    }
    
    /// Dismiss menu and call a callback
    private func dismissMenu(_ callback: @escaping ()->()) {
        MenuViewControllerOpened = false
        UIView.animate(withDuration: 0.3, animations: {
            self.view.backgroundColor = .clear
        }, completion: nil)
        self.dismissViewControllerToSide(self, side: .left, callback)
    }
    
    private func tryLogin(callback: @escaping ()->()) {
        Auth0
            .webAuth()
            .scope("openid profile")
            .audience("https://topcoder-dev.auth0.com/userinfo")
            .start { [weak self] result in
                switch result {
                case .failure(let error):
                    
                    // Handle the error
                    print("Error: \(error)")
                    showError(errorMessage: error.localizedDescription)
                case .success(let credentials):
                    
                    // Save credentials
                    print("Credentials: \(credentials)")
                    AuthenticationUtil.processCredentials(credentials: credentials)
                    UIViewController.getCurrentViewController()?.showAlert("Success login", "Tokens are stored in Keychain")
                    
                    // Event
                    Amplify.Analytics.tryRecord(event: BasicAnalyticsEvent(name: "App", properties: ["event_action": "Login"]))
                }
                callback()
        }
    }
    
    private func tryLogout(callback: @escaping ()->()) {
        Auth0
            .webAuth()
            .clearSession(federated: false) { result in
                if result {
                    AuthenticationUtil.cleanUp()
                }
                callback()
        }
    }
}
