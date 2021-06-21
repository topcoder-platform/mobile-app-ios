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

/** Connections
 ```
  // Creating a connection
cancellable = util.connect(withInviteDetails: invitation)
    .flatMap({ handle -> Future<Void, Error> in
        connectionHandle = handle
        return util.connect(handle: handle)
    })
    .map { _ in
        sleep(4)
}
.flatMap({ handle in
    util.connectionGetState(handle: connectionHandle)
})
    .flatMap({ handle in
        util.connectionUpdateState(handle: connectionHandle)
    })
    .flatMap({ _ in
        util.connectionSerialize(handle: connectionHandle)
    })
    .map { [weak self] serializedConnection in
        _ = util.connectionRelease(handle: connectionHandle)
        guard self != nil else { return }
        
         let connectionName = invitation["s"]["n"].string ?? invitation["label"].string ?? "-"
         let didRemote = invitation["recipientKeys"].arrayValue.first?.string ?? "-"
        // Show connection in UI
}
.sink(receiveCompletion: { completion in
    loadingIndicator.stop()
    switch completion {
    case .finished: break
    case .failure(let error): showError(errorMessage: error.localizedDescription)
    }
}, receiveValue: { _ in })
 ```
 */
extension CMConfig {
    
    public func credentialGetOffers(connectionHandle: Int) -> Future<String, Error> {
        return Future { promise in
            let sdkApi = CMConfig.sdkApi
            let handle = VcxHandle(truncatingIfNeeded: connectionHandle)
            sdkApi.credentialGetOffers(handle) { (error, offers) in
                guard !CMConfig.printError(label: "credentialGetOffers", error, promise: promise) else { return }
                print("credentialGetOffers was successful!")
                promise(.success(offers!))
            }
        }
    }
    
    public func credentialCreateWithOffer(sourceId: String, credentialOffer: String) -> Future<Int, Error> {
        return Future { promise in
            let sdkApi = CMConfig.sdkApi
            sdkApi.credentialCreate(withOffer: sourceId, offer: credentialOffer) { error, credentialHandle in
                guard !CMConfig.printError(label: "credentialCreate", error, promise: promise) else { return }
                print("credentialGetOffers was successful!")
                promise(.success(credentialHandle))
            }
        }
    }
    
    public func credentialSendRequest(credentialHandle: Int, connectionHandle: Int, paymentHandle: Int) -> Future<String, Error> {
        return Future { promise in
            let sdkApi = CMConfig.sdkApi
            sdkApi.credentialSendRequest(credentialHandle, connectionHandle: VcxHandle(truncatingIfNeeded: connectionHandle), paymentHandle: vcx_payment_handle_t(paymentHandle)) { error in
                guard !CMConfig.printError(label: "credentialSendRequest", error, promise: promise) else { return }
                print("credentialSendRequest was successful!")
                promise(.success(""))
            }
        }
    }
    
    public func credentialUpdateState(credentialHandle: Int) -> Future<Int, Error> {
        return Future { promise in
            let sdkApi = CMConfig.sdkApi
            sdkApi.credentialUpdateState(credentialHandle) { error, state in
                guard !CMConfig.printError(label: "credentialUpdateState", error, promise: promise) else { return }
                print("credentialUpdateState was successful!")
                promise(.success(state))
            }
        }
    }
    
    public func credentialRelease(credentialHandle: Int) -> Int {
        return Int(CMConfig.sdkApi.connectionRelease(credentialHandle))
    }
}
