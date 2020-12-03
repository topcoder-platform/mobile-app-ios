//
//  InputStreamReader.swift
//  SwiftEx
//
//  Created by Volkov Alexander on 06.11.2019.
//

import Foundation

/*
 let input = try InputStreamReader(filePath: filePath)
 var sum: Double = 0
 var count = 0
 var headerPassed = false
 try input
    .log(every: 10000)
    .process { (str, k) in
     let a = str.split(separator: ",")
     //        print(a[1])
     if headerPassed {
         sum += Double(a[1])!
         count += 1
     }
     else {
        headerPassed = true
     }
 }
 let mean = sum / Double(count)
 print("mean: \(mean)")
 */
public class InputStreamReader {
    
    private let input: InputStream
    let encoding: String.Encoding
    let chunkSize: Int
    var buffer: Data
    let delimPattern : Data
    var isAtEOF: Bool = false
    
    // The limit used to
    public var kLimit: Int = 1000000000
    public var logEvery: Int? // if provided, then will print "Lines proccessed: X" every `logEvent` line
    private var nextLogLine: Int = -1
    
    public convenience init(filePath: String) throws {
        guard let input = InputStream(fileAtPath: filePath) else { throw InputStreamError(message: "Cannot initialize InputStream with filePath=\(filePath)")}
        self.init(input)
    }
    
    public convenience init(url: URL) throws {
        guard let input = InputStream(url: url) else { throw InputStreamError(message: "Cannot initialize InputStream with url=\(url)")}
        self.init(input)
    }
    
    public init(_ input: InputStream, delimeter: String = "\n", encoding: String.Encoding = .utf8, chunkSize: Int = 4096) {
        self.input = input
        input.open()
        delimPattern = delimeter.data(using: .utf8)!
        self.encoding = encoding
        self.chunkSize = chunkSize
        buffer = Data(capacity: chunkSize)
    }
    
    // Error
    public struct InputStreamError: Error {
        public let message: String
    }
    
    deinit {
        input.close()
    }
    
    /// Get next line
    ///
    /// - Returns: nil if EoF, else next string
    public func nextLine() throws -> String? {
        if isAtEOF { return nil }
        
        repeat {
            // Search for delimiter
            if let range = buffer.range(of: delimPattern, options: [], in: buffer.startIndex..<buffer.endIndex) {
                let subData = buffer.subdata(in: buffer.startIndex..<range.lowerBound)
                let line = String(data: subData, encoding: encoding)
                buffer.replaceSubrange(buffer.startIndex..<range.upperBound, with: []) // remove read line with ""
                return line
            } else {
                let bufferSize = chunkSize
                let tmpBuffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
                defer {
                    tmpBuffer.deallocate()
                }
                if input.hasBytesAvailable {
                    let read = input.read(tmpBuffer, maxLength: chunkSize)
                    if read > 0 {
                        buffer.append(tmpBuffer, count: read)
                        continue
                    }
                    else if let error = input.streamError, read < 0 {
                        throw error
                    }
                    // EoF
                }
                // End of file
                isAtEOF = true
                return (buffer.count > 0) ? String(data: buffer, encoding: encoding) : nil
            }
        } while true
    }
    
    /// Process lines one-by-one
    ///
    /// - Parameter lineProcessor: the callback used to process next line (called synchronously).
    ///                            Second parameter is the index of line, e.g. 0, 1, 2, 3, ...
    public func process(_ lineProcessor: (String, Int)->()) throws {
        var k = 0
        var string: String? = nil
        let step = logEvery ?? kLimit
        nextLogLine = step
        repeat {
            // Read next line
            string = try self.nextLine()
            guard let str = string else { break }
            
            // Process
            lineProcessor(str, k)
            
            // Check limit
            k += 1
            if nextLogLine <= k {
                nextLogLine += step
                print("Line processed: \(k)")
            }
            if k >= kLimit { break }
        } while true
    }
    
    public func log(every: Int) -> InputStreamReader {
        logEvery = every
        return self
    }
}
