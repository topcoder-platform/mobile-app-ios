//
//  WebViewController.swift
//  EvernymApp
//
//  Created by Volkov Alexander on 2/9/21.
//  Copyright © 2021 Volkov Alexander. All rights reserved.
//

import UIKit
import WebKit
import SwiftEx83

/// Web view
class WebViewController: UIViewController {

    /// outlets
    @IBOutlet weak var webView: WKWebView!
    
    var urlString: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadData()
    }

    /// Load data
    private func loadData() {
        guard let url = URL(string: urlString ?? "") else { print("ERROR: incorrect URL: \(String(describing: urlString))"); return }
        self.webView.load(URLRequest(url: url))
    }
}
