//
//  RoundView.swift
//  UIComponents
//
//  Created by Volkov Alexander on 12/27/20.
//  Copyright © 2020 Volkov Alexander. All rights reserved.
//

import UIKit

/// Round view
@IBDesignable public class RoundView: UIButton {
    
    @IBInspectable public var isVertical: Bool = false { didSet { setNeedsLayout() }}
    
    /// the border radius
    @IBInspectable public var borderRadius: CGFloat = -1 { didSet { self.setNeedsLayout() } }
    
    /// Apply UI changes
    public override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = borderRadius > 0 ? borderRadius : ((isVertical ? self.bounds.width : self.bounds.height) / 2)
        self.layer.masksToBounds = true
    }
}
