//
//  DataExtensions.swift
//  Alamofire
//
//  Created by Volkov Alexander on 11/6/18.
//  Copyright (c) 2018-2019 Alexander Volkov. All rights reserved.
//

import Foundation


// MARK: - Shortcut methods for Data
extension Data {

    /// Hexadecimal string
    public var hex: String? {
        return map { String(format: "%02hhx", $0) }.joined()
    }
}
