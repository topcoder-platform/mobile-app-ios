//
//  AuthenticationViewController.swift
//  EvernymApp
//
//  Created by Volkov Alexander on 12/26/20.
//  Copyright © 2020 Volkov Alexander. All rights reserved.
//

import UIKit
import UIComponents
import SwiftEx83

/// Pincode screen
class AuthenticationViewController: UIViewController, UITextFieldDelegate {

    /// outlets
    @IBOutlet var fields: [PincodeField]!
    
    let n = 6
    
    /// the callback used to provide the entered username
    var callback: ((String)->())?
    
    var digits = [String]()
    
    enum ScreenType {
        case login, settings
    }
    
    var type: ScreenType = .login
    
    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for f in fields {
            f.delegate = self
            f.tintColor = .clear
            f.keyboardType = .numberPad
        }
        updateUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if type == .login
            && UserDefaults.setupCompleted && UserDefaults.useBiometrics {
            LocalAuthenticationUtil.shared.authenticate(callback: { [weak self] (success, _) in
                DispatchQueue.main.async {
                    if success {
                        self?.showHomeScreen(animated: true)
                    }
                    else {
                        self?.fields.first?.becomeFirstResponder()
                    }
                }
            }, notSupported: { [weak self] _ in
                self?.fields.first?.becomeFirstResponder()
            })
        }
        else {
            self.fields.first?.becomeFirstResponder()
        }
    }

    /// Update UI
    private func updateUI() {
        for i in 0..<n {
            let f = fields.filter({$0.tag == i}).first
            if i < digits.count {
                f?.text = digits[i]
            }
            else {
                f?.text = ""
            }
            f?.setNeedsDisplay()
        }
        fields.filter({$0.tag == 0}).first?.setNeedsDisplay()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.count == 1 {
            if Int(string) != nil { // allow enter numbers only
                digits.append(string)
                if digits.count >= n {
                    processCode()
                }
                self.updateUI()
            }
        }
        else if string.count == 0 { // remove last digit
            if digits.count > 0 {
                digits = Array(digits[0..<(digits.count-1)])
            }
            self.updateUI()
        }
        return false
    }
    
    private func processCode() {
        self.view.endEditing(true)
        let code = digits.joined(separator: "")
        if type == .login && UserDefaults.setupCompleted {
            // Authenticate
            API.authenticate(pincode: code)
                .addActivityIndicator(on: UIViewController.getCurrentViewController() ?? self)
                .subscribe(onNext: { [weak self] value in
                    self?.showHomeScreen(animated: true)
                    return
                }, onError: { [weak self] _ in
                    self?.digits = []
                    self?.updateUI()
                }).disposed(by: rx.disposeBag)
        }
        else {
            API.setup(pincode: code)
                .addActivityIndicator(on: UIViewController.getCurrentViewController() ?? self)
                .subscribe(onNext: { [weak self] value in
                    if self?.type == .settings {
                        self?.navigationController?.popViewController(animated: true)
                    }
                    else {
                        self?.showSetupScreens()
                    }
                    return
                    }, onError: { _ in
                }).disposed(by: rx.disposeBag)
        }
    }
    
    private func showSetupScreens() {
        guard let vc = create(FirstSetupViewController.self) else { return }
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
}
