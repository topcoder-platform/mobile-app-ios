//
//  Connection.swift
//  EvernymApp
//
//  Created by Volkov Alexander on 12/27/20.
//  Copyright © 2020 Volkov Alexander. All rights reserved.
//

import Foundation

class Connection: Codable, Hashable {
 
    let relation: String
    let info: String
    let date: Date
    let serializedConnection: String?
    
    var didRemote: String?
    var didCurrent: String? // TODO not sure what these DIDs mean
    
    init(relation: String, info: String, date: Date, serializedConnection: String?) {
        self.relation = relation
        self.info = info
        self.date = date
        self.serializedConnection = serializedConnection
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(relation)
    }
    
    static func == (lhs: Connection, rhs: Connection) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}
