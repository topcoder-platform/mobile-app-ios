//
//  UserDefaultsExtensions.swift
//  SwiftEx83
//
//  Created by Alexander Volkov on 09/29/2020.
//  Copyright (c) 2020 Alexander Volkov. All rights reserved.
//

import Foundation

extension UserDefaults {
    
    /// Store object in UserDefaults
    /// - Parameters:
    ///   - object: the object
    ///   - forKey: the key for the storage
    public func store<T: Encodable>(object: T?, forKey: String) {
        if let value = object {
            do {
                let data = try JSONEncoder().encode(value)
                UserDefaults.standard.set(data, forKey: forKey)
            }
            catch {
                print("ERROR: \(error)")
            }
        }
        else {
            UserDefaults.standard.removeObject(forKey: forKey)
        }
        UserDefaults.standard.synchronize()
    }
    
    /// Get stored object by key
    /// - Parameter forKey: the key
    /// - Returns: the decoded object
    public func get<T: Decodable>(forKey: String) -> T? {
        if let data = UserDefaults.standard.object(forKey: forKey) as? Data {
            do {
                return try JSONDecoder().decode(T.self, from: data)
            }
            catch {
                print("ERROR: \(error)")
            }
        }
        return nil
    }
}
