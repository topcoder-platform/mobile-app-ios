//
//  NetworkUtil.swift
//  SwiftExInt
//
//  Created by Volkov Alexander on 10/23/18.
//  Copyright (c) 2018-2019 Alexander Volkov. All rights reserved.
//

import Foundation
import UIKit
import SystemConfiguration.CaptiveNetwork
import SystemConfiguration.SCNetworkConnection
import SystemConfiguration
import NetworkExtension


/// Utility to fetch network info
public class NetworkUtil {

    /// Current network SSID
    public class func ssid() -> String? {
        return fetchSSIDInfo()["SSID"] as? String
    }

    /// Fetch network info
    public class func fetchSSIDInfo() -> [String: Any] {
        var interface = [String: Any]()
        if let interfaces = CNCopySupportedInterfaces() {
            for i in 0..<CFArrayGetCount(interfaces){
                let interfaceName = CFArrayGetValueAtIndex(interfaces, i)
                let rec = unsafeBitCast(interfaceName, to: AnyObject.self)
                guard let unsafeInterfaceData = CNCopyCurrentNetworkInfo("\(rec)" as CFString) else {
                    return interface
                }
                guard let interfaceData = unsafeInterfaceData as? [String: Any] else {
                    return interface
                }
                interface = interfaceData
            }
        }
        return interface
    }
}
