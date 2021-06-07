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
import Combine

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
    
    enum RequestType: String {
        case proof = "PROOF?", credentials = "CRED_OFFER"
        
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
    var offer: Offer!
    var connection: Connection!
    
    var account: String = ""
    var json: JSON = JSON(parseJSON:
"""
[
{
"updatedAt": "2020-12-24T02:41:00.174Z",
"credential_attrs": {
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
]
"""
    )
    
    /// the table model
    private var table = InfiniteTableViewModel<InfoItem, InfoItemCell>()
    private var cancellable: AnyCancellable?
    
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
            for (k,v) in self?.json.arrayValue.first?["credential_attrs"].dictionaryValue ?? [:] {
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
        nameLabel.text = connection.name
        actionLabel.text = type.by
        infoLabel.text = json.arrayValue.first?["comment"].stringValue
        infoLabel?.superview?.isHidden = (infoLabel.text ?? "").isEmpty
        cancelButton.setTitle(type.cancelButton, for: .normal)
        acceptButton.setTitle(type.acceptButton, for: .normal)
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        closeDialog()
    }
    
    @IBAction func acceptAction(_ sender: Any) {
        if type == .credentials {
            acceptCredentials(offer: offer, connection: connection)
        }
        else {
            showStub()
        }
    }
    
    private func closeDialog() {
        self.dismissViewControllerToSide(self, side: .bottom, nil)
    }
    
    private func acceptCredentials(offer: Offer, connection: Connection) {
        guard let serializedConnection = connection.serializedConnection else { return }
        print("CHECKING CREDENTIALS...")
        
        let util = VcxUtil.shared
        var connectionHandle: Int!
        var credentialHandle: Int!
        var credentialInfo: CredentialsInfo!
        
        let loadingIndicator = ActivityIndicator(parentView: nil).start()
        
        print("Checking offers for: \(connection.info)...")
        // Deserialize a saved connection
        var cancellable: AnyCancellable?
        cancellable = util.connectionDeserialize(serializedConnection: serializedConnection)
        .flatMap({ handle -> Future<Int, Error> in
            connectionHandle = handle
            // Create a credential object from the credential offer
            print("Processing an offer: \(offer)...")
            return util.credentialCreateWithOffer(sourceId: "1", credentialOffer: offer.rawString() ?? "")
        })
        .map { handle in
            credentialHandle = handle
        }
        .flatMap({ Void -> Future<Int, Error> in
            //            print("Getting credentials...")
            //            return util.getCredentials(credentialHandle: credentialHandle)
            print("Get credential state (1)...")
            return util.credentialGetState(credentialHandle: credentialHandle)
        })
        .map { state in
            print("Credentials State BEFORE: \(state)") // should be 3
        }
        .flatMap({
            // Send a credential request (accepts credentials)
            util.credentialSendRequest(credentialHandle: credentialHandle, connectionHandle: connectionHandle, paymentHandle: 0)
        })
        .map { _ in
            sleep(4)
        }
        .flatMap({ Void -> Future<Int, Error> in
//            print("Getting credentials...")
//            return util.getCredentials(credentialHandle: credentialHandle)
            print("Get credential state (2)...")
            return util.credentialGetState(credentialHandle: credentialHandle)
        })
        .flatMap({ state -> Future<String?, Error> in
            print("Credentials State AFTER: \(state)") // should be 2
            
//            print("Getting credentials...")
//            return util.getCredentials(credentialHandle: credentialHandle)
//        })
//        .flatMap({ creds -> Future<String?, Error> in
//            print("Credentials: \(String(describing: creds))")
//            credentialsObject = creds
            print("Serializing credentials...")
            return util.credentialSerialize(credentialHandle: credentialHandle)
        })
        .map { serializedCredentials in
            print("Serialized Credentials: \(String(describing: serializedCredentials))")
            credentialInfo = CredentialsInfo(offer: offer,
                                             serializedCredentials: serializedCredentials,
                                             connection: connection)
                // Release vcx objects from memory
                    util.connectionRelease(handle: connectionHandle)
                _ = util.credentialRelease(credentialHandle: credentialHandle)
        }
//        .map { state in
//            print("Credentials State AFTER: \(state)") // should be 2
//            // Release vcx objects from memory
//            _ = util.connectionRelease(handle: connectionHandle)
//            _ = util.credentialRelease(credentialHandle: credentialHandle)
//        }
        .sink(receiveCompletion: { [weak self] completion in
            guard self != nil else { return }
            
            switch completion {
            case .finished:
                
                // Store credentials
                API.add(credentials: credentialInfo)
                    .subscribe(onNext: { [weak self] value in
                        loadingIndicator.stop()
                        
                        self?.showAlert("Success", "Credential offer accepted") {
                            self?.closeDialog()
                        }
                        
                        return
                        }, onError: { _ in
                    }).disposed(by: self!.rx.disposeBag)
                
            case .failure(let error):
                loadingIndicator.stop()
                showError(errorMessage: error.localizedDescription)
            }
            }, receiveValue: { _ in })
        self.cancellable = cancellable
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

