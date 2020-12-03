//
//  HelpfulFunctions.swift
//  SwiftEx
//
//  Created by Alexander Volkov on 31/12/18.
//  Copyright (c) 2019 Alexander Volkov. All rights reserved.
//

import Foundation

/**
 A set of helpful functions and extensions
 */

// MARK: - allow throw strings
extension String: LocalizedError {
    public var errorDescription: String? {
        return NSLocalizedString(self, comment: self)
    }
}

/// Delay execution
///
/// - Parameters:
///   - delay: the delay in seconds
///   - callback: the callback to invoke after 'delay' seconds
public func execute(after delay: TimeInterval, _ callback: @escaping ()->()) {
    #if os(Linux)
    callback()
    #else
    let delay = delay * Double(NSEC_PER_SEC)
    let popTime = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC);
    DispatchQueue.main.asyncAfter(deadline: popTime, execute: {
        callback()
    })
    #endif
}

/// shortcut for `execute(after:callback)`
public func delay(_ delay: TimeInterval, _ callback: @escaping ()->()) {
    execute(after: delay, callback)
}

/*
 Thanks to siejkowski for `Optionable`
 https://gist.github.com/siejkowski/a2b187800f2e28b53c96
 */

// Optionable protocol exposes the subset of functionality required for flatten definition
public protocol Optionable {
    associatedtype Wrapped
    var value: Wrapped? { get }
}

// extension for Optional provides the implementations for Optional enum
extension Optional : Optionable {
    public var value: Wrapped? { return self  }
}

extension LazySequenceProtocol where Self.Iterator.Element : Optionable {
    public func flatten() -> [Self.Iterator.Element.Wrapped] {
        return compactMap { $0.value }
    }
}

// MARK: - Helpful methods for flattening dictionary
extension Dictionary where Value: Optionable {

    /// flatten dictionary
    public func flatten() -> [Key: Value.Wrapped] {
        return self.filter({ (k, v) in
            return v.value != nil
        }).mapValues({$0.value!})
    }
}

// MARK: - Helpful methods for using dictionary in URL
extension Dictionary {

    /// Create url string from Dictionary
    ///
    /// - Returns: the url string
    public func toURLString() -> String {
        var urlString = ""

        // Iterate all key,value and form the url string
        for (key, value) in self {
            let keyEncoded = ("\(key)").addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            let valueEncoded = ("\(value)").addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
            urlString += ((urlString == "") ? "" : "&") + keyEncoded + "=" + valueEncoded
        }
        return urlString
    }
}

// MARK: - Helpful methods in NSRange
extension NSRange {
    
    /// Convert to Range for given string
    ///
    /// - Parameter string: the string
    /// - Returns: range
    public func toRange(string: String) -> Range<String.Index> {
        let range = string.index(string.startIndex, offsetBy: self.lowerBound)..<string.index(string.startIndex, offsetBy: self.upperBound)
        return range
    }
    
    /// Create NSRange from Range<String.Index>
    ///
    /// - Parameters:
    ///   - range: Range<String.Index>
    ///   - string: the related string
    /// - Returns: NSRange
    public static func from(range: Range<String.Index>, inString string: String) -> NSRange {
        let s = string.distance(from: string.startIndex, to: range.lowerBound)
        let e = string.distance(from: string.startIndex, to: range.upperBound)
        return NSMakeRange(s, e-s)
    }
}
