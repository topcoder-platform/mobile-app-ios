//
//  CMConfig.swift
//  EvernymApp
//
//  Created by Volkov Alexander on 11/22/20.
//  Copyright © 2020 Volkov Alexander. All rights reserved.
//

import Foundation
import vcx
import Combine

/// Connection types
public enum CMConnectionType: String {
    case qr = "QR", sms = "SMS"
    
    func connectionTypeString(phone: String? = nil) -> String {
        switch self {
        case .qr:
            return "{\"connection_type\":\"\(self.rawValue)\",\"phone\":\"\"}"
        case .sms:
            return "{\"connection_type\":\"\(self.rawValue)\",\"phone\":\"\(phone ?? "")\"}"
        }
    }
}

/// Connections
extension CMConfig {
    
    /// Connect with given invitation
    /// - Parameters:
    ///   - inviteDetails: the invitation details taken from QR code URL
    public func connect(withInviteDetails inviteDetails: Dictionary<String, Any>) -> Future<Int, Error> {
        return Future { promise in
            let sdkApi = CMConfig.sdkApi
            let inviteId = inviteDetails.connectionID
            do {
                let detailsString = try inviteDetails.toJson()
                // Create connection
                sdkApi.connectionCreate(withInvite: inviteId, inviteDetails: detailsString) { (error, connectionHandle) in
                    // Check if 1010 error and call resuse in this case. If any other error, then fail
                    if let code = CMConfig.getErrorCode(from: error) {
                        if code != 1010 {
                            guard !CMConfig.printError(label: "connectionCreate:withInvite", error, promise: promise) else { return }
                        }
                        else {
                            let handle = VcxHandle(truncatingIfNeeded: connectionHandle)
                            sdkApi.connectionSendReuse(handle, invite: detailsString) { (error) in
                                guard !CMConfig.printError(label: "connectionSendReuse:", error, promise: promise) else { return }
                                print("connectionSendReuse was successful!")
                                print("connectionHandle: \(connectionHandle)")
                                promise(.success(connectionHandle))
                            }
                        }
                        return
                    }
                    print("connectionCreate:inviteDetails was successful!")
                    print("connectionHandle: \(connectionHandle)")
                    promise(.success(connectionHandle))
                }
            }
            catch {
                promise(.failure(error))
            }
        }
    }

    // TODO remove it. Used with old vcx version.
//    public func connectionTheirPwDid(handle: Int) -> Future<(String), Error> {
//        return Future { promise in
//            let sdkApi = CMConfig.sdkApi
//            //            let handle = VcxHandle(truncatingIfNeeded: handle)
//            sdkApi.connectionGetPwDid(handle) { (error, pwdid) in
//                guard !CMConfig.printError(label: "connectionGetPwDid", error, promise: promise) else { return }
//
//                sdkApi.connectionGetTheirPwDid(handle) { (error, theidDid) in
//                    guard !CMConfig.printError(label: "connectionGetPwDid", error, promise: promise) else { return }
//                    promise(.success(((pwdid ?? "-"), (theidDid ?? "-"))))
//                }
//            }
//        }
//    }
    
    /// Need to wait >4 seconds after connection is established
    /// - Parameters:
    ///   - handle: the handle
    ///   - connectionType: connection type
    ///   - phone: the phone number for `.sms` type or nil for `.qr`
    public func connect(handle: Int, connectionType: CMConnectionType, phone: String? = nil) -> Future<Void, Error> {
        return connect(handle: handle, connectionTypeString: connectionType.connectionTypeString(phone: phone))
    }
    
    /// Need to wait >4 seconds after connection is established
    /// - Parameters:
    ///   - handle: the handle
    public func connect(handle: Int, connectionTypeString: String = "{\"use_public_did\":true}") -> Future<Void, Error> {
        return Future { promise in
            let sdkApi = CMConfig.sdkApi
            // Connect
            let handle = VcxHandle(truncatingIfNeeded: handle)
            sdkApi.connectionConnect(handle, connectionType: "{\"use_public_did\":true}") { (error, _) in
                guard !CMConfig.printError(label: "connectionConnect:handle", error, promise: promise) else { return }
                print("connectionConnect:handle was successful!")
                promise(.success(()))
            }
        }
    }
    
    public func connectionGetState(handle: Int) -> Future<Int, Error> {
        return Future { promise in
            let sdkApi = CMConfig.sdkApi
            sdkApi.connectionGetState(Int(handle)) { (error, state) in
                guard !CMConfig.printError(label: "connectionGetState", error, promise: promise) else { return }
                print("connectionGetState was successful (state=\(state))!")
                promise(.success(state))
            }
        }
    }
    
    public func connectionUpdateState(handle: Int) -> Future<Int, Error> {
        return Future { promise in
            let sdkApi = CMConfig.sdkApi
            sdkApi.connectionUpdateState(Int(handle)) { (error, state) in
                guard !CMConfig.printError(label: "connectionUpdateState", error, promise: promise) else { return }
                print("connectionUpdateState was successful (state=\(state))!")
                promise(.success(state))
            }
        }
    }
    
    public func connectionSerialize(handle: Int) -> Future<String, Error> {
        return Future { promise in
            let sdkApi = CMConfig.sdkApi
            sdkApi.connectionSerialize(Int(handle)) { (error, serializedConnection) in
                guard !CMConfig.printError(label: "connectionSerialize", error, promise: promise) else { return }
                print("connectionSerialize was successful!")
                promise(.success(serializedConnection!))
            }
        }
    }
    
    public func connectionDeserialize(serializedConnection: String) -> Future<Int, Error> {
        return Future { promise in
            let sdkApi = CMConfig.sdkApi
            sdkApi.connectionDeserialize(serializedConnection) { (error, handle) in
                guard !CMConfig.printError(label: "connectionDeserialize", error, promise: promise) else { return }
                print("connectionDeserialize was successful!")
                promise(.success(handle))
            }
        }
    }
    
    public func connectionRelease(handle: Int) {
        CMConfig.sdkApi.connectionRelease(handle)
    }
}

extension Dictionary where Key == String, Value == Any {
    
    /// Get connection name from invitation Dictionary
    // line 173: https://github.com/topcoder-platform/mobile-sdk/blob/master/examples/ios/VCXHelpers/CMConnection.m
    public var connectionName: String {
        if let a = self["s"] as? Dictionary {
            if let n = a["n"] as? String {
                return n
            }
        }
        return self["label"] as? String ?? "-"
    }
    
    /// The connection ID used to connect with invite, aka `getPwDid()` (`pw_did`)
    // line 154: https://github.com/topcoder-platform/mobile-sdk/blob/master/examples/ios/VCXHelpers/CMConnection.m
    public var connectionID: String {
        // invitation
        if let id = self["id"] as? String { return id }
        if let id = self["@id"] as? String { return id }
        // serialized connection
        if let data = self["data"] as? Dictionary, let id = data["pw_did"] as? String { return id }
        // previous version used in this app
        return connectionName
    }
}
