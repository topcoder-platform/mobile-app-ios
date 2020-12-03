//
//  UILabelExtensions.swift
//  SwiftEx
//
//  Created by Volkov Alexander on 11/6/16.
//  Copyright (c) 2016-2019 Alexander Volkov. All rights reserved.
//

import UIKit

/**
 * Helpful methods in UILabel
 *
 * - author: Volkov Alexander
 * - version: 1.0
 */
extension UILabel {

    /// Updates line spacing in the label
    ///
    /// - Parameter lineSpacing: the linespacing
    public func setLineSpacing(lineSpacing: CGFloat) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = lineSpacing
        paragraphStyle.alignment = self.textAlignment
        if let attributedString = self.attributedText as? NSMutableAttributedString {
            attributedString.addAttributes([.paragraphStyle: paragraphStyle], range: NSMakeRange(0, attributedString.length))
            self.attributedText = attributedString
        }
        else {
            let attributedString = NSMutableAttributedString(string: self.text ?? "", attributes: [
                .paragraphStyle: paragraphStyle,
                .foregroundColor: self.textColor,
                .font: UIFont(name: self.font.fontName, size: self.font.pointSize)!
                ])
            self.attributedText = attributedString
        }
    }

    /// Updates letter spacing in the label
    ///
    /// - Parameter letterSpacing: the letter spacing
    public func set(letterSpacing: CGFloat) {
        let attributedString = NSMutableAttributedString(string: self.text ?? "", attributes: [
            NSAttributedString.Key.kern: letterSpacing,
            NSAttributedString.Key.foregroundColor: self.textColor,
            NSAttributedString.Key.font: UIFont(name: self.font.fontName, size: self.font.pointSize)!
            ])
        self.attributedText = attributedString
    }
    
    /// Update font and color for the label
    ///
    /// - Parameters:
    ///   - font: the font
    ///   - color: the color
    public func set(font: String, color: UIColor) {
        let string = NSAttributedString(string: self.text ?? "", attributes: [.font: UIFont(name: font, size: self.font.pointSize)!, .foregroundColor: color])
        self.attributedText = string
    }
}
