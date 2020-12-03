//
//  UINavigationControllerExtensions.swift
//  SwiftEx
//
//  Created by Volkov Alexander on 10/19/17.
//

import UIKit

/**
 * Extension adds methods that change navigation bar
 *
 * @author Volkov Alexander
 * @version 1.0
 */
extension UIViewController {

    /// Changes navigation bar design
    ///
    /// - Parameters:
    ///   - isTransparent: true - if need to have transparent navigation bar, false - else
    ///   - buttonColor: the button color
    ///   - bgColor: if NON-transparent, then background color
    ///   - bgImage: if NON-transparent, then background image
    ///   - shadowImage: if NON-transparent, then shadow image
    public func setupNavigationBar(isTransparent: Bool = false, buttonColor: UIColor = UIColor.white, bgColor: UIColor = UIColor.black, bgImage: UIImage? = nil, shadowImage: UIImage? = nil) {
        navigationController!.navigationBar.tintColor = buttonColor
        navigationController?.navigationBar.barTintColor = isTransparent ? .clear : bgColor
        navigationController?.navigationBar.setBackgroundImage(isTransparent ? UIImage() : bgImage, for: UIBarMetrics.default)
        navigationController?.navigationBar.isTranslucent = isTransparent
        if isTransparent {
            navigationController?.navigationBar.shadowImage = UIImage()
        }
        else if let shadowImage = shadowImage {
            navigationController?.navigationBar.shadowImage = shadowImage
        }
    }

    /// Add left navigation bar button
    ///
    /// - Parameters:
    ///   - image: the image
    ///   - action: the action
    public func addLeftNavigationBarButton(image: UIImage, action: Selector) {
        navigationController?.navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: action)
    }
}

// MARK: - UINavigationController extensions
extension UINavigationController {
    
    /// Remove given view controller from navigation stack
    public func remove<T: UIViewController>(_ clazz: T.Type) {
        self.setViewControllers(viewControllers.filter({!($0 is T)}), animated: false)
    }
}
