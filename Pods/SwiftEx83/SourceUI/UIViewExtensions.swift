//
//  UIViewExtensions.swift
//  SwiftEx
//
//  Created by Volkov Alexander on 2/15/19.
//

import UIKit

// MARK: - Borders
extension UIView {
    
    /// Add border for the view
    ///
    /// - Parameters:
    ///   - color: the border color
    ///   - borderWidth: the size of the border
    public func addBorder(color: UIColor = UIColor.lightGray, borderWidth: CGFloat = 0.5) {
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = color.cgColor
    }

    /// Make round corners for the view
    ///
    /// - Parameter radius: the radius of the corners
    public func roundCorners(_ radius: CGFloat = 4) {
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
    
    /// Make the view round
    public func round() {
        self.layoutIfNeeded()
        self.roundCorners(self.bounds.height / 2)
    }
    
    /// Add shadow view to superview
    ///
    /// - Parameters:
    ///   - shift: the shift
    ///   - opacity: the opacity
    ///   - color: the color
    ///   - cornerRaduis: the radius of the corners
    /// - Returns: the shadow view
    @discardableResult
    public func addShadowView(shift: CGFloat = 1, opacity: Float = 0.5, color: UIColor = UIColor.black, cornerRaduis: CGFloat = 0) -> UIView {
        let shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRaduis).cgPath
        let shadowView = UIView(frame: self.frame)
        self.superview?.addSubview(shadowView)
        self.superview?.sendSubview(toBack: shadowView)
        shadowView.backgroundColor = UIColor.black
        
        shadowView.layer.shadowColor = color.cgColor
        shadowView.layer.shadowOffset = CGSize(width: 0, height: shift)
        shadowView.layer.shadowOpacity = opacity
        shadowView.layer.shadowPath = shadowPath
        shadowView.isHidden = false
        return shadowView
    }
}
