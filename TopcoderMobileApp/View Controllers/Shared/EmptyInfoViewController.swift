//
//  EmptyInfoViewController.swift
// TopcoderMobileApp
//
//  Created by Volkov Alexander on 12/26/20.
//  Copyright © 2020 Volkov Alexander. All rights reserved.
//

import UIKit

struct EmptyInfo {
    let title: String
    let subtitle: String
    let text: String
    let icon: UIImage?
}

/// Screen shown when no data
class EmptyInfoViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var iconVIew: UIImageView!
    
    var info: EmptyInfo!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleLabel.text = info.title.uppercased()
        subtitleLabel.text = info.subtitle
        textLabel.text = info.text
        textLabel.setLineSpacing(lineSpacing: 7)
        if let image = info.icon {
            iconVIew.image = image
        }
    }
    
}
