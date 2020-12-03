//
//  SectionInfiniteTableViewModel.swift
//  SwiftExInt
//
//  Created by Volkov Alexander on 3/12/18.
//  Copyright (c) 2018-2019 Alexander Volkov. All rights reserved.
//

import UIKit

/// the table model

/**
 * Viewmodel for table with sections
 *

 ```
 /// the table model
 private var table = SectionInfiniteTableViewModel<Any, UITableViewCell, SectionHeaderCell>()

 table.noDataLabel = noDataLabel
 table.configureCell = { indexPath, item, _, cell in
      cell.titleLabel?.text = item.title
 }
 table.configureHeader = { index, item, section in
      ...
 }
 table.sectionHeaderHeight = 44
 table.onSelect = { indexPath, item in
     ...
 }
 table.loadSectionItems = { callback, failure in
      ...
 }
 table.bindData(to: tableView)
 ```
 * - author: Alexander Volkov
 * - version: 1.0
 */
open class SectionInfiniteTableViewModel<T, C: UITableViewCell, S: UITableViewHeaderFooterView>: InfiniteTableViewModel<T, C> {

    /// load items callback
    public var loadSectionItems: ((_ callback: @escaping ([[T]], [String])->(), _ failure: @escaping FailureCallback) -> ())!

    /// fetch items callback
    public var fetchSectionItems: ((_ offset: Any?, _ limit: Int, _ callback: @escaping ([[T]], [String], Any)->(), _ failure: @escaping FailureCallback) -> ())!

    /// section header configuration
    public var configureHeader: ((_ index: Int, _ item: String, _ section: S) -> ())?

    /// section footer configuration
    public var configureFooter: ((_ index: Int) -> (UITableViewHeaderFooterView?))?

    /// the section header height
    public var sectionHeaderHeight: CGFloat = 30
    /// the section footer height
    public var sectionFooterHeight: CGFloat = 0
    
    /// the section header height configuration
    public var configureSectionHeaderHeight: ((_ index: Int) -> (CGFloat?))?
    
    /// the items to show
    public var sectionItems = [[T]]()
    public var sectionTitles = [String]()

    /// binds data to table view
    ///
    /// - Parameter tableView: tableView to bind to
    /// - Parameter sequence: data sequence
    public override func bindData(to tableView: UITableView) {
        tableView.register(header: S.self)
        super.bindData(to: tableView)
    }

    /// Load data
    public override func loadData() {
        self.sectionItems.removeAll()
        self.sectionTitles.removeAll()
        super.loadData()
    }

    /// Get items in given section
    ///
    /// - Parameter section: the section
    /// - Returns: the number of items in section
    internal override func getItems(inSection section: Int) -> [T] {
        return sectionItems[section]
    }

    /// Loading next items
    internal override func loadNextItems(showLoading: Bool = false) {
        if !loadCompleted {
            let requestId = UUID().uuidString
            self.requestId = requestId
            isLoading = true
            let loadingView = showLoading && showLoadingIndicator ? UIViewController.getCurrentViewController()?.showActivityIndicator() : nil
            let callback: ([[T]], [String], Any)->() = { items, sectionTitles, offset in
                if self.requestId == requestId {
                    self.offset = offset
                    let count = items.map{$0.count}.reduce(0, +)
                    self.loadCompleted = count == 0
                    if !items.isEmpty {
                        self.merge(newItems: items, titles: sectionTitles)
                        if showLoading {
                            self.initCellHeights()
                            self.updateTableHeight()
                        }
                        self.tableView.reloadData()
                    }
                    self.noDataLabel?.isHidden = self.sectionItems.map{$0.count}.reduce(0, +) > 0

                    //self.set(items: items, sectionTitles: sectionTitles)

                    self.isLoading = false
                    self.tableView.tableFooterView = nil
                }
                loadingView?.stop()
            }
            let failure: FailureCallback = { (errorMessage) -> () in
                showError(errorMessage: errorMessage)
                self.isLoading = false
                self.tableView.tableFooterView = nil
                loadingView?.stop()
            }
            if let fetch = self.fetchSectionItems {
                fetch(offset, LIMIT, callback, failure)
            }
            else {
                if offset == nil {
                    loadSectionItems?({ items, titles in
                        callback(items, titles, items.count)
                    }, failure)
                }
                else {
                    callback([], [], 0)
                }
            }
        }
    }

    /// Add items to existing sections (if exist) or add new sections
    ///
    /// - Parameters:
    ///   - items: the items
    ///   - titles: the titles
    private func merge(newItems items: [[T]], titles: [String]) {
        for i in 0..<titles.count {
            let title = titles[i]
            if let index = sectionTitles.index(of: title) {
                self.sectionItems[index].append(contentsOf: items[i])
            }
            else {
                self.sectionTitles.append(title)
                self.sectionItems.append(items[i])
            }
        }
    }

    /// Set items and section titles
    ///
    /// - Parameters:
    ///   - items: the items
    ///   - sectionTitles: the titles for the sections
    public func set(items: [[T]], sectionTitles: [String]) {
        self.sectionItems = []
        self.tableView.reloadData()
        self.sectionItems = items
        self.sectionTitles = sectionTitles
        self.initCellHeights()
        self.updateTableHeight()
        self.tableView.reloadData()
        let count = items.map{$0.count}.reduce(0, +)
        self.noDataLabel?.isHidden = count > 0

        delay(0) {
            self.tableView.contentOffset.y = 0
            self.tableView.setNeedsLayout()
        }
    }

    public func remove(at indexPath: IndexPath) {
//        if self.sectionItems.count > indexPath.section && self.sectionItems[indexPath.section].count > indexPath.row {
            self.sectionItems[indexPath.section].remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
//        }
    }

    // MARK: UITableViewDataSource, UITableViewDelegate

    /// Get number of sections
    ///
    /// - Parameter tableView: the tableView
    /// - Returns: the number of sections
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return sectionItems.count
    }

    /**
     The number of rows

     - parameter tableView: the tableView
     - parameter section:   the section index

     - returns: the number of items
     */
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionItems[section].count
    }

    /// Load more items
    ///
    /// - Parameters:
    ///   - tableView: the tableView
    ///   - cell: the cell
    ///   - indexPath: the indexPath
    public override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableHeight != nil {
            if var sectionHeights = heights[indexPath.section] {
                sectionHeights[indexPath.row] = cell.bounds.height
                heights[indexPath.section] = sectionHeights
            }
            updateTableHeight()
        }
        if indexPath.section + 1 == sectionTitles.count
            && indexPath.row + 1 == sectionItems[indexPath.section].count
            && !isLoading && !ignoreFetchFromLastCell {
            loadNextItems()
        }
    }

    /// Get section title
    ///
    /// - Parameters:
    ///   - tableView: the tableView
    ///   - section: the section index
    /// - Returns: the title
    public override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return configureHeader == nil ? sectionTitles[section] : nil
    }

    /// Get section header view
    ///
    /// - Parameters:
    ///   - tableView: the tableView
    ///   - section: the section index
    /// - Returns: the view
    public override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let configure = configureHeader {
            let title = sectionTitles[section]
            let id = NSStringFromClass(S.self).components(separatedBy: ".").last!
            let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: id) as! S
            configure(section, title, view)
            return view
        }
        return nil
    }

    /// Get section footer view
    ///
    /// - Parameters:
    ///   - tableView: the tableView
    ///   - section: the section index
    /// - Returns: the view
    public override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return configureFooter?(section)
    }

    /// Get section header height
    ///
    /// - Parameters:
    ///   - tableView: the tableView
    ///   - section: the section index
    /// - Returns: the height
    public override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return configureSectionHeaderHeight?(section) ?? sectionHeaderHeight
    }

    /// Get section footer height
    ///
    /// - Parameters:
    ///   - tableView: the tableView
    ///   - section: the section index
    /// - Returns: the height
    public override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return sectionFooterHeight
    }

    // MARK: - Table methods

    /**
     Get cell for given indexPath

     - parameter tableView: the tableView
     - parameter indexPath: the indexPath

     - returns: cell
     */
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let value = getItems(inSection: indexPath.section)[indexPath.row]
        self.onSelect?(indexPath, value)
    }

    /// Update table height
    internal override func updateTableHeight() {
        if let tableHeight = tableHeight {
            var height: CGFloat = 0
            for (_,list) in heights {
                for (_,h) in list {
                    height += h
                }
            }
            height += extraHeight
            tableHeight.constant = height
            let nSections = self.numberOfSections(in: tableView)
            for i in 0..<nSections {
                let h = configureSectionHeaderHeight?(i) ?? sectionHeaderHeight
                height += h + self.sectionFooterHeight
            }
            tableHeight.constant = height
            tableHeightCallback?(height)
        }
    }
    
    /// Remove cell at index path to the left
    /// - Parameter indexPath: the indexPath
    public func remove(indexPath: IndexPath) {
        var list = sectionItems[indexPath.section]
        list.remove(at: indexPath.row)
        if let sectionHeights = heights[indexPath.section] {
            var newHeights = [Int: CGFloat]()
            for (i,h) in sectionHeights {
                if i > indexPath.row {
                    newHeights[i-1] = h
                }
                else if i < indexPath.row {
                    newHeights[i] = h
                }
            }
            heights[indexPath.section] = newHeights
        }
        if list.isEmpty {
            var sections = sectionItems
            sections.remove(at: indexPath.section)
            sectionItems = sections
            heights.removeValue(forKey: indexPath.section)
            tableView.deleteSections(IndexSet(arrayLiteral: indexPath.section), with: .left)
        }
        else {
            var sections = sectionItems
            sections[indexPath.section] = list
            sectionItems = sections
            tableView.deleteRows(at: [indexPath], with: .left)
        }
        delay(0.3) {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: { [weak self] in
                self?.updateTableHeight()
                self?.tableView.superview?.layoutIfNeeded()
                }, completion: nil)
        }
    }
}
