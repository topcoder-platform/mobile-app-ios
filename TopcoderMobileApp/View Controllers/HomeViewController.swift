//
//  HomeViewController.swift
// TopcoderMobileApp
//
//  Created by Volkov Alexander on 12/26/20.
//  Copyright © 2020 Volkov Alexander. All rights reserved.
//

import UIKit
import SwiftEx83

/// Home
class HomeViewController: UIViewController {

    /// outlets
    @IBOutlet weak var tableView: UITableView!
    
    /// the table model
    private var table = SectionInfiniteTableViewModel<Notification, NotificationCell, UITableViewHeaderFooterView>()
    
    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDefaultNavigationBar()
//        table.noDataLabel = noDataLabel
        table.configureCell = { indexPath, item, _, cell in
            cell.configure(item)
        }
        table.onSelect = { _, item in
        }
        table.loadSectionItems = { [weak self] callback, failure in
            guard self != nil else { return }
            API.getNotifications()
                .subscribe(onNext: { value in
                    let new = value.filter({$0.isNew})
                    let old = value.filter({!$0.isNew})
                    callback([new, old], ["", "Recent"])
                    return
                }, onError: { error in
                    failure(error.localizedDescription)
                }).disposed(by: self!.rx.disposeBag)
        }
        table.bindData(to: tableView)
        initEmptyScreen()
    }
    
    private func initEmptyScreen() {
        guard let vc = create(EmptyInfoViewController.self) else { return }
        vc.info = EmptyInfo(title: "You now have a digital wallet!", subtitle: "Want to see how it works?", text: "We have setup an optional tutorial site for you to go through using this Topcoder wallet app. To start this process, go to wallet.topcoder.com in a desktop browser and click Start Tutorial. ", icon: nil)
        loadViewController(vc, self.view)
        table.noDataLabel = vc.view
    }
}

/// Cell for table in this view controller
class NotificationCell: UITableViewCell {
    
    /// outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var relationLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    /// the related item
    private var item: Notification!
    
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
    func configure(_ item: Notification) {
        self.item = item
        titleLabel.text = item.title
        relationLabel.text = item.relation
        dateLabel.text = Date.shortDate.string(from: item.date)
    }
}

class MainNavigationViewController: UINavigationController {
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
}
