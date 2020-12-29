//
//  ConnectionsViewController.swift
//  EvernymApp
//
//  Created by Volkov Alexander on 12/27/20.
//  Copyright © 2020 Volkov Alexander. All rights reserved.
//

import UIKit
import SwiftEx83
import QRCodeScanner83
import Combine
import SwiftyJSON

var simulateConnectionAddedComplete = false

class ConnectionsViewController: UIViewController {

    /// outlets
    @IBOutlet weak var tableView: UITableView!
    
    /// the table model
    private var table = InfiniteTableViewModel<Connection, ConnectionCell>()

    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initEmptyScreen()
        table.configureCell = { [weak self] indexPath, item, _, cell in
            cell.parent = self
            cell.configure(item)
        }
        table.onSelect = { [weak self] _, item in
            self?.openDetails(item)
        }
        table.loadItems = { [weak self] callback, failure in
            guard self != nil else { return }
            API.getConnections()
                .subscribe(onNext: { value in
                    DispatchQueue.main.async {
                        callback(value)
                    }
                    return
                }, onError: { error in
                    failure(error.localizedDescription)
                }).disposed(by: self!.rx.disposeBag)
        }
        table.bindData(to: tableView)
        updateUI()
        
        NotificationCenter.add(observer: self, selector: #selector(notificationHandler(_:)), name: UIEvents.connectionUpdate)
        NotificationCenter.add(observer: self, selector: #selector(notificationHandler(_:)), name: SdkEvent.ready)
        
        simulateConnectionAdded()
    }
    
    private func simulateConnectionAdded() {
        guard !simulateConnectionAddedComplete else { return }
        simulateConnectionAddedComplete = true
        delay(2) { [weak self] in
            self?.showAlert("", "Connection creation will be simulated in a second") { [weak self] in
                
                guard let vc = self?.create(NewConnectionViewController.self) else { return }
                vc.connectionName = "justin_phone"
                vc.callback = { [weak self] in
                    self?.addConnection(connection: Connection(relation: "justin_phone", info: "You shared proof01 with justin_phone.", date: Date(), serializedConnection: nil))
                }
                self?.present(vc, animated: true, completion: nil)
            }
        }
    }
    
    @objc func notificationHandler(_ notification: UIKit.Notification) {
        if notification.name.rawValue == SdkEvent.ready.rawValue {
            delay(0.1) { [weak self] in
                self?.updateUI()
            }
        }
        else if notification.name.rawValue == UIEvents.connectionUpdate.rawValue {
            DispatchQueue.main.async { [weak self] in
                self?.table.loadData()
            }
        }
    }
    
    private func updateUI() {
        // TODO uncomment after issue with VCX initialization is fixed
//        navigationItem.rightBarButtonItem?.isEnabled = AppDelegate.shared.sdkInited
        navigationItem.rightBarButtonItem?.tintColor = AppDelegate.shared.sdkInited ? UIColor(named: "green")! : UIColor.red
    }
    
    private func initEmptyScreen() {
        guard let vc = create(EmptyInfoViewController.self) else { return }
        vc.info = EmptyInfo(title: "You now have a digital wallet!", subtitle: "Want to see how it works?", text: "We have setup an optional tutorial site...")
        loadViewController(vc, self.view)
        table.noDataLabel = vc.view
        vc.view.superview?.sendSubviewToBack(vc.view)
    }
    
    @IBAction func scanConnection(_ sender: Any) {
        // Open scanner
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CodeScannerViewController") as? CodeScannerViewController else {
            return
        }
        vc.callbackCodeScanned = { code in
            vc.dismiss(animated: true, completion: { [weak self] in
                self?.process(code: code)
            })
        }
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    // MARK: - VCX
    
    /// Process invitation URL provided as QR code
    /// - Parameter code: the code
    private func process(code: String) {
        print("SCANNED CODE: \(code)")
        guard let url = URL(string: code) else { return }
        print("GETTING INVITATION...")
        RestServiceApi.getInvitation(url: url)
            .addActivityIndicator(on: UIViewController.getCurrentViewController() ?? self)
            .subscribe(onNext: { [weak self] value in
                print("INVITAION:\n\(value)")
                
                // Show invitation to user
                self?.showInvitation(invitation: value)
                
                return
                }, onError: { _ in
            }).disposed(by: rx.disposeBag)
    }
    
    fileprivate func openDetails(_ item: Connection) {
        guard let vc = create(ConnectionDetailsViewController.self) else { return }
        vc.item = item
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

/// Cell for table in this view controller
class ConnectionCell: UITableViewCell {
    
    /// outlets
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var infoLabel: UILabel?
    @IBOutlet weak var dateLabel: UILabel?
    
    /// the related item
    private var item: Connection!
    
    fileprivate weak var parent: ConnectionsViewController!
    
    /// Setup UI
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
    
    /// Update UI with given data
    ///
    /// - Parameters:
    ///   - item: the data to show in the cell
    func configure(_ item: Connection) {
        self.item = item
        titleLabel?.text = item.relation
        infoLabel?.text = item.info
        dateLabel?.text = Date.shortDate.string(from: item.date)
    }
    
    @IBAction func buttonAction(_ sender: Any) {
        parent?.openDetails(item)
    }
}

