//
//  NotificationCenterExtension.swift
//  BleconfApp
//
//  Created by Alexander Volkov on 12/17/18.
//  Copyright © 2018 Alexander Volkov. All rights reserved.
//

import Foundation

#if os(Linux)
#else
/// Application state changes
///
/// - enterForeground: the app will enter foreground
/// - active: alias for `enterForeground`
/// - resignActive: the app will became inactive
/// - inactive: alias for `inactive`
///
/// Add the following pairs of calls in AppDelegate:
///     NotificationCenter.post(ApplicationEvent.resignActive)
///     NotificationCenter.post(ApplicationEvent.inactive)
///
///     NotificationCenter.post(ApplicationEvent.enterForeground)
///     NotificationCenter.post(ApplicationEvent.active)
public enum ApplicationEvent: String {
    case enterForeground, active, resignActive, inactive
}

// MARK: - Extension that allows to post enum based notifications
extension NotificationCenter {

    /// Post notification
    ///
    /// - Parameters:
    ///   - notification: a notification, e.g. `ApplicationEvent.active`
    ///   - object: the related object
    ///   - userInfo: the related user info
    public static func post<T:RawRepresentable>(_ name: T, object: Any? = nil, userInfo: [AnyHashable: Any]? = nil) where T.RawValue == String {
        NotificationCenter.default.post(name: Foundation.Notification.Name(name.rawValue), object: object, userInfo: userInfo)
    }

    /// Add observer
    ///
    /// - Parameters:
    ///   - observer: the observer
    ///   - selector: the selector
    ///   - name: a notification, e.g. ApplicationEvent.active
    ///   - object: the related object
    ///
    ///
    /// - Example:
    ///     ```
    ///     NotificationCenter.add(observer: self, selector: #selector(notificationHandler(_:)), name: ApplicationEvent.active)
    ///
    ///    /// Notification handler
    ///    ///
    ///    /// - Parameter notification: the notification
    ///    @objc func notificationHandler(_ notification: Notification) {
    ///         // TODO handle notification
    ///    }
    ///    ```
    public static func add<T:RawRepresentable>(observer: Any, selector: Selector, name: T?, object: Any? = nil) where T.RawValue == String {
        NotificationCenter.default.addObserver(observer, selector: selector, name: Foundation.Notification.Name(name?.rawValue ?? ""), object: object)
    }
    
    /// Shortcut method for adding observer for a set of events
    ///
    /// - Parameters:
    ///   - observer: the observer
    ///   - selector: the selector
    ///   - name: notification names, e.g. [ApplicationEvent.active, ApplicationEvent.inactive]
    ///   - object: the related object
    public static func add<T:RawRepresentable>(observer: Any, selector: Selector, names: [T], object: Any? = nil) where T.RawValue == String {
        for name in names {
            add(observer: observer, selector: selector, name: name, object: object)
        }
    }
}
#endif
