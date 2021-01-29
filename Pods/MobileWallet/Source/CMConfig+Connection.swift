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

/// Connections
extension CMConfig {
    
    /// Connect with given invitation
    /// - Parameters:
    ///   - inviteDetails: the invitation details taken from QR code URL
    public func connect(withInviteDetails inviteDetails: Dictionary<String, Any>) -> Future<Int, Error> {
        return Future { promise in
            let sdkApi = CMConfig.sdkApi
            let inviteLabel = inviteDetails["label"] as? String ?? ""
            do {
                let detailsString = try inviteDetails.toJson()
                // Create connection
                sdkApi.connectionCreate(withInvite: inviteLabel, inviteDetails: detailsString) { (error, connectionHandle) in
                    guard !CMConfig.printError(label: "connectionCreate:withInvite", error, promise: promise) else { return }
                    print("connectionCreate:inviteDetails was successful!")
                    print("connectionHandle: \(connectionHandle)")
                    //            let handle = VcxHandle(truncatingIfNeeded: connectionHandle)
                    promise(.success(connectionHandle))
                }
            }
            catch {
                promise(.failure(error))
            }
        }
    }
    
    public func connectionDids(handle: Int) -> Future<(String, String), Error> {
        return Future { promise in
            let sdkApi = CMConfig.sdkApi
            //            let handle = VcxHandle(truncatingIfNeeded: handle)
            sdkApi.connectionGetPwDid(handle) { (error, pwdid) in
                guard !CMConfig.printError(label: "connectionGetPwDid", error, promise: promise) else { return }
                
                sdkApi.connectionGetTheirPwDid(handle) { (error, theidDid) in
                    guard !CMConfig.printError(label: "connectionGetPwDid", error, promise: promise) else { return }
                    promise(.success(((pwdid ?? "-"), (theidDid ?? "-"))))
                }
            }
        }
    }
    
    /// Need to wait >4 seconds after connection is established
    /// - Parameters:
    ///   - handle: the handle
    ///   - callback: the callback to call when connection is done/fails
    public func connect(handle: Int) -> Future<Void, Error> {
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
