//
//  ConnectionDetailsViewController.swift
//  EvernymApp
//
//  Created by Volkov Alexander on 12/27/20.
//  Copyright © 2020 Volkov Alexander. All rights reserved.
//

import UIKit

class ConnectionDetailsViewController: UIViewController {

    /// outlets
    @IBOutlet weak var didRemote: UILabel!
    @IBOutlet weak var didCurrent: UILabel!
    
    var item: Connection!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = UIColor.systemOrange
        updateUI()
    }
    
    private func updateUI() {
        title = item.relation
        didRemote.text = item.didRemote ?? "<not defined>"
        didCurrent.text = item.didCurrent ?? "<not defined>"
    }
    
    @IBAction func deleteAction(_ sender: Any) {
        API.delete(connection: item)
            .addActivityIndicator(on: UIViewController.getCurrentViewController() ?? self)
            .subscribe(onNext: { [weak self] value in
                self?.navigationController?.popViewController(animated: true)
            return
            }, onError: { _ in
        }).disposed(by: rx.disposeBag)
    }
    
}
