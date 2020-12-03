//
//  SectionCollectionModel.swift
//  Alamofire
//
//  Created by Volkov Alexander on 4/2/19.
//

import UIKit

/// Viewmodel for collection with sections
open class SectionCollectionModel<T, C: UICollectionViewCell, S, H: UICollectionReusableView>: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    /// the collection view
    internal var collectionView: UICollectionView!

    /// configuration callbacks
    public var createCell: ((T, IndexPath)->(C))? // (optional); can be used when there are multiple types of cells
    public var configureCell: ((T, IndexPath, C)->())!  // required
    public var configureHeader: ((_ index: Int, _ item: S, _ section: H) -> ())! // required if `useSectionHeaders == true`
    public var hasData: ((Bool)->())? // optional
    public var calculateCellSize: ((Any, IndexPath)->(CGSize))? // required

    /// the event handlers
    public var selected: ((T, IndexPath)->())? // recommended

    /// the items to show
    public var sectionItems = [[T]]()
    internal var sections = [S]()

    /// true - will use section headers, false - will skip them. If `false`, then you can use `UICollectionReusableView` as `H`.
    public var useSectionHeaders = true

    public var count: Int {
        return sectionItems.map({$0.count}).reduce(0, +)
    }

    /// binds data to collection view
    public func bind(_ collectionView: UICollectionView) {
        self.collectionView = collectionView
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    /// Set items
    ///
    /// - Parameter items: the items
    public func setItems(_ sectionItems: [[T]], sections: [S]) {
        self.sectionItems = sectionItems
        self.sections = sections
        hasData?(self.count > 0)
        self.collectionView.reloadData()
    }

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sections.count
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sectionItems[section].count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = sectionItems[indexPath.section][indexPath.row]
        var cell: C!
        if let createCell = createCell {
            cell = createCell(item, indexPath)
        }
        else {
            cell = collectionView.cell(indexPath, ofClass: C.self)
        }
        configureCell?(item, indexPath, cell)
        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = sectionItems[indexPath.section][indexPath.row]
        self.selected?(item, indexPath)
        collectionView.deselectItem(at: indexPath, animated: false)
    }

    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader && useSectionHeaders {
            let className = NSStringFromClass(H.self).components(separatedBy: ".").last!
            let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: className, for: indexPath) as! H
            let item = sections[indexPath.section]
            configureHeader(indexPath.section, item, view)
            return view
        }
        return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "footer", for: indexPath)
    }

    /// Get cell size
    ///
    /// - Parameters:
    ///   - collectionView: the collectionView
    ///   - collectionViewLayout: the layout
    ///   - indexPath: the indexPath
    /// - Returns: cell size
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = sectionItems[indexPath.section][indexPath.row]
        return calculateCellSize?(item, indexPath) ?? CGSize(width: 100, height: 100)
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        willDisplay(cell: cell, forItemAt: indexPath)
    }
    
    internal func willDisplay(cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
}
