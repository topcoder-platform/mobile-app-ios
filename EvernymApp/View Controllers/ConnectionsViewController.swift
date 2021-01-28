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
    @IBOutlet weak var collectionView: UICollectionView!
    
    /// collection data source
    private var dataSource: CollectionDataModel<ConnectionCell>!
    
    private weak var noDataLabel: UIView!

    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initEmptyScreen()
        dataSource = CollectionDataModel(collectionView, cellClass: ConnectionCell.self) { [weak self] (item, indexPath, cell) in
            guard self != nil else { return }
            let item = item as! Connection
            cell.configure(item)
        }
        dataSource.calculateCellSize = { [weak self]  item, _ -> CGSize in
            guard self != nil else { return .zero }
            let width = self!.collectionView.cellWidth(forColumns: 2)
            let height = width + 26
            return CGSize(width: width, height: height)
        }
        dataSource.selected = { [weak self] item, indexPath in
            let item = item as! Connection
            self?.openDetails(item)
        }
        
        updateUI()
        
        NotificationCenter.add(observer: self, selector: #selector(notificationHandler(_:)), name: UIEvents.connectionUpdate)
        NotificationCenter.add(observer: self, selector: #selector(notificationHandler(_:)), name: SdkEvent.ready)
        
        simulateConnectionAdded()
        
    }
    /// Load data
    private func loadData() {
        API.getConnections()
            .subscribe(onNext: { [weak self] value in
                DispatchQueue.main.async {
                    self?.dataSource.setItems(value)
                    self?.noDataLabel?.isHidden = value.isEmpty
                }
                return
            }, onError: { error in
                showError(errorMessage: error.localizedDescription)
                return
            }).disposed(by: self.rx.disposeBag)
    }
    
    private func simulateConnectionAdded() {
        guard !simulateConnectionAddedComplete else { return }
        simulateConnectionAddedComplete = true
        delay(0) { [weak self] in
            self?.showAlert("", "Connection creation will be simulated in a second") { [weak self] in
                
                guard let vc = self?.create(NewConnectionViewController.self) else { return }
                vc.connection = Connection(relation: "justin_phone", info: "", date: Date(), serializedConnection: nil)
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
                self?.loadData()
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
        vc.info = EmptyInfo(title: "You now have a digital wallet!", subtitle: "Want to see how it works?", text: "We have setup an optional tutorial site...", icon: nil)
        loadViewController(vc, self.view)
        noDataLabel = vc.view
        vc.view.superview?.sendSubviewToBack(vc.view)
    }
    
    @IBAction func scanConnection(_ sender: Any) {
        // Open scanner
        guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CodeScannerViewController") as? CodeScannerViewController else {
            return
        }
        if let button = vc.view.subviews.filter({$0.tag == 1}).first as? UIButton {
            button.addTarget(self, action: #selector(closeCodeScanner), for: .touchUpInside)
        }
        vc.callbackCodeScanned = { code in
            vc.dismiss(animated: true, completion: { [weak self] in
                self?.process(code: code)
            })
        }
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc func closeCodeScanner() {
        (UIViewController.getCurrentViewController() as? CodeScannerViewController)?.dismiss(animated: true, completion: nil)
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

/// Cell for the collection in this screen
class ConnectionCell: UICollectionViewCell {
    
    /// outlets
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel?
    
    /// the related item
    private var item: Connection!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        iconView.roundCorners(8)
    }
    
    /// Update UI with given data
    ///
    /// - Parameters:
    ///   - item: the data to show in the cell
    func configure(_ item: Connection) {
        self.item = item
        titleLabel?.text = item.relation
        iconView?.image = item.type.icon
        iconView.backgroundColor = item.type.color
    }
}
