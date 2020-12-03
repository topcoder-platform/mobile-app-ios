//
//  ArrayExtensions.swift
//  SwiftEx
//
//  Created by Volkov Alexander on 3/18/19.
//

import Foundation

// MARK: - Helpful extension for arrays
extension Array {

    /**
     Convert array to hash array.
     Example:
     ```
     let a = [Item(id: 1, title: "one"), Item(id: 2, title: "two"), Item(id: 3, title: "three"), Item(id: 1, title: "another one")]
     let map = a.hashmapWithKey{$0.id} // [1: Item(id: 1, title: "another one"), 2: Item(id: 2, title: "two"), 3: Item(id: 3 title: "three")]
     ```
     Note that first element is dropped because there is duplication (by ID)
     - Parameter transform: the transformation of an object to a key
     - Returns: a hashmap
     */
    public func hashmapWithKey<K>(_ transform: (Element) -> (K)) -> [K:Element] {
        var hashmap = [K:Element]()

        for item in self {
            let key = transform(item)
            hashmap[key] = item
        }
        return hashmap
    }

    /**
     Convert array to hash array
     Example:
     ```
     let a = [Item(id: 1, title: "one"), Item(id: 2, title: "two"), Item(id: 3, title: "three"), Item(id: 1, title: "another one")]
     let map = a.hasharrayWithKey{$0.id} // [1: [Item(id: 1, title: "one"), Item(id: 1, title: "another one")], 2: [Item(id: 2, title: "two")], 3: [Item(id: 3, title: "three")]]
     ```
     - Parameter transform: the transformation of an object to a key
     - Returns: a hashmap with arrays as values
     */
    public func hasharrayWithKey<K>(_ transform: (Element) -> (K)) -> [K:[Element]] {
        var hashmap = [K:[Element]]()

        for item in self {
            let key = transform(item)
            var a = hashmap[key]
            if a == nil {
                a = [Element]()
                hashmap[key] = a
            }
            a!.append(item)
            hashmap[key] = a
        }
        return hashmap
    }

    /// Filter items by given offset and limit
    ///
    /// - Parameters:
    ///   - items: the list of all items
    ///   - offset: the offset
    ///   - limit: the limit
    /// - Returns: the items by given offset and nextOffset
    public func filterByOffset<E>(_ items: [E], offset: Any?, limit: Int) -> ([E], Any) {
        if let offset = offset as? Int {
            if offset < items.count {
                let nextOffset = Swift.min(offset + limit, items.count)
                return (Array<E>(items[offset..<nextOffset]), nextOffset)
            }
            else {
                return ([], offset)
            }
        }
        else {
            let nextOffset = Swift.min(limit, items.count)
            return (Array<E>(items[0..<nextOffset]), nextOffset)
        }
    }
    
    
}

extension Array where Element: Equatable {

    /// Get unique elements
    ///
    /// - Returns: the list with unique element from this array
    public func unique() -> [Element] {
        var list = [Element]()
        for item in self {
            if !list.contains(item) {
                list.append(item)
            }
        }
        return list
    }
}
