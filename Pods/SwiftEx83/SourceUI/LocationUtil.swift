//
//  LocationUtil.swift
//  Alamofire
//
//  Created by Volkov Alexander on 4/1/19.
//

import Foundation
import CoreLocation

/// Util that provides current device locations (single, or as a sequence)
open class LocationUtil: NSObject, CLLocationManagerDelegate {

    public static var shared = LocationUtil()
    public var manager: CLLocationManager?
    private var callback: ((CLLocation)->())?
    private var singleCallback: ((CLLocation)->())?

    /// Setup
    /// Can be used to set accuracy. If not called, then .best accuracy will be user
    public func setup(withAccuracy locationAccuracy: CLLocationAccuracy = kCLLocationAccuracyBest, allowBackground: Bool = false) {
        guard manager == nil else { return }
        manager = CLLocationManager()
        manager?.delegate = self
        manager?.activityType = .fitness
        manager?.desiredAccuracy = locationAccuracy
        if #available(iOS 9.0, *) {
            manager?.allowsBackgroundLocationUpdates = allowBackground
        } else {
            // Fallback on earlier versions
        }
        if !(CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse) {
            manager?.requestAlwaysAuthorization()
        }
    }

    /// Starts listening location
    /// Call .stop() to finish the listening
    public func start(_ callback: @escaping (CLLocation)->(), needToSetup: Bool = true) {
        if CLLocationManager.locationServicesEnabled() && needToSetup {
            setup()
        }
        self.callback = callback
        manager?.startUpdatingLocation()
    }

    /// Stops listening location
    public func stop() {
        self.callback = nil
        manager?.stopUpdatingLocation()
    }

    /// Get current location
    public func getCurrentLocation(_ callback: @escaping (CLLocation)->()) {
        if CLLocationManager.locationServicesEnabled() {
            setup()
        }
        singleCallback = callback
        manager?.startUpdatingLocation()
    }

    // MARK: - CLLocationManager delegate

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            singleCallback?(location)
            singleCallback = nil
            if callback == nil {
                stop()
            }
            else {
                callback?(location)
            }
        }
    }
}
