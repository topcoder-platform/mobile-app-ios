//
//  WebViewController.swift
// TopcoderMobileApp
//
//  Created by Volkov Alexander on 2/9/21.
//  Copyright © 2021 Volkov Alexander. All rights reserved.
//

import UIKit
import WebKit
import SwiftEx83
import Amplify

/// Web view
class WebViewController: UIViewController, WKUIDelegate, WKNavigationDelegate {

    /// outlets
    @IBOutlet weak var webView: WKWebView!
    
    var urlString: String = Configuration.urlLogin
    
    private var initialOpening: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        webView.uiDelegate = self
        webView.navigationDelegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if initialOpening {
            initialOpening = false
            loadData()
        }
    }

    /// Load data
    private func loadData() {
        guard let url = URL(string: urlString) else { print("ERROR: incorrect URL: \(String(describing: urlString))"); return }
        self.webView.load(URLRequest(url: url))
    }
    
    // Clean cookies
    private func cleanUpCookies() {
        /// old API cookies
        for cookie in HTTPCookieStorage.shared.cookies ?? [] {
            HTTPCookieStorage.shared.deleteCookie(cookie)
        }
        /// URL cache
        URLCache.shared.removeAllCachedResponses()
        /// WebKit cache
        let date = Date(timeIntervalSince1970: 0)
        WKWebsiteDataStore.default().removeData(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes(), modifiedSince: date, completionHandler:{ })
    }
    
    // MARK: -
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let url = navigationAction.request.url?.absoluteString ?? ""
        if url != "about:blank" {
            print("navigationAction URL: \(url)")
        }
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, preferences: WKWebpagePreferences, decisionHandler: @escaping (WKNavigationActionPolicy, WKWebpagePreferences) -> Void) {
        let url = navigationAction.request.url?.absoluteString ?? ""
        
        // Ignore "about:blank"
        if url != "about:blank" {
            print("navigationAction URL (preferences): \(url)")
        }
        
        // Log events
        
        if tryLogUrlEvent(url) {
            // URL recognized
        }
        else if url.contains("addthis.com") {
            let urlFixed = url.replace("#rand=", withString: "?rand=")
            let params = URL(string: urlFixed)?.queryParameters ?? [:]
            if let href = params["href"] {
                tryLogUrlEvent(href)
            }
        }
        decisionHandler(.allow, preferences)
    }
    
    @discardableResult
    private func tryLogUrlEvent(_ url: String) -> Bool {
        var props: AnalyticsProperties?
        if url.hasPrefix(Configuration.urlChallenges + "/") {
            let id = String(url.split(separator: "/").last ?? "")
            props = ["event_action": "navigation", "url": url, "target": "Challenge Details", "challenge_id": id]
        }
        else if url == Configuration.urlChallenges {
            props = ["event_action": "navigation", "url": url, "target": "Challenges"]
        }
        else {
            return false
        }
        if let props = props {
            Amplify.Analytics.tryRecord(event: BasicAnalyticsEvent(name: "Embeded Web", properties: props))
        }
        return true
    }
}
