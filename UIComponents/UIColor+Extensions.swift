//
//  UIColor+Extensions.swift
//  UIComponents
//
//  Created by Volkov Alexander on 12/26/20.
//  Copyright © 2020 Volkov Alexander. All rights reserved.
//

import UIKit

/**
 * Extends UIColor with helpful methods
 *
 * - author: Alexander Volkov
 * - version: 1.0
 */
extension UIColor {
    
    /// Creates new color with RGBA values from 0-255 for RGB and a from 0-1
    ///
    /// - Parameters:
    ///   - r: the red color
    ///   - g: the green color
    ///   - b: the blue color
    ///   - a: the alpha color
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat = 1) {
        self.init(red: r / 255, green: g / 255, blue: b / 255, alpha: a)
    }
    
    /// Create color with RGB value in 16-format, e.g. 0xFF0000 -> red color
    ///
    /// - Parameter hex: the color in hex
    convenience init(_ hex: Int) {
        let components = (
            r: CGFloat((hex >> 16) & 0xff) / 255,
            g: CGFloat((hex >> 08) & 0xff) / 255,
            b: CGFloat((hex >> 00) & 0xff) / 255
        )
        self.init(red: components.r, green: components.g, blue: components.b, alpha: 1)
    }
    
    /**
     Get same color with given transparancy
     
     - parameter alpha: the alpha channel
     
     - returns: the color with alpha channel
     */
    func alpha(alpha: CGFloat) -> UIColor {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b :CGFloat = 0
        if (self.getRed(&r, green:&g, blue:&b, alpha:nil)) {
            return UIColor(red: r, green: g, blue: b, alpha: alpha)
        }
        return self
    }
}
