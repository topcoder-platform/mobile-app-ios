//
//  NewConnectionViewController.swift
// TopcoderMobileApp
//
//  Created by Volkov Alexander on 12/27/20.
//  Copyright © 2020 Volkov Alexander. All rights reserved.
//

import UIKit
import SwiftEx83

/// New connection
class NewConnectionViewController: UIViewController {

    /// outlets
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var currentImage: UIImageView!
    @IBOutlet weak var remoteImage: UIImageView!
    
    var connection: Connection!
    
    var callback: (()->())!
    
    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()
        currentImage.round()
        remoteImage.round()
        updateUI()
    }
    
    /// Update UI
    private func updateUI() {
        messageLabel.text = connection.name
        messageLabel.textColor = connection.type.color
        remoteImage.image = connection.type.icon
        remoteImage.backgroundColor = connection.type.color
    }
    
    /// "Deny" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    /// "Connect" button action handler
    ///
    /// - parameter sender: the button
    @IBAction func connectAction(_ sender: Any) {
        let callback = self.callback
        dismiss(animated: true, completion: callback)
    }
}
