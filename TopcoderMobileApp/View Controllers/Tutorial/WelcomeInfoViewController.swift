//
//  WelcomeInfoViewController.swift
// TopcoderMobileApp
//
//  Created by Volkov Alexander on 2/9/21.
//  Copyright © 2021 Volkov Alexander. All rights reserved.
//

import UIKit

struct WelcomeInfo: Codable {
    
    let title: String
    let text: String
    let imageName: String
    
}

class WelcomeInfoViewController: UIViewController {

    /// outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    var callback: ((WelcomeInfo)->())?
    var prevCallback: (()->())?
    var nextCallback: (()->())?
    
    var item: WelcomeInfo!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    private func updateUI() {
        titleLabel.text = item.title
        textLabel.text = item.text
        imageView.image = UIImage(named: item.imageName)
    }
    
    @IBAction func playButtonAction(_ sender: Any) {
        DispatchQueue.main.async { [weak self] in
            guard self != nil else { return }
            self?.callback?(self!.item)
        }
    }
    
    @IBAction func swipeLeft(_ sender: Any) {
        nextCallback?()
    }
    
    @IBAction func swipeRight(_ sender: Any) {
        prevCallback?()
    }
}
