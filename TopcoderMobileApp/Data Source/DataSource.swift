//
//  DataSource.swift
// TopcoderMobileApp
//
//  Created by Volkov Alexander on 12/3/20.
//  Copyright © 2020 Volkov Alexander. All rights reserved.
//

import SwiftEx83
import SwiftyJSON
import RxSwift
import MobileWallet

typealias API = RestServiceApi

enum UIEvents: String {
    case connectionUpdate, credentialUpdate
}

/// the file names
let kFileConnections = "connections.json"
let kFileCredentials = "credentials2.json"

extension RestServiceApi {
    
    static var cacheConnections: [Connection]?
    static var cacheCredentials: [CredentialsInfo]?
    
    // Keychain utility used to store `walletKey` and `vcxConfig`
    static var keychain: Keychain = {
        let util = Keychain(service: "TopcoderMobileData")
        util.queryConfiguration = { query in
            let query = NSMutableDictionary(dictionary: query)
            query[kSecAttrAccessible] = kSecAttrAccessibleWhenUnlocked
            return query
        }
        return util
    }()
    
    /// Get invitation content by requesting URL
    /// - Parameter url: the URL from QR code
    static func getInvitation(url: URL) -> Observable<JSON> {
        return request(.get, url: url)
    }
    
    static func getNotifications() -> Observable<[Notification]> {
        
        return Observable.just([
//            Notification(title: "You shared \"proof01\".", relation: "rel01", date: Date(), isNew: false),
//            Notification(title: "You have been issued a \"comment\".", relation: "rel01", date: Date(), isNew: false),
//            Notification(title: "You connected to \"proof01\".", relation: "rel01", date: Date(), isNew: false)
        ])
    }
    
    static func authenticate(pincode: String) -> Observable<Void> {
        return Observable.create { (obs) -> Disposable in
            if keychain["pincode"] == pincode {
                obs.onNext(())
                obs.onCompleted()
            }
            else {
                obs.onError("Wrong passcode")
            }
            return Disposables.create()
        }
    }
    
    static func setup(pincode: String) -> Observable<Void> {
        keychain["pincode"] = pincode
        return Observable.just(())
    }
    
    // MARK: - Connections
    
    static func getConnections() -> Observable<[Connection]> {
        if cacheConnections == nil {
            readFileConnections()
        }
        return Observable.just(cacheConnections!)
    }
    
    static func add(connection: Connection) -> Observable<Void> {
        _ = getConnections()
        cacheConnections?.append(connection)
        
        // Store changes
        do { try saveFileConnections() }
        catch { return Observable.error(error) }
        
        NotificationCenter.post(UIEvents.connectionUpdate)
        return Observable.just(())
    }
    
    static func delete(connection: Connection) -> Observable<Void> {
        _ = getConnections()
        if let i = cacheConnections?.firstIndex(of: connection) {
            cacheConnections?.remove(at: i)
        }
        
        // Store changes
        do { try saveFileConnections() }
        catch { return Observable.error(error) }
        
        NotificationCenter.post(UIEvents.connectionUpdate)
        
        // Remove related credentials
        _ = getCredentials()
            .subscribe(onNext: { value in
                let relatedCredentials = value.filter({$0.connection.id == connection.id})
                if !relatedCredentials.isEmpty {
                    _ = delete(credentials: relatedCredentials)
                }
            }, onError: { error in
                print("ERROR: \(error)")
            })
        return Observable.just(())
    }
    
    // MARK: - Credentials
    
    static func getCredentials() -> Observable<[CredentialsInfo]> {
        if cacheCredentials == nil {
            readFileCredentials()
        }
        return Observable.just(cacheCredentials!)
    }
    
    static func add(credentials: CredentialsInfo) -> Observable<Void> {
        _ = getCredentials()
        cacheCredentials?.append(credentials)
        
        // Store changes
        do { try saveFileCredentials() }
        catch { return Observable.error(error) }
        
        NotificationCenter.post(UIEvents.credentialUpdate)
        return Observable.just(())
    }
    
    /// Delete credentials
    /// - Parameter credentials: the credentials
    static func delete(credentials: [CredentialsInfo]) -> Observable<Void> {
        _ = getCredentials()
        for item in credentials {
            if let i = cacheCredentials?.firstIndex(of: item) {
                cacheCredentials?.remove(at: i)
            }
        }
        
        // Store changes
        do { try saveFileCredentials() }
        catch { return Observable.error(error) }
        
        NotificationCenter.post(UIEvents.credentialUpdate)
        return Observable.just(())
    }
    
    // MARK: - APN
    struct Empty: Codable {
    }
    
    static func registerApn(token: String) -> Observable<Empty> {
        var url = Configuration.apnEndpoint
        if !url.hasSuffix("/") {
            url += "/"
        }
        url += "notifications/subscriber"
        let parameters = [
            "handle": AuthenticationUtil.handle ?? "-",
            "token": token,
            "deviceType": "ios"
        ]
        return post(url: url, parameters: parameters)
    }
    
    /// Get profile image URL
    /// - Parameter handle: the handle
    static func getProfileImage(handle: String) -> Observable<String?> {
        let url = "https://api.topcoder.com/v5/members/\(handle)"
        struct ProfileJson: Decodable {
            let userId: Int
            let handle: String
            let photoURL: String?
        }
        return get(url: url).map { (profile: ProfileJson) -> String? in
            return profile.photoURL
        }
    }
    
    /// Get profile ID
    /// - Parameter handle: the handle
    static func getProfileId(handle: String) -> Observable<Int?> {
        let url = "https://api.topcoder.com/v5/members/\(handle)"
        struct ProfileJson: Decodable {
            let userId: Int
            let handle: String
            let photoURL: String?
        }
        return get(url: url).map { (profile: ProfileJson) -> Int? in
            return profile.userId
        }
    }
    
    // MARK: - Storing/restoring connections from persistent store
    
    private static func saveFileConnections() throws {
        let json = try cacheConnections?.json()
        _ = json?.saveFile(fileName: kFileConnections)
    }
    
    private static func readFileConnections() {
        if let json = JSON.contentOfFile(kFileConnections) {
            do {
                cacheConnections = try json.decodeIt()
            }
            catch {
                print("\(error)")
                cacheConnections = []
            }
        }
        else {
            cacheConnections = []
        }
    }
    
    private static func saveFileCredentials() throws {
        let json = try cacheCredentials?.json()
        _ = json?.saveFile(fileName: kFileCredentials)
    }
    
    private static func readFileCredentials() {
        if let json = JSON.contentOfFile(kFileCredentials) {
            do {
                cacheCredentials = try json.decodeIt()
            }
            catch {
                print("\(error)")
                cacheCredentials = []
            }
        }
        else {
            cacheCredentials = []
        }
    }
}
