//
//  Pages.swift
//  SwiftExInt
//
//  Created by Volkov Alexander on 3/14/19.
//  Copyright (c) 2019 Alexander Volkov. All rights reserved.
//

import Foundation

/*
 Use typealias to use one of the structures
 `typealias Page = PageV1`
 */

public struct PageV1<T: Codable>: Codable {

    /// fields
    public var items: Array<T>
    public var offset: Int?
    public var total = 0
    public var pageSize = 0
    
    public init(items: Array<T>, offset: Int?, total: Int = 0, pageSize: Int = 0) {
        self.items = items
        self.offset = offset
        self.total = total
        self.offset = offset
    }
}

public struct PageV2<T: Codable>: Codable {
    
    /// fields
    public var items: Array<T>
    public var hasMore: Bool
    
    public init(items: Array<T>, hasMore: Bool) {
        self.items = items
        self.hasMore = hasMore
    }
}

public struct PageV3<T: Codable>: Codable {
    
    /// fields
    public var results: Array<T>
    public var page: Int?
    public var total: Int = 0
    public var perPage: Int = 0
    
    public init(results: Array<T>, page: Int?, total: Int = 0, perPage: Int = 0) {
        self.results = results
        self.page = page
        self.total = total
        self.perPage = perPage
    }
}
