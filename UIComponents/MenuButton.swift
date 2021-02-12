//
//  MenuButton.swift
//  UIComponents
//
//  Created by Volkov Alexander on 12/26/20.
//  Copyright © 2020 Volkov Alexander. All rights reserved.
//

import UIKit

/// Button with some changes according to design
@IBDesignable public class MenuButton: UIButton {
    
    /// the main color
    @IBInspectable public var mainTextColor: UIColor = UIColor.label.alpha(alpha: 0.84) { didSet { self.setNeedsLayout() } }
    @IBInspectable public var mainTintColor: UIColor = UIColor.clear { didSet { self.setNeedsLayout() } }
    @IBInspectable public var selectedBgColor: UIColor = UIColor.label.alpha(alpha: 0.09) { didSet { self.setNeedsLayout() } }
    @IBInspectable public var selectedTextColor: UIColor = UIColor.label.alpha(alpha: 0.84)   { didSet { self.setNeedsLayout() } }
    @IBInspectable public var selectedTintColor: UIColor = UIColor(0x137D60) { didSet { self.setNeedsLayout() } }
    
    /// the border width
    @IBInspectable public var borderWidth: CGFloat = 0
    
    /// the border radius
    @IBInspectable public var borderRadius: CGFloat = 1
    
    /// Draw extra underline
    ///
    /// - Parameter rect: the rect to draw in
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        if isSelected {
            selectedTintColor.set()
         
            let path = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 6, height: self.bounds.height))
            let c = UIGraphicsGetCurrentContext()
            c?.addPath(path.cgPath)
            c?.drawPath(using: .fill)
        }
    }
    
    /// Apply UI changes
    public override func layoutSubviews() {
        super.layoutSubviews()
        var white = UIColor.white
        if #available(iOS 13.0, *) {
            white = UIColor.systemBackground
        }
        self.layer.cornerRadius = borderRadius > 0 ? borderRadius : self.bounds.height / 2
        self.layer.borderColor = (isSelected ? UIColor.clear : mainTextColor).cgColor
        self.layer.borderWidth = borderWidth
        self.layer.masksToBounds = true
        self.backgroundColor = isSelected ? selectedBgColor : white
        
        let textColor = isSelected ? selectedTextColor : mainTextColor
        self.setTitleColor(textColor, for: .normal)
        if let title = self.title(for: .normal) {
            let f = UIFont(name: isSelected ? "Roboto-Bold" : "Roboto-Regular", size: 18)!
            setAttributedTitle(NSAttributedString(string: title, attributes: [.font: f, .foregroundColor: textColor]), for: .normal)
        }
        self.tintColor = isSelected ? selectedTintColor : mainTintColor
        if isHighlighted {
            self.backgroundColor = self.backgroundColor?.alpha(alpha: 0.5)
        }
        tintColor = self.titleColor(for: .normal)
        if !isEnabled {
            self.backgroundColor = self.backgroundColor?.alpha(alpha: 0.2)
        }
    }
}
