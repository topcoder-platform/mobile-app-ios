//
//  CredentialsViewController.swift
//  EvernymApp
//
//  Created by Volkov Alexander on 12/27/20.
//  Copyright © 2020 Volkov Alexander. All rights reserved.
//

import UIKit
import SwiftEx83
import MobileWallet
import Combine
import SwiftyJSON

typealias Offer = JSON

class CredentialsViewController: AbstractViewController {

    /// outlets
    @IBOutlet weak var tableView: UITableView!
    
    private var loadingIndicator: ActivityIndicator? // also a flag of loading process (if not nil, then loading in progress)
    private var cancellables = [AnyCancellable]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initEmptyScreen()
        
        navigationItem.rightBarButtonItems?.removeAll()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadCredentialOffers()
    }
    
    /// Reload when initialization complete
    override func initializationComplete() {
        super.initializationComplete()
        loadCredentialOffers()
    }
    
    private func initEmptyScreen() {
        guard let vc = create(EmptyInfoViewController.self) else { return }
        vc.info = EmptyInfo(title: "No Credentials yet!", subtitle: "Want to see how it works?", text: "We have setup an optional tutorial site for you to go through using this Topcoder wallet app. To start this process, go to wallet.topcoder.com in a desktop browser and click Start Tutorial. ", icon: UIImage(named: "empty2"))
        loadViewController(vc, self.view)
//        table.noDataLabel = vc.view
        vc.view.superview?.sendSubviewToBack(vc.view)
    }
    
    private func loadCredentialOffers() {
        guard loadingIndicator == nil else { print("loadCredentialOffers: Skipping. Already loading"); return }
        guard CMConfig.shared.sdkInited else { return }
        self.loadingIndicator = ActivityIndicator(parentView: nil).start()
        API.getConnections()
            .subscribe(onNext: { [weak self] value in
                let g = DispatchGroup()
                var offsetShown = false
                self?.cancellables.removeAll()
                for c in value {
                    g.enter()
                    if let o = self?.loadCredentialOffers(for: c, callback: { offers in
                        for offer in offers {
                            if !offsetShown {
                                // TODO uncomment to filter some offers by `name`
//                                if offer.arrayValue.first?["credential_attrs"]["name"] != "YOUR_NAME" {
                                    offsetShown = true
                                    UIViewController.showOffer(offer, from: c)
//                                }
                            }
                        }
                        g.leave()
                    }) {
                        self?.cancellables.append(o)
                    }
                }
                g.notify(queue: .main) {
                    self?.loadingIndicator?.stop()
                    self?.loadingIndicator = nil
                    self?.cancellables.removeAll()
                }
                return
                }, onError: { _ in
            }).disposed(by: rx.disposeBag)
    }
    
    private func loadCredentialOffers(for connection: Connection, callback: @escaping ([Offer])->()) -> AnyCancellable? {
        guard let serializedConnection = connection.serializedConnection else { return nil }
        print("CHECKING CREDENTIALS...")
        
        let util = VcxUtil.shared
        var connectionHandle: Int!
        
        print("Checking offers for: \(connection.info)...")
        // Deserialize a saved connection
        var cancellable: AnyCancellable?
        cancellable = util.connectionDeserialize(serializedConnection: serializedConnection)
            .map { handle in
                connectionHandle = handle
        }
        .flatMap({
            // Check agency for a credential offers
            util.credentialGetOffers(connectionHandle: connectionHandle)
        })
        .map { offers -> String in
            let json = JSON(parseJSON: offers) // Parse offers
            print("Credential offers: ", json)
            callback(json.arrayValue)
            return ""
        }
        .map { _ in
            // Release vcx objects from memory
            _ = util.connectionRelease(handle: connectionHandle)
        }
        .sink(receiveCompletion: { completion in
            switch completion {
            case .finished: break
            case .failure(let error): fatalError(error.localizedDescription)
            }
            }, receiveValue: { _ in })
        return cancellable
    }
    // MARK: - Button actions

    @IBAction func simulateCredentialsAction(_ sender: Any) {
        guard loadingIndicator == nil else { print("loadCredentialOffers: Skipping. Already loading"); return }
        guard let vc = create(IncomingRequestViewController.self) else { return }
        vc.type = .credentials
        vc.account = "sample_account"
        guard let parent = Current else { return }
        parent.showViewControllerFromSide(vc, inContainer: parent.view, bounds: parent.view.bounds, side: .bottom, nil)
    }
    
    @IBAction func simulateProofsAction(_ sender: Any) {
        guard loadingIndicator == nil else { print("loadCredentialOffers: Skipping. Already loading"); return }
        guard let vc = create(IncomingRequestViewController.self) else { return }
        vc.type = .proof
        guard let parent = Current else { return }
        vc.account = "sample_account"
        parent.showViewControllerFromSide(vc, inContainer: parent.view, bounds: parent.view.bounds, side: .bottom, nil)
    }
}

extension UIViewController {
    
    /// Shows offer to the user for acceptance
    /// - Parameters:
    ///   - offer: the offer
    ///   - connection: the connection
    static func showOffer(_ offer: Offer, from connection: Connection) {
        print("OFFER: \(offer)")
        
        let type = IncomingRequestViewController.RequestType(rawValue: offer["msg_type"].stringValue) ?? .credentials
        
        // Show to the user
        guard let vc = Current?.create(IncomingRequestViewController.self) else { return }
        vc.type = type
        
        // Save for later
        vc.offer = offer
        vc.connection = connection
        
        vc.json = offer
        vc.account = connection.info
        guard let parent = Current else { return }
        parent.showViewControllerFromSide(vc, inContainer: parent.view, bounds: parent.view.bounds, side: .bottom, nil)
    }
}
