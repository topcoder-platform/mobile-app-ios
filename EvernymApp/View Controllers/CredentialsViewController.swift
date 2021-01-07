//
//  CredentialsViewController.swift
//  EvernymApp
//
//  Created by Volkov Alexander on 12/27/20.
//  Copyright © 2020 Volkov Alexander. All rights reserved.
//

import UIKit

class CredentialsViewController: UIViewController {

    /// outlets
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initEmptyScreen()
    }
    
    private func initEmptyScreen() {
        guard let vc = create(EmptyInfoViewController.self) else { return }
        vc.info = EmptyInfo(title: "No Credentials yet!", subtitle: "Want to see how it works?", text: "We have setup an optional tutorial site for you to go through using this Topcoder wallet app. To start this process, go to wallet.topcoder.com in a desktop browser and click Start Tutorial. ", icon: UIImage(named: "empty2"))
        loadViewController(vc, self.view)
//        table.noDataLabel = vc.view
    }

    @IBAction func simulateCredentialsAction(_ sender: Any) {
        guard let vc = create(IncomingRequestViewController.self) else { return }
        vc.type = .credentials
        vc.account = "sample_account"
        guard let parent = Current else { return }
        parent.showViewControllerFromSide(vc, inContainer: parent.view, bounds: parent.view.bounds, side: .bottom, nil)
    }
    
    @IBAction func simulateProofsAction(_ sender: Any) {
        guard let vc = create(IncomingRequestViewController.self) else { return }
        vc.type = .proof
        guard let parent = Current else { return }
        vc.account = "sample_account"
        parent.showViewControllerFromSide(vc, inContainer: parent.view, bounds: parent.view.bounds, side: .bottom, nil)
    }
}
