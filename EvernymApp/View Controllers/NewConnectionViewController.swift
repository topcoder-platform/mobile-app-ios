//
//  NewConnectionViewController.swift
//  EvernymApp
//
//  Created by Volkov Alexander on 12/27/20.
//  Copyright © 2020 Volkov Alexander. All rights reserved.
//

import UIKit

/// New connection
class NewConnectionViewController: UIViewController {

    /// outlets
    @IBOutlet weak var messageLabel: UILabel!
    
    var connectionName: String!
    var callback: (()->())!
    
    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    /// Update UI
    private func updateUI() {
        messageLabel.text = "\(connectionName ?? "-") wants to connect with you."
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
