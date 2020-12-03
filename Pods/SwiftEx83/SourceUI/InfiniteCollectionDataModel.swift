//
//  InfiniteCollectionDataModel.swift
//  RemoteExpert
//
//  Created by Volkov Alexander on 8/6/20.
//  Copyright © 2020 Volkov Alexander. All rights reserved.
//

import UIKit

/// Collection model with infinite loading
open class InfiniteCollectionDataModel<T, C: UICollectionViewCell, S: Equatable, H: UICollectionReusableView>: SectionCollectionModel<T, C, S, H> {
    
    /// the reference to "no data" label (Optional)
    public var noDataLabel: UIView?
    
    /// true - will show loading indicator, false - else
    public var showLoadingIndicator = true
    
    /// the number of items to load at once
    public var LIMIT = 10
    
    /// the last used offset
    internal var offset: Any?
    
    /// flag: true - the loading completed (no more data), false - else (getter only)
    public var loadCompleted = false
    
    /// flag: is currently loading
    internal var isLoading = false
    
    /// the request ID
    internal var requestId = ""
    
    /// true - the model will not fetch nex page when last cell is displayed, false - else
    /// Set to true to use custom event handler for next page loading - call `
    public var ignoreFetchFromLastCell = false
    
    /// true - will not set `loadCompleted` to true (you have to do that manually using `setLoadCompleted()`), false - will set true when the number of loaded items is less than `LIMIT`.
    public var useCustomLoadCompletedLogic = false
    
    /// fetch items callback (required)
    public var fetchSectionItems: ((_ offset: Any?, _ limit: Int, _ callback: @escaping ([[T]], [S], Any)->(), _ failure: @escaping FailureCallback) -> ())!
    
    /// Load data
    public func loadData() {
        
        self.sectionItems.removeAll()
        self.sections.removeAll()
        
        self.noDataLabel?.isHidden = true
        self.offset = nil
        self.loadCompleted = false
        collectionView.reloadData()
        
        loadNextItems(showLoading: true)
    }
    
    /// Loading next items
    internal func loadNextItems(showLoading: Bool = false) {
        if !loadCompleted {
            let requestId = UUID().uuidString
            self.requestId = requestId
            isLoading = true
            let loadingView = showLoading ? UIViewController.getCurrentViewController()?.showActivityIndicator() : nil
            let callback: ([[T]], [S], Any)->() = { items, sectionTitles, offset in
                if self.requestId == requestId {
                    self.offset = offset
                    let count = items.map{$0.count}.reduce(0, +)
                    self.loadCompleted = count == 0
                    if !items.isEmpty {
                        self.merge(newItems: items, newSections: sectionTitles)
                        self.collectionView.reloadData()
                    }
                    self.noDataLabel?.isHidden = self.sectionItems.map{$0.count}.reduce(0, +) > 0
                    self.isLoading = false
                }
                loadingView?.stop()
            }
            let failure: FailureCallback = { (errorMessage) -> () in
                showError(errorMessage: errorMessage)
                self.isLoading = false
                loadingView?.stop()
            }
            if let fetch = self.fetchSectionItems {
                fetch(offset, LIMIT, callback, failure)
            }
        }
    }
    
    /// Add items to existing sections (if exist) or add new sections
    ///
    /// - Parameters:
    ///   - items: the items
    ///   - newSections: the new sections
    private func merge(newItems items: [[T]], newSections: [S]) {
        for i in 0..<newSections.count {
            let title = newSections[i]
            if let index = sections.index(of: title) {
                self.sectionItems[index].append(contentsOf: items[i])
            }
            else {
                self.sections.append(title)
                self.sectionItems.append(items[i])
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
    
    internal override func willDisplay(cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if indexPath.section + 1 == sections.count
            && indexPath.row + 1 == sectionItems[indexPath.section].count
            && !isLoading && !ignoreFetchFromLastCell {
            loadNextItems()
        }
    }
}
