//
//  UIExtensions.swift
//  SwiftEx
//
//  Created by Alexander Volkov on 04/16/15.
//  Copyright © 2015-2018 Alexander Volkov. All rights reserved.
//

import UIKit

/**
 A set of helpful extensions for classes from UIKit
 */

// MARK: - Color

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
    public convenience init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat = 1) {
        self.init(red: r / 255, green: g / 255, blue: b / 255, alpha: a)
    }

    /// Create color with RGB value in 16-format, e.g. 0xFF0000 -> red color
    ///
    /// - Parameter hex: the color in hex
    public convenience init(_ hex: Int) {
        let components = (
            r: CGFloat((hex >> 16) & 0xff) / 255,
            g: CGFloat((hex >> 08) & 0xff) / 255,
            b: CGFloat((hex >> 00) & 0xff) / 255
        )
        self.init(red: components.r, green: components.g, blue: components.b, alpha: 1)
    }

    /**
     Creates new color with RGBA values from 0-255 for RGB and a from 0-1

     - parameter g: the gray color
     - parameter a: the alpha color
     */
    public convenience init(gray: CGFloat, a: CGFloat = 1) {
        self.init(r: gray, g: gray, b: gray, a: a)
    }

    /**
     Get UIColor from hex string, e.g. "FF0000" -> red color

     - parameter hexString: the hex string
     - returns: the UIColor instance or nil
     */
    public class func fromString(_ hexString: String) -> UIColor? {
        if hexString.count == 6 {
            let redStr = hexString[..<hexString.index(hexString.startIndex, offsetBy: 2)]
            let greenStr = hexString[hexString.index(hexString.startIndex, offsetBy: 2)..<hexString.index(hexString.startIndex, offsetBy: 4)]
            let blueStr = hexString[hexString.index(hexString.startIndex, offsetBy: 4)..<hexString.index(hexString.startIndex, offsetBy: 6)]
            return UIColor(
                r: CGFloat(Int(redStr, radix: 16)!),
                g: CGFloat(Int(greenStr, radix: 16)!),
                b: CGFloat(Int(blueStr, radix: 16)!))
        }
        return nil
    }

    /**
     Get same color with given transparancy

     - parameter alpha: the alpha channel

     - returns: the color with alpha channel
     */
    public func alpha(alpha: CGFloat) -> UIColor {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b :CGFloat = 0
        if (self.getRed(&r, green:&g, blue:&b, alpha:nil)) {
            return UIColor(red: r, green: g, blue: b, alpha: alpha)
        }
        return self
    }

    /// Convert to string, e.g. "#FF0000"
    ///
    /// - Returns: the string
    public func toString() -> String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let redStr = Int(red * alpha * 255 + 255 * (1 - alpha)).toHex()
        let greenStr = Int(green * alpha * 255 + 255 * (1 - alpha)).toHex()
        let blueStr = Int(blue * alpha * 255 + 255 * (1 - alpha)).toHex()
        return "#\(redStr)\(greenStr)\(blueStr)"
    }
}

// MARK: - Transitions

/**
 View transition type (from corresponding side)
 */
public enum Transition {
    case right, left, bottom, none

    /// The reverse Transition to given
    ///
    /// - Returns: Transition
    public func reverse() -> Transition {
        switch self {
        case .right:
            return .left
        case .left:
            return .right
        default:
            return .none
        }
    }
}

/**
 * Methods for loading and removing a view controller and its views,
 * and shortcut helpful methods for instantiating UIViewController
 *
 * - author: Alexander Volkov
 * - version: 1.0
 */
extension UIViewController {

    /**
     Show view controller from the side.
     See also dismissViewControllerToSide()

     - parameter viewController: the view controller to show
     - parameter side:           the side to move the view controller from
     - parameter bounds:         the bounds of the view controller
     - parameter callback:       the callback block to invoke after the view controller is shown and stopped
     */
    public func showViewControllerFromSide(_ viewController: UIViewController,
                                           inContainer containerView: UIView, bounds: CGRect, side: Transition, _ callback:(()->())?) {
        // New view
        let toView = viewController.view!

        // Setup bounds for new view controller view
        toView.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleHeight]
        var frame = bounds
        frame.origin.y = containerView.frame.height - bounds.height
        switch side {
        case .bottom:
            frame.origin.y = containerView.frame.size.height // From bottom
        case .left:
            frame.origin.x = -containerView.frame.size.width // From left
        case .right:
            frame.origin.x = containerView.frame.size.width // From right
        default:break
        }
        toView.frame = frame

        self.addChild(viewController)
        containerView.addSubview(toView)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 1.0, options: .curveEaseOut, animations: { () -> Void in
                        switch side {
                        case .bottom:
                            frame.origin.y = containerView.frame.height - bounds.height + bounds.origin.y
                        case .left, .right:
                            frame.origin.x = 0
                        default:break
                        }
                        toView.frame = frame
        }) { (fin: Bool) -> Void in
            viewController.didMove(toParent: self)
            callback?()
        }
    }

    /**
     Dismiss the view controller through moving it back to given side
     See also showViewControllerFromSide()

     - parameter viewController: the view controller to dismiss
     - parameter side:           the side to move the view controller to
     - parameter callback:       the callback block to invoke after the view controller is dismissed
     */
    public func dismissViewControllerToSide(_ viewController: UIViewController, side: Transition, _ callback:(()->())?) {
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 1.0, options: .curveEaseOut, animations: { () -> Void in
                        // Move back to bottom
                        switch side {
                        case .bottom:
                            viewController.view.frame.origin.y = self.view.frame.height
                        case .left:
                            viewController.view.frame.origin.x = -self.view.frame.size.width
                        case .right:
                            viewController.view.frame.origin.x = self.view.frame.size.width
                        default:break
                        }

        }) { (fin: Bool) -> Void in
            viewController.remove()
            callback?()
        }
    }

    /// Replace given view controller with another view controller from a side with animation
    ///
    /// - Parameters:
    ///   - viewController: the view controller to replace
    ///   - newViewController: the view controller to load
    ///   - containerView: the container view
    ///   - bounds: the bounds of the view controller (if nil, them containerView bounds are used)
    ///   - side: the side to animate from, if nil, then no animation
    ///   - callback: the callback to invoke when animation finished
    public func replaceFromSide(_ viewController: UIViewController?, withViewController newViewController: UIViewController,
                                inContainer containerView: UIView, bounds: CGRect? = nil, side: Transition?, _ callback:(()->())?) {
        let bounds = bounds ?? containerView.bounds
        if let side = side {
            self.showViewControllerFromSide(newViewController, inContainer: containerView, bounds: bounds, side: side, callback)
            if let vc = viewController {
                self.dismissViewControllerToSide(vc, side: side.reverse(), nil)
            }
        }
        else {
            self.loadViewController(newViewController, containerView)
            viewController?.remove()
            callback?()
        }
        self.view.layoutIfNeeded()
    }

    /**
     Add the view controller and view into the current view controller
     and given containerView correspondingly.
     Uses autoconstraints.

     - parameter childVC:       view controller to load
     - parameter containerView: view to load into
     */
    public func loadViewController(_ childVC: UIViewController, _ containerView: UIView) {
        let childView = childVC.view
        childView?.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth,  UIView.AutoresizingMask.flexibleHeight]
        loadViewController(childVC, containerView, withBounds: containerView.bounds)
    }

    /// Load view controller and add connstraints
    ///
    /// - Parameters:
    ///   - childVC: the view controller
    ///   - containerView: the container view
    public func loadViewControllerWithConstraints(_ childVC: UIViewController, _ containerView: UIView) {
        guard let childView = childVC.view else { return }
        childView
            .translatesAutoresizingMaskIntoConstraints = false
        loadViewController(childVC, containerView, withBounds: containerView.bounds)
        containerView.addConstraint(NSLayoutConstraint(item: childView,
                                                       attribute: .top,
                                                       relatedBy: .equal,
                                                       toItem: containerView,
                                                       attribute: .top,
                                                       multiplier: 1.0,
                                                       constant: 0))
        containerView.addConstraint(NSLayoutConstraint(item: childView,
                                                       attribute: .leading,
                                                       relatedBy: .equal,
                                                       toItem: containerView,
                                                       attribute: .leading,
                                                       multiplier: 1.0,
                                                       constant: 0))
        containerView.addConstraint(NSLayoutConstraint(item: childView,
                                                       attribute: .trailing,
                                                       relatedBy: .equal,
                                                       toItem: containerView,
                                                       attribute: .trailing,
                                                       multiplier: 1.0,
                                                       constant: 0))
        containerView.addConstraint(NSLayoutConstraint(item: childView,
                                                       attribute: .bottom,
                                                       relatedBy: .equal,
                                                       toItem: containerView,
                                                       attribute: .bottom,
                                                       multiplier: 1.0,
                                                       constant: 0))
    }

    /**
     Add the view controller and view into the current view controller
     and given containerView correspondingly.
     Sets fixed bounds for the loaded view in containerView.
     Constraints can be added manually or automatically.

     - parameter childVC:       view controller to load
     - parameter containerView: view to load into
     - parameter bounds:        the view bounds
     */
    public func loadViewController(_ childVC: UIViewController, _ containerView: UIView, withBounds bounds: CGRect) {
        let childView = childVC.view

        childView?.frame = bounds

        // Adding new VC and its view to container VC
        self.addChild(childVC)
        containerView.addSubview(childView!)

        // Finally notify the child view
        childVC.didMove(toParent: self)
    }

    /// Remove view controller and view from their parents
    public func remove() {
        self.willMove(toParent: nil)
        self.view.removeFromSuperview()
        self.removeFromParent()
    }

    /**
     Instantiate given view controller.
     The method assumes that view controller is identified the same as its class
     and view is defined in the same storyboard.

     - parameter viewControllerClass: the class name
     - parameter storyboardName:      the name of the storyboard (optional)

     - returns: view controller or nil
     */
    public func create<T: UIViewController>(_ viewControllerClass: T.Type, storyboardName: String? = nil) -> T? {
        let className = NSStringFromClass(viewControllerClass).components(separatedBy: ".").last!
        var storyboard = self.storyboard
        if let storyboardName = storyboardName {
            storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        }
        return storyboard?.instantiateViewController(withIdentifier: className) as? T
    }

    /**
     Instantiate given view controller and push into navigation stack

     - parameter viewControllerClass: the class name
     - parameter storyboardName:      the name of the storyboard (optional)

     - returns: view controller or nil
     */
    @discardableResult
    public func pushViewController<T: UIViewController>(_ viewControllerClass: T.Type, storyboardName: String? = nil) -> T? {
        if let vc = create(viewControllerClass, storyboardName: storyboardName) {
            self.navigationController?.pushViewController(vc, animated: true)
            return vc
        }
        return nil
    }

    /**
     Instantiate given view controller.
     The method assumes that view controller is identified the same as its class
     and view is defined in "Main" storyboard.

     - parameter viewControllerClass: the class name

     - returns: view controller or nil
     */
    public class func createFromMainStoryboard<T: UIViewController>(_ viewControllerClass: T.Type) -> T? {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let className = NSStringFromClass(viewControllerClass).components(separatedBy: ".").last!
        return storyboard.instantiateViewController(withIdentifier: className) as? T
    }

    /// Get currently opened view controller
    ///
    /// - Returns: the top visible view controller
    public class func getCurrentViewController() -> UIViewController? {

        // If the root view is a navigation controller, we can just return the visible ViewController
        let vc: UIViewController? = getNavigationController()?.visibleViewController

        // Otherwise, we must get the root UIViewController and iterate through presented views
        if let rootController = vc ?? UIApplication.shared.keyWindow?.rootViewController {

            var currentController: UIViewController! = rootController

            // Each ViewController keeps track of the view it has presented, so we
            // can move from the head to the tail, which will always be the current view
            while( currentController.presentedViewController != nil ) {
                currentController = currentController.presentedViewController
            }
            return currentController
        }
        return nil
    }

    /// Returns the navigation controller if it exists
    ///
    /// - Returns: the navigation controller or nil
    public class func getNavigationController() -> UINavigationController? {
        if let navigationController = UIApplication.shared.keyWindow?.rootViewController  {
            return navigationController as? UINavigationController
        }
        return nil
    }

    /**
     Wraps the given view controller into NavigationController

     - returns: NavigationController instance
     */
    public func wrapInNavigationController() -> UINavigationController {
        let navigation = UINavigationController(rootViewController: self)
        navigation.navigationBar.isTranslucent = false
        return navigation
    }

    /// Update navigation stack to contain only first and last view controllers
    public func cleanNavigationStack() {
        if let list = self.navigationController?.viewControllers {
            if list.count > 1 {
                let updatedStack = [list.last!]
                self.navigationController?.setViewControllers(updatedStack, animated: false)
            }
        }
    }
}


// MARK: - Helpful deallocation check methods
extension UIViewController {
    
    /// Initiate deallocation check.
    ///
    /// Usage:
    /// ```
    ///        override func viewDidDisappear(_ animated: Bool) {
    ///            super.viewDidDisappear(animated)
    ///            debugCheckDeallocation()
    ///       }
    /// ```
    ///
    /// - Parameter delay: the delay used to check if deallocation happened
    public func debugCheckDeallocation(afterDelay delay: TimeInterval = 2.0) {
        let rootParentViewController = debugRootParentViewController
    
        if isMovingFromParent || rootParentViewController.isBeingDismissed {
            let typeClass = type(of: self)
            let disappearanceSource: String = isMovingFromParent ? "removed from its parent" : "dismissed"
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: { [weak self] in
                assert(self == nil, "\(typeClass) not deallocated after being \(disappearanceSource)")
            })
        }
    }
    
    private var debugRootParentViewController: UIViewController {
        var root = self
        
        while let parent = root.parent {
            root = parent
        }
        
        return root
    }
}

// MARK: - Alerts and Progress indicators

/**
 * Extension to display alerts
 *
 * - author: Alexander Volkov
 * - version: 1.0
 */
extension UIViewController {

    /// Displays alert with specified title & message
    ///
    /// - Parameters:
    ///   - title: the title
    ///   - message: the message
    ///   - completion: the completion callback
    public func showAlert(_ title: String, _ message: String, completion: (()->())? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default,
                                      handler: { (_) -> Void in
                                        alert.dismiss(animated: true, completion: nil)
                                        DispatchQueue.main.async {
                                            completion?()
                                        }
        }))
        self.present(alert, animated: true, completion: nil)
    }

    /// Show activity indicator view
    ///
    /// - Parameter view: the parent view
    /// - Returns: the activity indicator view
    public func showActivityIndicator(_ view: UIView? = nil) -> ActivityIndicator? {
        return ActivityIndicator(parentView: view ?? UIViewController.getCurrentViewController()?.view ?? self.view).start()
    }
}

/// Shows an alert with the title and message.
///
/// - Parameters:
///   - title: the title
///   - message: the message
///   - completion: the completion callback
public func showAlert(_ title: String, message: String, completion: (()->())? = nil) {
    UIViewController.getCurrentViewController()?.showAlert(title, message, completion: completion)
}

/// Show alert with given error message
///
/// - Parameters:
///   - errorMessage: the error message
///   - completion: the completion callback
public func showError(errorMessage: String, completion: (()->())? = nil) {
    if Thread.isMainThread {
        showAlert(NSLocalizedString("Error", comment: "Error alert title"), message: errorMessage, completion: completion)
    }
    else {
        DispatchQueue.main.async {
            showAlert(NSLocalizedString("Error", comment: "Error alert title"), message: errorMessage, completion: completion)
        }
    }
}

/// Show alert message about stub functionalify
public func showStub() {
    showAlert("Stub", message: "This feature will be implemented in future")
}

/**
 * Activity indicator view
 *
 * - author: Alexander Volkov
 * - version: 1.0
 */
public class ActivityIndicator: UIView {

    private var activityIndicator: UIActivityIndicatorView!
    private var stopped = false
    private var didShow = false
    private var parentView: UIView?

    /// Initializer
    ///
    /// - Parameters:
    ///   - parentView: the parent view
    ///   - isDark: true - will make the content dark, false - no changes in content
    public init(parentView: UIView?, isDark: Bool = true) {
        super.init(frame: parentView?.bounds ?? UIScreen.main.bounds)

        self.parentView = parentView

        configureIndicator(isDark: isDark)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Configure indicator and changes colors
    ///
    /// - Parameter isDark: true - will make the content dark, false - no changes in content
    private func configureIndicator(isDark: Bool) {
        activityIndicator = UIActivityIndicatorView()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(activityIndicator)
        self.addConstraint(NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: activityIndicator, attribute: .centerX, multiplier: 1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: activityIndicator, attribute: .centerY, multiplier: 1, constant: 0))
        if isDark {
            activityIndicator.color = .white
            activityIndicator.tintColor = .white
            self.backgroundColor = UIColor(white: 0.0, alpha: 0.7)
        }
        else {
            activityIndicator.color = .gray
            activityIndicator.tintColor = .gray
            self.backgroundColor = UIColor.clear
        }
        self.alpha = 0.0
    }

    /// Removes the indicator
    public func stop() {
        stopped = true
        if !didShow { return }
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0.0
        }, completion: { success in
            self.activityIndicator.stopAnimating()
            self.removeFromSuperview()
        })
    }

    /// Show
    /// Usage: `let indicator = ActivityIndicator().start()`
    ///
    /// - Returns: self
    public func start() -> ActivityIndicator {
        didShow = true
        if !stopped {
            if let view = parentView {
                self.translatesAutoresizingMaskIntoConstraints = false
                view.addSubview(self)
                view.addConstraint(NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0))
                view.addConstraint(NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0))
                view.addConstraint(NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0))
                view.addConstraint(NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0))
                return self
            }
            if #available(iOS 13.0, *) {
                (UIApplication.shared.delegate?.window
                    ??
                    (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first)?
                    .addSubview(self)
            } else {
                UIApplication.shared.delegate?.window!?.addSubview(self)
            }
        }
        return self
    }

    /// Change alpha after the view is shown
    override public func didMoveToSuperview() {
        activityIndicator.startAnimating()
        UIView.animate(withDuration: 0.3) {
            self.alpha = 0.75
        }
    }
}


// MARK: - Navigation Bar
/**
 * Extension adds methods that change navigation bar
 *
 * - author: Alexander Volkov
 * - version: 1.0
 */
extension UIViewController {

    /// Add right button to the navigation bar
    ///
    /// - Parameters:
    ///   - image: the image
    ///   - selector: the selector to invoke when tapped
    ///   - xOffset: Ox offset
    ///   - yOffset: Oy offset
    public func addRightButton(image: UIImage, selector: Selector, xOffset: CGFloat = 0, yOffset: CGFloat = 0) {
        // Right navigation button
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView:
            createBarButton(image, selector: selector, xOffset: xOffset, yOffset: yOffset))
    }

    /// Create button for the navigation bar
    ///
    /// - Parameters:
    ///   - image: the image
    ///   - selector: the selector to invoke when tapped
    ///   - xOffset: Ox offset
    ///   - yOffset: Oy offset
    /// - Returns: the button
    public func createBarButton(_ image: UIImage, selector: Selector, xOffset: CGFloat = 0, yOffset: CGFloat = 0) -> UIView {
        // Right navigation button
        let size = CGSize(width: 40, height: 40)
        let customBarButtonView = UIView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let b = UIButton()
        b.addTarget(self, action: selector, for: .touchUpInside)
        b.frame = CGRect(x: xOffset, y: yOffset, width: size.width, height: size.height);
        b.setImage(image, for: .normal)

        customBarButtonView.addSubview(b)
        return customBarButtonView
    }

    /// Initialize back button for current view controller that will be pushed
    public func initBackButtonFromChild(padding: UIEdgeInsets = .zero) {
        let rect = CGRect(x: 0, y: 0, width: 44, height: 44)
        let customBarButtonView = UIView(frame: rect)
        // Button
        let button = UIButton()
        button.addTarget(self, action: #selector(UIViewController.backButtonAction), for: .touchUpInside)
        let w = rect.width - padding.left - padding.right
        let h = rect.height - padding.top - padding.bottom
        button.frame = CGRect(x: padding.left, y: padding.top, width: w, height: h)

        // Button title
        button.setTitle(" ", for: .normal)
        button.setImage(#imageLiteral(resourceName: "iconBack"), for: .normal)

        // Set custom view for left bar button
        customBarButtonView.addSubview(button)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: customBarButtonView)
    }

    /// "Back" button action handler
    @objc open func backButtonAction() {
        self.navigationController?.popViewController(animated: true)
    }

    /// Instantiate initial view controller from given storyboard
    ///
    /// - Parameter storyboardName: the name of the storyboard
    /// - Returns: view controller or nil
    public func createInitialViewController(fromStoryboard storyboardName: String) -> UIViewController? {
        return UIStoryboard(name: storyboardName, bundle: nil).instantiateInitialViewController()
    }

}

// Prints all fonts to verify what fonts the app has access to
public func printAllFonts() {
    for name in UIFont.familyNames {
       print("family: \(name)")
       for j in UIFont.fontNames(forFamilyName: name) {
           print("\tname: \(j)")
       }
   }
}
