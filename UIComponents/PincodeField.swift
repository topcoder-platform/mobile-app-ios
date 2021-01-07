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
    
    /// the colors
    @IBInspectable public var colorEmpty: UIColor = UIColor(0xE9E9E9) { didSet { self.setNeedsDisplay() } }
    @IBInspectable public var colorFilled: UIColor = UIColor(0x2A2A2A) { didSet { self.setNeedsDisplay() } }
    
    /// the height of the line
    @IBInspectable public var circleSize: CGFloat = 25 { didSet { self.setNeedsDisplay() } }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        textColor = .clear
    }
    
    /// Draw extra underline
    ///
    /// - Parameter rect: the rect to draw in
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        if self.text ?? "" == "" {
            colorEmpty.set()
        }
        else {
            colorFilled.set()
        }
        
        let c = self.bounds.center
        let path = UIBezierPath(ovalIn: CGRect(x: c.x - circleSize / 2, y: c.y - circleSize / 2, width: circleSize, height: circleSize))
        let currentContext = UIGraphicsGetCurrentContext()
        currentContext?.addPath(path.cgPath)
        currentContext?.drawPath(using: .fill)
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

extension CGRect {
    
    var center: CGPoint {
        return CGPoint(x: self.size.width / 2, y: self.size.height / 2)
    }
}
