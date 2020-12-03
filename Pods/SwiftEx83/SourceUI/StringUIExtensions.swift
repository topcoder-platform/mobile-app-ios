//
//  StringExtensions.swift
//  Pods-SwiftUIExample
//
//  Created by Volkov Alexander on 26.10.2019.
//

import Foundation

extension String {
    
    /// Get string from HTML
    public var htmlToString: String {
        return html?.string ?? ""
    }
    
    /// Get HTML attributed string
    public var html: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
}
