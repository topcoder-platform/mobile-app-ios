//
//  CustomButton.swift
//  UIComponents
//
//  Created by Volkov Alexander on 1/6/21.
//  Copyright © 2021 Volkov Alexander. All rights reserved.
//

import UIKit

/// Button with some changes according to design
@IBDesignable public class CustomButton: UIButton {
    
    /// the main color
    @IBInspectable public var mainTextColor: UIColor = UIColor(0xa5a5a5) { didSet { self.setNeedsLayout() } }
    @IBInspectable public var mainTintColor: UIColor = UIColor(0x777777) { didSet { self.setNeedsLayout() } }
    @IBInspectable public var selectedBgColor: UIColor = UIColor(0xf0f6e7) { didSet { self.setNeedsLayout() } }
    @IBInspectable public var selectedTextColor: UIColor = UIColor(0x86b93b) { didSet { self.setNeedsLayout() } }
    @IBInspectable public var selectedTintColor: UIColor = UIColor(0x86b93b) { didSet { self.setNeedsLayout() } }
    
    /// the border width
    @IBInspectable public var borderWidth: CGFloat = 1
    
    /// the border radius
    @IBInspectable public var borderRadius: CGFloat = 0
    
    
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
        if let title = self.title(for: .normal)?.uppercased() {
            let f = UIFont(name: "Barlow-SemiBold", size: 16)!
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
