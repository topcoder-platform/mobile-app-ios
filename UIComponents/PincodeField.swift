//
//  PincodeField.swift
//  UIComponents
//
//  Created by Volkov Alexander on 12/26/20.
//  Copyright © 2020 Volkov Alexander. All rights reserved.
//

import UIKit

/// Custom text field
@IBDesignable public class PincodeField: UITextField {
    
    /// the left padding
    @IBInspectable public var leftPadding: CGFloat = 0 { didSet { self.setNeedsLayout() } }
    
    /// the right padding
    @IBInspectable public var rightPadding: CGFloat = 3 { didSet { self.setNeedsLayout() } }
    
    /// the border color
    @IBInspectable public var customBorderColor: UIColor = UIColor(0x86b93b) { didSet { self.setNeedsDisplay() } }
    
    /// the height of the line
    @IBInspectable public var lineHeight: CGFloat = 2 { didSet { self.setNeedsDisplay() } }
    
    /// Draw extra underline
    ///
    /// - Parameter rect: the rect to draw in
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        customBorderColor.set()
        let currentContext = UIGraphicsGetCurrentContext()
        currentContext?.setLineWidth(lineHeight)
        currentContext?.move(to: CGPoint(x: 0, y: self.bounds.height - lineHeight/2))
        currentContext?.addLine(to: CGPoint(x: self.bounds.width, y: self.bounds.height - lineHeight/2))
        currentContext?.strokePath()
    }
    
    /// Text rectangle
    ///
    /// - Parameter bounds: the bounds
    /// - Returns: the rectangle
    override public func textRect(forBounds bounds: CGRect) -> CGRect {
        let originalRect: CGRect = super.editingRect(forBounds: bounds)
        return CGRect(x: originalRect.origin.x + leftPadding, y: originalRect.origin.y, width: originalRect.size.width - leftPadding - rightPadding, height: originalRect.size.height)
    }
    
    /// Editing rectangle
    ///
    /// - Parameter bounds: the bounds
    /// - Returns: the rectangle
    override public func editingRect(forBounds bounds: CGRect) -> CGRect {
        let originalRect: CGRect = super.editingRect(forBounds: bounds)
        return CGRect(x: originalRect.origin.x + leftPadding, y: originalRect.origin.y, width: originalRect.size.width - leftPadding - rightPadding, height: originalRect.size.height)
    }
}
