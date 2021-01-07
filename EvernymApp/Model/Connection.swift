//
//  Connection.swift
//  EvernymApp
//
//  Created by Volkov Alexander on 12/27/20.
//  Copyright © 2020 Volkov Alexander. All rights reserved.
//

import UIKit

class Connection: Codable, Hashable {
 
    let relation: String
    let info: String
    let date: Date
    let serializedConnection: String?
    let type: ConnectionType
    
    var didRemote: String?
    var didCurrent: String? // TODO not sure what these DIDs mean
    
    
    enum ConnectionType: String, Codable {
        case phone = "type1", topcoder = "type2"
        
        var color: UIColor {
            switch self {
            case .topcoder:
                return UIColor(named: "purple")!
            default:
                return UIColor(named: "yellow")!
            }
        }
        
        var icon: UIImage {
            switch self {
            case .phone:
                return UIImage(named: "type1")!
            default:
                return UIImage(named: "type2")!
            }
        }
    }
    
    init(relation: String, info: String, date: Date, serializedConnection: String?) {
        self.relation = relation
        self.info = info
        self.date = date
        self.serializedConnection = serializedConnection
        self.type = relation.lowercased().contains("phone") ? .phone : .topcoder
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(relation)
    }
    
    static func == (lhs: Connection, rhs: Connection) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}
