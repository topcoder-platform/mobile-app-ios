//
//  Credentials.swift
//  EvernymApp
//
//  Created by Volkov Alexander on 2/21/21.
//  Copyright © 2021 Volkov Alexander. All rights reserved.
//

import Foundation

class CredentialsInfo: Codable, Hashable {
    
    let offer: Offer
    let serializedCredentials: String?
    let connection: Connection
    
    var title: String {
        offer.getTitle() ?? "-"
    }
    
    var cellTitle: String {
        offer.getCellTitle() ?? "-"
    }
    
    init(offer: Offer, serializedCredentials: String?, connection: Connection) {
        self.offer = offer
        self.serializedCredentials = serializedCredentials
        self.connection = connection
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
    
    static func == (lhs: CredentialsInfo, rhs: CredentialsInfo) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}
