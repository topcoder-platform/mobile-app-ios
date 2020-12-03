//
//  UICollectionViewExtensions.swift
//  SwiftEx
//
//  Created by Volkov Alexander on 2/21/18.
//

import UIKit

// MARK: - UICollectionView extension
extension UICollectionView {

    /// Get cell of given class for indexPath
    ///
    /// - Parameters:
    ///   - indexPath: the indexPath
    ///   - cellClass: a cell class
    /// - Returns: a reusable cell
    public func cell<T: UICollectionViewCell>(_ indexPath: IndexPath, ofClass cellClass: T.Type) -> T {
        let className = NSStringFromClass(cellClass).components(separatedBy: ".").last!
        return self.dequeueReusableCell(withReuseIdentifier: className, for: indexPath) as! T
    }

    /// Calculate collection height
    ///
    /// - Parameters:
    ///   - n: the number of columns
    ///   - items: the number of items
    ///   - cellHeight: the cell height
    public func collectionHeight(forColumns n: Int = 2, items: Int, cellHeight: CGFloat) -> CGFloat {
        let layout = (self.collectionViewLayout as! UICollectionViewFlowLayout)
        let margins = layout.sectionInset
        let spacing = CGSize(width: layout.minimumInteritemSpacing, height: layout.minimumLineSpacing)

        let rows = Int(max(0, floor(Float(items - 1) / Float(n)) + 1))
        let spaces = max(0, rows - 1)
        let height = margins.top + CGFloat(rows) * cellHeight + CGFloat(spaces) * spacing.height + margins.bottom
        return height
    }

    /// Calculate cell width
    ///
    /// - Parameters:
    ///   - n: the number of columns
    public func cellWidth(forColumns n: Int = 2) -> CGFloat {
        let layout = (self.collectionViewLayout as! UICollectionViewFlowLayout)
        let margins = layout.sectionInset
        let spacing = CGSize(width: layout.minimumInteritemSpacing, height: layout.minimumLineSpacing)
        let width = (self.bounds.width - margins.left - margins.right - CGFloat(n - 1) * spacing.width) / CGFloat(n)
        return floor(width)
    }

    /// Get height of the collection with cells of different width
    ///
    /// - Parameters:
    ///   - maxWidth: the width of the collection
    ///   - cellHeight: the height of the cell
    ///   - itemWidths: the width of the cells
    /// - Returns: height for the whole collection
    public func collectionDynamicHeight(forMaxWidth maxWidth: CGFloat, cellHeight: CGFloat, itemWidths: [CGFloat]) -> CGFloat {
        let layout = (self.collectionViewLayout as! UICollectionViewFlowLayout)
        let margins = layout.sectionInset
        let spacing = CGSize(width: layout.minimumInteritemSpacing, height: layout.minimumLineSpacing)

        var lineIndex = 0
        var lineWidth: CGFloat = 0
        var itemsInLine = 0
        let prepareNextLine = {
            lineWidth += margins.left + margins.right
        }
        prepareNextLine()
        for item in itemWidths {
            // Add item
            if itemsInLine > 0 {
                lineWidth += spacing.width
            }
            lineWidth += item
            if lineWidth >= maxWidth { // next line
                lineIndex += 1
                lineWidth = 0; prepareNextLine()
                itemsInLine = 0
                lineWidth += item // Add item to next line
            }
            itemsInLine += 1
        }
        let n = lineIndex + 1
        let h = CGFloat(n) * cellHeight + CGFloat(n - 1) * spacing.height + margins.top + margins.bottom
        return h
    }
}
