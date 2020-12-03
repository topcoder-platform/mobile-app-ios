//
//  UITableViewExtensions.swift
//  SwiftEx
//
//  Created by Alexander Volkov on 04/16/15.
//  Copyright © 2015-2019 Alexander Volkov. All rights reserved.
//

import UIKit

/**
 * Cell without margins and selection style.
 *
 * - author: Alexander Volkov
 * - version: 1.0
 */
open class ClearCell: UITableViewCell {

    /// separator inset fix
    override open var layoutMargins: UIEdgeInsets {
        get { return UIEdgeInsets.zero }
        set(newVal) {}
    }

    // Setup UI
    override open func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }
}

/**
 * Shortcut methods for UITableView
 *
 * - author: Alexander Volkov
 * - version: 1.0
 */
extension UITableView {

    /// Prepares tableView to have zero margins for separator and removes extra separators after all rows
    public func separatorFix() {
        let tableView = self
        if tableView.responds(to: #selector(setter: UITableViewCell.separatorInset)) {
            tableView.separatorInset = UIEdgeInsets.zero
        }
        if tableView.responds(to: #selector(setter: UIView.layoutMargins)) {
            tableView.layoutMargins = UIEdgeInsets.zero
        }

        // Remove extra separators after all rows
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }

    /// Set transparent background and separator
    public func transparentTable() {
        backgroundColor = .clear
        separatorStyle = .none
    }

    /// Register cell class for the table
    ///
    /// - Parameter cell: a cell class
    public func register(cell: UITableViewCell.Type) {
        let className = NSStringFromClass(cell).components(separatedBy: ".").last!
        let nib = UINib(nibName: className, bundle: nil)
        self.register(nib, forCellReuseIdentifier: className)
    }

    /// Register header class for the table
    ///
    /// - Parameter header: the header class
    func register(header: UITableViewHeaderFooterView.Type) {
        let className = NSStringFromClass(header).components(separatedBy: ".").last!
        let nib = UINib(nibName: className, bundle: nil)
        self.register(nib, forHeaderFooterViewReuseIdentifier: className)
    }

    /// Dequeue reusable cell for indexPath
    ///
    /// - Parameters:
    ///   - indexPath: the indexPath
    ///   - cellClass: a cell class
    /// - Returns: a reusable cell
    public func cell<T: UITableViewCell>(_ indexPath: IndexPath, ofClass cellClass: T.Type) -> T {
        let className = NSStringFromClass(cellClass).components(separatedBy: ".").last!
        return self.dequeueReusableCell(withIdentifier: className, for: indexPath) as! T
    }
}
