//
//  Credentials.swift
//  EvernymApp
//
//  Created by Volkov Alexander on 2/21/21.
//  Copyright © 2021 Volkov Alexander. All rights reserved.
//

import Foundation

class CredentialsInfo: Codable, Hashable {
    
    let title: String
    let serializedCredentials: String?
    
    init(title: String, serializedCredentials: String?) {
        self.title = title
        self.serializedCredentials = serializedCredentials
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
    
    static func == (lhs: CredentialsInfo, rhs: CredentialsInfo) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}
