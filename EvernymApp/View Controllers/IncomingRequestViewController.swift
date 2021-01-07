//
//  IncomingRequestViewController.swift
//  EvernymApp
//
//  Created by Volkov Alexander on 12/29/20.
//  Copyright © 2020 Volkov Alexander. All rights reserved.
//

import UIKit
import SwiftEx83
import SwiftyJSON

struct InfoItem {
    let title: String
    let value: String?
}

class IncomingRequestViewController: UIViewController {

    /// outlets
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var actionLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var acceptButton: UIButton!
    
    enum RequestType {
        case proof, credentials
        
        var title: String {
            switch self {
            case .proof: return "Proof Request"
            case .credentials: return "Credentials Offer"
            }
        }
        
        var by: String {
            switch self {
            case .proof: return "Requested by"
            case .credentials: return "Issued by"
            }
        }
        
        var cancelButton: String {
            switch self {
            case .proof: return "Reject"
            case .credentials: return "Reject"
            }
        }
        
        var acceptButton: String {
            switch self {
            case .proof: return "Share Attributes"
            case .credentials: return "Accept Credentials"
            }
        }
        
        var acceptButtonIcon: UIImage {
            switch self {
            case .proof: return #imageLiteral(resourceName: "16px_share-26")
            case .credentials: return UIImage(systemName: "square.and.arrow.down")!
            }
        }
    }
    
    var type: RequestType = .credentials
    
    var account: String = ""
    var json: JSON = JSON(parseJSON:
"""
{
"updatedAt": "2020-12-24T02:41:00.174Z",
"credentialData": {
"name": "Justin Test Credential",
"degree": "Bachelors"
},
"relDID": "LLZJknHYU5msAs6VEETeMF",
"status": "offered",
"createdAt": "2020-12-24T02:40:59.728Z",
"comment": "comment",
"definitionId": "277jR9Utv7FBU8H7xaC1i9:3:CL:166183:latest",
"threadId": "b22cb0d6-6b9e-4278-9797-2b0b20ebc46d",
"id": "b873c7c2-67cf-4b88-9455-7b38625f3b8b"
}
"""
    )
    
    /// the table model
    private var table = InfiniteTableViewModel<InfoItem, InfoItemCell>()
    
    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.darkGray.alpha(alpha: 0.9)
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
            for (k,v) in self?.json["credentialData"].dictionaryValue ?? [:] {
                list.append(InfoItem(title: k, value: v.stringValue))
            }
            callback(list)
        }
        table.bindData(to: tableView)
        updateUI()
    }
    
    /// Update UI
    private func updateUI() {
        titleLabel.text = type.title.uppercased()
        actionLabel.text = type.by
        infoLabel.text = json["comment"].stringValue
        cancelButton.setTitle(type.cancelButton, for: .normal)
        acceptButton.setTitle(type.acceptButton, for: .normal)
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        closeDialog()
    }
    
    @IBAction func acceptAction(_ sender: Any) {
        showStub()
    }
    
    private func closeDialog() {
        self.dismissViewControllerToSide(self, side: .bottom, nil)
    }
}

/// Cell for table in this view controller
class InfoItemCell: ClearCell {
    
    /// outlets
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    /// the related item
    private var item: InfoItem!
    
    /// Setup UI
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    /// Update UI with given data
    ///
    /// - Parameters:
    ///   - item: the data to show in the cell
    ///   - isSelected: true - if selected
    func configure(_ item: InfoItem) {
        self.item = item
        titleLabel.text = item.title
        valueLabel.text = item.value ?? "Not found"
        iconView.isHidden = item.value != nil
    }
}

