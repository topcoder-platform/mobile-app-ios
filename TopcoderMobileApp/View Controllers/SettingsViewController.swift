//
//  SettingsViewController.swift
// TopcoderMobileApp
//
//  Created by Volkov Alexander on 12/27/20.
//  Copyright © 2020 Volkov Alexander. All rights reserved.
//

import UIKit
import SwiftEx83

struct SettingsItem {

    enum `Type` {
        case `switch`, disclosure
    }
    
    enum SettingsType {
        case biometrics, passcode, feedback, about
    }
    
    let icon: UIImage
    let title: String
    let subtitle: String
    let type: Type
    let settings: SettingsType
}

/// Settings screen
class SettingsViewController: UIViewController {

    /// outlets
    @IBOutlet weak var tableView: UITableView!
    
    /// the table model
    private var table = InfiniteTableViewModel<SettingsItem, SettingsItemCell>()
    
    private var items: [SettingsItem] = []
    
    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDefaultNavigationBar()
        table.showLoadingIndicator = false
        table.configureCell = { indexPath, item, _, cell in
            cell.configure(item, isSelected: UserDefaults.useBiometrics)
            cell.parent = self
        }
        table.onSelect = { [weak self] indexPath, item in
            switch item.settings {
            case .biometrics: break
            case .passcode:
                guard let vc = self?.create(AuthenticationViewController.self) else { return }
                vc.type = .settings
                self?.navigationController?.pushViewController(vc, animated: true)
            case .feedback:
                showStub()
            case .about:
                showStub()
            }
        }
        table.loadItems = { [weak self] callback, failure in
            guard self != nil else { return }
            callback(self?.items ?? [])
        }
        table.bindData(to: tableView)
        tableView.isScrollEnabled = false
        loadData()
    }
    
    private func loadData() {
        items = [
            SettingsItem(icon: UIImage(named: "s1")!, title: "Biometrics", subtitle: "Use your finger or face to secure app", type: .switch, settings: .biometrics),
            SettingsItem(icon: UIImage(named: "s2")!, title: "Passcode", subtitle: "Use your finger or face to secure app", type: .disclosure, settings: .passcode),
            SettingsItem(icon: UIImage(named: "s3")!, title: "Give app feedback", subtitle: "Tell us what you think of Topcoder.Connect", type: .disclosure, settings: .feedback),
            SettingsItem(icon: UIImage(named: "s4")!, title: "About", subtitle: "Legal, Version and Network Information", type: .disclosure, settings: .about),
        ]
        table.loadData()
    }
    
    fileprivate func `switch`(on: Bool, item: SettingsItem) {
        if item.settings == .biometrics {
            LocalAuthenticationUtil.shared.setup(on: on) { [weak self] (success, error) in
                DispatchQueue.main.async {
                    if success != on { // if failed, then UISwitch state does not match the actual result - reload to update
                        self?.loadData()
                    }
                    if let error = error {
                        showError(errorMessage: error.localizedDescription)
                    }
                }
            }
        }
    }
}

/// Cell for table in this view controller
class SettingsItemCell: UITableViewCell {
    
    /// outlets
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var `switch`: UISwitch!
    @IBOutlet weak var iconDisclosure: UIImageView!
    
    /// the related item
    private var item: SettingsItem!
    fileprivate weak var parent: SettingsViewController!
    
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
    func configure(_ item: SettingsItem, isSelected: Bool) {
        self.item = item
        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
        self.iconView.image = item.icon
        
        `switch`.isHidden = item.type != .switch
        iconDisclosure.isHidden = item.type != .disclosure
        if item.type == .switch {
            `switch`.isOn = isSelected
        }
    }
    
    @IBAction func switchAction(_ sender: UISwitch) {
        DispatchQueue.main.async { [weak self] in
            self?.parent.switch(on: sender.isOn, item: self!.item)
        }
    }
}

