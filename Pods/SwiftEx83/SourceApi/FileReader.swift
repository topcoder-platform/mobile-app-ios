//
//  FileReader.swift
//  SwiftEx
//
//  Created by Volkov Alexander on 05.11.2019.
//

import Foundation

// File reader
/*
 ```
 do {
    let limit = 3
    try FileReader(filePath: "/Users/volk/.../myFile.csv", limit: limit)
        .process{ (str, k) in
            print("line \(k): \(str)")
        }
 }
 catch let error {
    print("ERROR: \(error)")
 }
 ```
 */
public class FileReader {
    
    // Error
    public struct FileError: Error {
        public let error: String
        
        var localizedDescription: String {
            return error
        }
    }
    
    // The limit used to
    public let kLimit: Int
    private let filePath: String
    
    /// Initializer
    ///
    /// - Parameters:
    ///   - filePath: the path to the file to read
    ///   - limit: the maximum number of lines to read
    public init(filePath: String, limit: Int = 10000) {
        self.filePath = filePath
        self.kLimit = limit
    }
    
    /// Process lines one-by-one
    ///
    /// - Parameter lineProcessor: the callback used to process next line (called synchronously).
    ///                            Second parameter is the index of line, e.g. 0, 1, 2, 3, ...
    public func process(_ lineProcessor: (String, Int)->()) throws {
        guard let url = URL(string: filePath) else { throw FileError(error: "Cannot read file \(filePath)") }
        guard let reader = StreamReader(url: url) else { throw FileError(error: "Cannot read file \(filePath)") }
        
        var k = 0
        var string: String? = nil
        repeat {
            // Read next line
            string = reader.nextLine()
            guard let str = string else { break }
        
            // Process
            lineProcessor(str, k)
            
            // Check limit
            k += 1
            if k >= kLimit { break }
        } while true
    }
}
