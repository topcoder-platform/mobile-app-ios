//
//  BiometricsViewController.swift
//  EvernymApp
//
//  Created by Volkov Alexander on 12/26/20.
//  Copyright © 2020 Volkov Alexander. All rights reserved.
//

import UIKit

/// "Biometrics are faster." screen
class BiometricsViewController: UIViewController {

    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /// "Use..." button action handler
    ///
    /// - parameter sender: the button
    @IBAction func useBioAction(_ sender: Any) {
        LocalAuthenticationUtil.shared.setup(on: true) { [weak self] _, _ in
            DispatchQueue.main.async {
                self?.continueSetup()
            }
        }
    }
    
    /// "No thanks" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func cancelAction(_ sender: Any) {
        continueSetup()
    }
    
    private func continueSetup() {
        DispatchQueue.main.async { [weak self] in
            self?.showHomeScreen(animated: true)
        }
    }
}
