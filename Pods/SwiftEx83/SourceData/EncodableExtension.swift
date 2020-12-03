//
//  EncodableExtension.swift
//  SwiftExData
//
//  Created by Volkov Alexander on 3/14/19.
//  Copyright (c) 2019 Alexander Volkov. All rights reserved.
//

import Foundation
import SwiftyJSON

/// Helpful methods for converting Encodable classes
extension Encodable {
    
    /// Convert to parameters
    func asParameters() -> [String: Any] {
        return dictionary()
    }
    
    /// Convert object to another type using intermidiate JSON object
    ///
    /// - Returns: the decoded object
    public func convert<T>() -> T where T : Decodable {
        let data = try! JSONEncoder().encode(self)
        let json = try! JSON(data: data)
        let result = try! JSONDecoder().decode(T.self, from: try json.rawData())
        return result
    }
    
    /// Convert object to another type using intermidiate JSON object
    ///
    /// - Returns: the decoded object
    public func convertTry<T>() throws -> T where T : Decodable {
        let data = try JSONEncoder().encode(self)
        let json = try JSON(data: data)
        let result = try JSONDecoder().decode(T.self, from: try json.rawData())
        return result
    }
    
    // Clone object
    public func clone<T>() -> T where T : Decodable {
        return convert()
    }
    
    /// Convert to dictionary (to use as parameters)
    public func dictionary() -> [String: Any] {
        do {
            let data = try JSONEncoder().encode(self)
            let json = try JSON(data: data)
            let dic = json.dictionaryObject ?? [:]
            return dic
        }
        catch let error {
            fatalError(error.localizedDescription)
        }
    }
    
    /// Convert object to JSON data
    public func data() throws -> Data {
        return try JSONEncoder().encode(self)
    }
    
    /// Convert object to JSON
    public func json() throws -> JSON {
        return try JSON(data: data())
    }
}
