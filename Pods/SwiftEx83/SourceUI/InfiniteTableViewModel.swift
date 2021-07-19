//
//  InfiniteTableViewModel.swift
//  SwiftExInt
//
//  Created by Volkov Alexander on 2/23/18.
//  Copyright © 2018-2019 Alexander Volkov. All rights reserved.
//

import UIKit

/**
 * Model for table used in table view controllers
 ```
 private public var table = InfiniteTableViewModel<PieChartDataEntry, AccountInfoTableViewCell>()

 table.configureCell = { [weak self] indexPath, item, _, cell in
     guard self != nil else { return }
     let color = self!.colors[indexPath.row % self.colors.count]
     cell.configure(item, color: color)
 }
 table.onSelect = { [weak self] _, item in
 }
 table.loadItems = { [weak self] callback, failure in
     callback([])
 }
 table.bindData(to: tableView)
 ```
 or use the following instead of `table.loadItems`
 ```
 table.fetchItems = { [weak self] (_ offset, _ limit, _ callback, _ failure) in
     RestServiceApi.shared.getSomething(offset: offset, limit: limit, forObject: self!.object, callback: callback, failure: failure)
 }
 ```


 Use the following example when `ignoreFetchFromLastCell == true`
 ```
 // MARK: - UIScrollViewDelegate

 func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
    if !decelerate {
        checkIfNeedToLoadMore()
    }
 }

 func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    checkIfNeedToLoadMore()
 }

 private func checkIfNeedToLoadMore() {
     let offset = scrollView.contentOffset.y
     let limit = scrollView.contentSize.height - scrollView.bounds.height - 1
     if offset >= limit && scrollView.contentSize.height > scrollView.bounds.height {
        tryToFetchMore()
     }
 }

 private func tryToFetchMore() {
    table.tryLoadNextItems()
 }
 ```
 *
 * - author: Alexander Volkov
 * - version: 1.0
 */
open class InfiniteTableViewModel<T, C: UITableViewCell>: NSObject, UITableViewDataSource, UITableViewDelegate {

    // the table view
    public weak var tableView: UITableView!
    public weak var tableHeight: NSLayoutConstraint?
    public var tableHeightCallback: ((CGFloat)->())?

    /// the extra height added to the table
    public var extraHeight: CGFloat = 0

    /// selection handler
    public var onSelect: ((_ indexPath: IndexPath, _ item: T) -> ())?

    /// cell configuration
    public var configureCell: ((_ indexPath: IndexPath, _ item: T, _ items: [T], _ cell: C) -> ())?

    /// pre-configuration callback
    public var preConfigure: ((_ indexPath: IndexPath, _ item: T, _ items: [T]) -> (C))?

    /// fetch items callback
    public var fetchItems: ((_ offset: Any?, _ limit: Int, _ callback: @escaping ([T], Any)->(), _ failure: @escaping FailureCallback) -> ())!

    /// load items callback
    public var loadItems: ((_ callback: @escaping ([T])->(), _ failure: @escaping FailureCallback) -> ())!
    
    /// Delete action
    public var deleteAction: ((_ indexPath: IndexPath, _ item: T)->())?
    
    /// Edit action
    public var editAction: ((_ indexPath: IndexPath, _ item: T)->())?
    
    /// Edit actions
    public var editActions: ((_ indexPath: IndexPath, _ item: T)->(Any?))? // the callback must return nil or `UISwipeActionsConfiguration`
    
    /// the reference to "no data" label
    public var noDataLabel: UIView?

    /// true - will show loading indicator, false - else
    public var showLoadingIndicator = true

    /// the number of items to load at once
    internal var LIMIT = 10

    /// the items to show
    public var items = [T]()

    /// the last used offset
    internal var offset: Any?

    /// flag: true - the loading completed (no more data), false - else
    public var loadCompleted = false

    /// flag: is currently loading
    internal var isLoading = false

    /// the minimum height of the cell
    internal var cellMinHeight: CGFloat = 44

    /// the request ID
    internal var requestId = ""

    /// the heights of the cell
    internal var heights = [Int: [Int:CGFloat]]()

    /// true - the model will not fetch nex page when last cell is displayed, false - else
    /// Set to true to use custom event handler for next page loading - call `
    public var ignoreFetchFromLastCell = false

    /// true - will not set `loadCompleted` to true (you have to do that manually using `setLoadCompleted()`), false - will set true when the number of loaded items is less than `LIMIT`.
    public var useCustomLoadCompletedLogic = false

    /// binds data to table view
    public func bindData(to tableView: UITableView) {
        self.tableView = tableView
        // Remove extra separators after all rows
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentOffset.y = -tableView.contentInset.top
        loadData()
    }

    /// Load data
    public func loadData() {
        self.noDataLabel?.isHidden = true
        self.offset = nil
        self.loadCompleted = false
        self.items.removeAll()
        self.initCellHeights()
        self.updateTableHeight()
        tableView.reloadData()

        loadNextItems(showLoading: true)
    }

    /// Loading next items
    internal func loadNextItems(showLoading: Bool = false) {
        if !loadCompleted {
            let requestId = UUID().uuidString
            self.requestId = requestId
            // infinite loader ?
            isLoading = true
            let loadingView = showLoading && self.showLoadingIndicator ? UIViewController.getCurrentViewController()?.showActivityIndicator() : nil
            let callback: ([T], Any)->() = { list, offset in
                if self.requestId == requestId {
                    self.offset = offset
                    if !(self.useCustomLoadCompletedLogic) {
                        self.loadCompleted = list.count < self.LIMIT
                    }
                    if !list.isEmpty {
                        self.items.append(contentsOf: list)
                        if showLoading {
                            self.initCellHeights()
                            self.updateTableHeight()
                        }
                        self.tableView.reloadData()
                    }
                    else {
                        // dodo test
                        if showLoading {
                            self.initCellHeights()
                            self.updateTableHeight()
                        }
                    }

                    self.noDataLabel?.isHidden = self.items.count > 0

                    self.isLoading = false
                    self.tableView.tableFooterView = UIView(frame: CGRect.zero)
                }
                loadingView?.stop()
            }
            let failure: FailureCallback = { (errorMessage) -> () in
                showError(errorMessage: errorMessage)
                self.isLoading = false
                self.tableView.tableFooterView = UIView(frame: CGRect.zero)
                loadingView?.stop()
            }
            if let fetch = self.fetchItems {
                fetch(offset, LIMIT, callback, failure)
            }
            else {
                if offset == nil {
                    loadItems?({ items in
                        callback(items, items.count)
                    }, failure)
                }
                else {
                    callback([], 0)
                }
            }
        }
    }

    /// Fetch next page. Can be used when `ignoreFetchFromLastCell := true`
    public func tryLoadNextItems() {
        if !isLoading {
            loadNextItems()
        }
    }

    /// Used to set "loadCompleted" flag when further "scroll to bottom" will not result in data loading
    public func setLoadCompleted() {
        loadCompleted = true
    }
    
    /// Set items manually
    ///
    /// - Parameter items: the items
    public func set(items: [T]) {
        self.items = items
        self.tableView.reloadData()
    }

    // MARK: UITableViewDataSource, UITableViewDelegate

    /// Get number of sections
    ///
    /// - Parameter tableView: the tableView
    /// - Returns: the number of sections
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    /**
     The number of rows

     - parameter tableView: the tableView
     - parameter section:   the section index

     - returns: the number of items
     */
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getItems(inSection: section).count
    }

    /**
     Get cell for given indexPath

     - parameter tableView: the tableView
     - parameter indexPath: the indexPath

     - returns: cell
     */
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let items = getItems(inSection: indexPath.section)
        let value = items[indexPath.row]
        if let preConfigure = preConfigure {
            return preConfigure(indexPath, value, items)
        }
        else {
            let cell = tableView.cell(indexPath, ofClass: C.self)
            configureCell?(indexPath, value, items, cell)
            return cell
        }
    }

    /// Cell selection handler
    ///
    /// - Parameters:
    ///   - tableView: the tableView
    ///   - indexPath: the indexPath
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let value = getItems(inSection: indexPath.section)[indexPath.row]
        self.onSelect?(indexPath, value)
    }

    /// Load more items
    ///
    /// - Parameters:
    ///   - tableView: the tableView
    ///   - cell: the cell
    ///   - indexPath: the indexPath
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableHeight != nil {
            if var sectionHeights = heights[indexPath.section] {
                sectionHeights[indexPath.row] = cell.bounds.height
                heights[indexPath.section] = sectionHeights
            }
            updateTableHeight()
        }
        if indexPath.row + 1 == items.count && !isLoading && !ignoreFetchFromLastCell {
            loadNextItems()
        }
    }

    /// Get section title
    ///
    /// - Parameters:
    ///   - tableView: the tableView
    ///   - section: the section index
    /// - Returns: the title
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return nil
    }

    /// Get section header view
    ///
    /// - Parameters:
    ///   - tableView: the tableView
    ///   - section: the section index
    /// - Returns: the view
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }

    /// Get section footer view
    ///
    /// - Parameters:
    ///   - tableView: the tableView
    ///   - section: the section index
    /// - Returns: the view
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return nil
    }

    /// Get section header height
    ///
    /// - Parameters:
    ///   - tableView: the tableView
    ///   - section: the section index
    /// - Returns: the height
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }

    /// Get section footer height
    ///
    /// - Parameters:
    ///   - tableView: the tableView
    ///   - section: the section index
    /// - Returns: the height
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    @available(iOS 11.0, *)
    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return editActions?(indexPath, getItem(indexPath: indexPath)) as? UISwipeActionsConfiguration
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if let action = editActions {
            return action(indexPath, getItem(indexPath: indexPath)) != nil
        }
        return deleteAction != nil || editAction != nil || editActions != nil
    }
    
    /// Delete row
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
       if editingStyle == .delete {
            if let deleteAction = deleteAction {
                deleteAction(indexPath, getItem(indexPath: indexPath))
                items.remove(at: indexPath.row)
                if items.count > 0 {
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                }
                else {
                    noDataLabel?.isHidden = false
                    tableView.reloadData()
                }
            }
        }
    }

    // MARK: - Table height

    /// Initialize heights array
    internal func initCellHeights() {
        heights.removeAll()
        let n = self.numberOfSections(in: tableView)
        for i in 0..<n {
            var sectionHeights = [Int:CGFloat]()
            for j in 0..<getItems(inSection: i).count {
                sectionHeights[j] = self.cellMinHeight
            }
            heights[i] = sectionHeights
        }
    }

    /// Get items in given section
    ///
    /// - Parameter section: the section
    /// - Returns: the number of items in section
    internal func getItems(inSection section: Int) -> [T] {
        return items
    }
    
    /// Get item for indexPath
    ///
    /// - Parameter indexPath: the indexPath
    /// - Returns: the item
    internal func getItem(indexPath: IndexPath) -> T {
        return getItems(inSection: indexPath.section)[indexPath.row]
    }

    /// Update table height
    internal func updateTableHeight() {
        if let tableHeight = tableHeight {
            var height: CGFloat = 0
            for (_,list) in heights{
                for (_,h) in list {
                    height += h
                }
            }
            tableHeight.constant = height + extraHeight
            tableHeightCallback?(height + extraHeight)
        }
    }
}

