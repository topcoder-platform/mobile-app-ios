//
//  CollectionDataModel.swift
//  SwiftExInt
//
//  Created by Volkov Alexander on 2/10/18.
//  Copyright © 2018-2019 Alexander Volkov. All rights reserved.
//

import UIKit
import SwiftyJSON

/**
 * UICollectionView data source and delegate
 *
 ```
 private var dataSource: CollectionDataModel<Cell>!
 self.dataSource = CollectionDataModel(collectionView, cellClass: Cell.self) { [weak self] (item, indexPath, cell) in
     guard self != nil else { return }
     let item = item as! Item
     cell.configure(item, isSelected: self!.selectedItem == item)
 }
 dataSource.selected = { [weak self] item, indexPath in
     self!.selectedItem = item as! Item
     self!.collectionView.reloadData()
     self!.reloadData()
 }
 dataSource.calculateCellSize = { [weak self] _, _ -> CGSize in
     return CGSize(width: self!.collectionView.getCellWidth(forColumns: 3), height: self!.collectionView.bounds.height)
 }
 ```
 * - author: Alexander Volkov
 * - version: 1.0
 */
open class CollectionDataModel<T: UICollectionViewCell>: NSObject, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    /// the collection view
    internal let collectionView: UICollectionView

    /// the cell class
    internal let cellClass: T.Type

    /// configuration callbacks
    internal let createCell: ((Any, IndexPath)->(T))?
    internal let configure: (Any, IndexPath, T)->()

    /// the items to show
    public var items = [Any]()

    /// the event handlers
    public var selected: ((Any, IndexPath)->())?
    public var hasData: ((Bool)->())?
    public var calculateCellSize: ((Any, IndexPath)->(CGSize))?

    /// Initializer
    ///
    /// - Parameter tableView: the tableView
    @discardableResult
    public init(_ collectionView: UICollectionView, cellClass: T.Type, preConfigure: ((Any, IndexPath)->(T))? = nil, configure: @escaping (Any, IndexPath, T)->()) {
        self.collectionView = collectionView
        self.cellClass = cellClass
        self.createCell = preConfigure
        self.configure = configure
        super.init()
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    /// Set items
    ///
    /// - Parameter items: the items
    public func setItems(_ items: [Any]) {
        self.items = items
        hasData?(!items.isEmpty)
        self.collectionView.reloadData()
    }

    // MARK: - UICollectionViewDataSource, UICollectionViewDelegate

    /// Get the number of cells
    ///
    /// - Parameters:
    ///   - collectionView: the collectionView
    ///   - section: the section
    /// - Returns: the number of cells
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }

    /// Get cell
    ///
    /// - Parameters:
    ///   - collectionView: the collectionView
    ///   - indexPath: the indexPath
    /// - Returns: the cell
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = items[indexPath.row]
        if let preConfigure = createCell {
            let cell = preConfigure(item, indexPath)
            configure(item, indexPath, cell)
            return cell
        }
        else {
            let cell = collectionView.cell(indexPath, ofClass: T.self)
            configure(item, indexPath, cell)
            return cell
        }
    }

    /// Cell selection handler
    ///
    /// - Parameters:
    ///   - collectionView: the collectionView
    ///   - indexPath: the indexPath
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        selected?(item, indexPath)
        collectionView.reloadData()
    }

    /// Get cell size
    ///
    /// - Parameters:
    ///   - collectionView: the collectionView
    ///   - collectionViewLayout: the layout
    ///   - indexPath: the indexPath
    /// - Returns: cell size
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let item = items[indexPath.row]
        return calculateCellSize?(item, indexPath) ?? CGSize(width: 100, height: 100)
    }
}
