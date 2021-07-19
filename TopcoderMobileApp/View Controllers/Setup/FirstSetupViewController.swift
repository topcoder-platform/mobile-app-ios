//
//  FirstSetupViewController.swift
// TopcoderMobileApp
//
//  Created by Volkov Alexander on 12/26/20.
//  Copyright © 2020 Volkov Alexander. All rights reserved.
//

import UIKit
import SwiftEx83

/// First screen
/// setup complete -> Home
/// no -> BiometricsViewController
class FirstSetupViewController: UIViewController {
    
    @IBAction func setupAction(_ sender: Any) {
        UserDefaults.setupCompleted = true // mark as completed
        guard let vc = create(BiometricsViewController.self) else {
            return
        }
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
}

