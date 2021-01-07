//
//  ConnectionDetailsViewController.swift
//  EvernymApp
//
//  Created by Volkov Alexander on 12/27/20.
//  Copyright © 2020 Volkov Alexander. All rights reserved.
//

import UIKit
import SwiftEx83

struct ConnectionState {
    
    let title: String
    let subtitle: String
    let date: Date
    let inProgress: Bool
}

class ConnectionDetailsViewController: UIViewController {

    /// outlets
    @IBOutlet weak var tableView: UITableView!
    
    var item: Connection!
    
    /// the table model
    private var table = SectionInfiniteTableViewModel<ConnectionState, ConnectionStateInfoCell, ConnectionStateInfoSection>()
    
    private var items = [ConnectionState]()
        
    /// Setup UI
    override func viewDidLoad() {
        super.viewDidLoad()
        table.configureCell = { indexPath, item, _, cell in
            cell.configure(item)
        }
        table.configureHeader = { index, item, section in
            section.dateLabel.text = item.uppercased()
        }
        table.sectionHeaderHeight = 44
        table.onSelect = { indexPath, item in
        }
        table.loadSectionItems = { [weak self] callback, failure in
            guard self != nil else { return }
            let data = self!.prepareData(self!.items)
            callback(data.0, data.1)
        }
        table.bindData(to: tableView)
        updateUI()
        loadData()
    }
    
    private func updateUI() {
        title = item.relation.uppercased()
    }
    
    private func loadData() {
        items = [ConnectionState(title: item.relation, subtitle: item.info, date: item.date, inProgress: true)]
        table.loadData()
    }
    
    private func prepareData(_ list: [ConnectionState]) -> ([[ConnectionState]], [String]) {
        var map = [String: [ConnectionState]]()
        for item in list {
            let date = Date.connectionStateDateTime.string(from: item.date)
            var group = map[date]
            if group == nil {
                group = [ConnectionState]()
            }
            group!.append(item)
            map[date] = group
        }
        var items = [(String, [ConnectionState])]()
        for (k,v) in map {
            items.append((k, v))
        }
        items = items.sorted { (a1, a2) -> Bool in
            return a1.0 < a2.0
        }
        var titles = [String]()
        var states = [[ConnectionState]]()
        for item in items {
            titles.append(item.0)
            states.append(item.1)
        }
        return (states, titles)
    }
    
    @IBAction func detailsAction(_ sender: Any) {
        guard let vc = create(ConnectionInfoViewController.self) else { return }
        vc.item = item
        guard let parent = Current else { return }
        parent.showViewControllerFromSide(vc, inContainer: parent.view, bounds: parent.view.bounds, side: .bottom, nil)
    }
    
}

/// Cell for table in this view controller
class ConnectionStateInfoCell: UITableViewCell {
    
    /// outlets
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var mainLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    /// the related item
    private var item: ConnectionState!
    
    /// Setup UI
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        loadingIndicator.startAnimating()
    }
    
    /// Update UI with given data
    ///
    /// - Parameters:
    ///   - item: the data to show in the cell
    func configure(_ item: ConnectionState) {
        self.item = item
        mainLabel.text = item.title
        subtitleLabel.text = item.subtitle
        loadingIndicator.isHidden = !item.inProgress
        
    }
}

class ConnectionStateInfoSection: UITableViewHeaderFooterView {
    
    @IBOutlet weak var dateLabel: UILabel!
}
