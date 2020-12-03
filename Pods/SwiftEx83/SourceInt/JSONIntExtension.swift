//
//  JSONExtension.swift
//  SwiftExInt
//
//  Created by Volkov Alexander on 1/9/19.
//  Copyright (c) 2018-2019 Alexander Volkov. All rights reserved.
//

import Foundation
import SwiftyJSON
import RxSwift

// MARK: - SwiftyJSON extensions
extension JSON {
    
    /// Get JSON from resource file
    /// Created by Volkov Alexander on 21/10/16.
    ///
    /// - Parameter name: the resource name
    /// - Returns: JSON
    public static func resource(named name: String) -> JSON? {
        guard let resourceUrl = Bundle.main.url(forResource: name, withExtension: "json") else {
            fatalError("Could not find resource \(name)")
        }
        
        // create data from the resource content
        var data: Data
        do {
            data = try Data(contentsOf: resourceUrl, options: Data.ReadingOptions.dataReadingMapped) as Data
        } catch let error {
            print("ERROR: \(error)")
            return nil
        }
        // reading the json
        return try? JSON(data: data)
    }
    
    /// Get JSON resource as Observable
    ///
    /// - Parameter name: the resource name
    /// - Returns: the sequence
    public static func load(named name: String) -> Observable<JSON> {
        if let json = JSON.resource(named: name) {
            return Observable.just(json).share(replay: 1)
        }
        else {
            return Observable.error("ERROR: Wrong JSON format in \"\(name).json\"")
        }
    }
}
