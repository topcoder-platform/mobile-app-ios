//
//  CredentialDetailsViewController.swift
//  EvernymApp
//
//  Created by Volkov Alexander on 6/1/21.
//  Copyright © 2021 Volkov Alexander. All rights reserved.
//

import UIKit
import SwiftEx83
import SwiftyJSON
import Combine

class CredentialDetailsViewController: UIViewController {

    /// outlets
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var actionLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    @IBOutlet weak var revokeButton: UIButton!
    
    @IBOutlet weak var credDefJsonTextView: UITextView!
    @IBOutlet weak var credDefJsonHeight: NSLayoutConstraint!
    @IBOutlet weak var refMetaTextView: UITextView!
    @IBOutlet weak var refMetaHeight: NSLayoutConstraint!
    
    var item: CredentialsInfo!
    private let type: IncomingRequestViewController.RequestType = .credentials
    
    /// the table model
    private var table = InfiniteTableViewModel<InfoItem, InfoItemCell>()
    
    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()
        
        infoView.layer.borderWidth = 1
        infoView.layer.borderColor = UIColor(0xAAAAAA).cgColor
        iconView.round()
        
        table.configureCell = { indexPath, item, _, cell in
            cell.configure(item)
        }
        table.onSelect = { _, item in
        }
        table.loadItems = { [weak self] callback, failure in
            guard self != nil else { return }
            var list = [InfoItem]()
            for (k,v) in self?.item.offer.arrayValue.first?["credential_attrs"].dictionaryValue ?? [:] {
                list.append(InfoItem(title: k, value: v.stringValue))
            }
            callback(list)
        }
        table.tableHeight = self.tableHeight
        table.bindData(to: tableView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateUI()
    }
    
    /// Update UI
    private func updateUI() {
        nameLabel.text = item.connection.name
        actionLabel.text = self.type.by
        infoLabel.text = item.offer.arrayValue.first?["comment"].stringValue
        infoLabel?.superview?.isHidden = (infoLabel.text ?? "").isEmpty
        
        // Creds details
        let credJson = JSON(parseJSON: item.serializedCredentials ?? "")
        if let str = credJson["data"]["holder_sm"]["state"]["RequestSent"]["cred_def_json"].string {
            credDefJsonTextView.text = str
        }
        else {
            credDefJsonTextView.text = "-"
        }
        credDefJsonHeight.constant = credDefJsonTextView.sizeThatFits(credDefJsonTextView.bounds.size).height
        
        if let str = credJson["data"]["holder_sm"]["state"]["RequestSent"]["req_meta"].string {
            refMetaTextView.text = str
        }
        else {
            refMetaTextView.text = "-"
        }
        refMetaHeight.constant = refMetaTextView.sizeThatFits(refMetaTextView.bounds.size).height
        
        revokeButton.isHidden = true
    }


}
