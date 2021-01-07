//
//  ConnectionInfoViewController.swift
//  EvernymApp
//
//  Created by Volkov Alexander on 1/7/21.
//  Copyright © 2021 Volkov Alexander. All rights reserved.
//

import UIKit
import SwiftEx83
import SwiftyJSON

class ConnectionInfoViewController: UIViewController {

    /// outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var remoteIconView: UIImageView!
    @IBOutlet weak var currentIconView: UIImageView!
    @IBOutlet weak var remoteDidLabel: UILabel!
    @IBOutlet weak var currentDidLabel: UILabel!
    
    var item: Connection!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.darkGray.alpha(alpha: 0.9)
        remoteIconView.round()
        currentIconView.round()
        updateUI()
    }
    
    /// Update UI
    private func updateUI() {
        remoteIconView.image = item.type.icon
        remoteIconView.backgroundColor = item.type.color
        remoteDidLabel.text = item.didRemote ?? "<not defined>"
        currentDidLabel.text = item.didCurrent ?? "<not defined>"
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        closeDialog()
    }
    
    @IBAction func deleteConnectionAction(_ sender: Any) {
        let this = self
        API.delete(connection: item)
            .addActivityIndicator(on: UIViewController.getCurrentViewController() ?? self)
            .subscribe(onNext: { value in
                this.dismissViewControllerToSide(this, side: .bottom, {
                    (Current as? UINavigationController ?? Current?.navigationController)?.popViewController(animated: true)
                })
                return
                }, onError: { _ in
            }).disposed(by: rx.disposeBag)
    }
    
    private func closeDialog() {
        self.dismissViewControllerToSide(self, side: .bottom, nil)
    }
}
