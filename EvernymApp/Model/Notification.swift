//
//  Notification.swift
//  EvernymApp
//
//  Created by Volkov Alexander on 12/26/20.
//  Copyright © 2020 Volkov Alexander. All rights reserved.
//

import Foundation

struct Notification: Codable {
    
    let title: String
    let relation: String
    let date: Date
    
    let isNew: Bool
}


