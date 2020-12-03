//
//  JSONExtension.swift
//  SwiftExInt
//
//  Created by Volkov Alexander on 1/9/19.
//  Copyright (c) 2018-2019 Alexander Volkov. All rights reserved.
//

import Foundation
import SwiftyJSON

// MARK: - SwiftyJSON extensions
extension JSON {

    /// Decode object of given type from JSON
    /// Created by Volkov Alexander on 18/12/18.
    ///
    /// - Parameter type: the type
    /// - Returns: the decoded object
    /// - Throws: the decoding error
    public func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        let result = try JSONDecoder().decode(T.self, from: try self.rawData())
        return result
    }

    /// Decode object of given type from JSON
    /// Created by Volkov Alexander on 05/02/19.
    ///
    /// - Returns: the decoded object
    /// - Throws: the decoding error
    public func decodeIt<T>() throws -> T where T : Decodable {
        let result = try JSONDecoder().decode(T.self, from: try self.rawData())
        return result
    }

    /// Convert to array of objects
    ///
    /// - Returns: the array
    public func toArray<T>() -> [T] where T : Decodable {
        let items: [T] = self.arrayValue.map { try? $0.decode(T.self) }.filter({$0 != nil}) as! [T]
        return items
    }
}
