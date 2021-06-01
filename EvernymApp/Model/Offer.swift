//
//  Offer.swift
//  EvernymApp
//
//  Created by Volkov Alexander on 2/21/21.
//  Copyright © 2021 Volkov Alexander. All rights reserved.
//

import Foundation
import SwiftyJSON

typealias Offer = JSON

extension Offer {
    
    // Title used in UI
    func getTitle() -> String? {
        let defId = self.arrayValue.first?["cred_def_id"].string
        return "\(defId ?? "")"
    }
    
    // Title used in the cell
    func getCellTitle() -> String? {
        let attrName = (self.arrayValue.first?["credential_attrs"]["name"].string ?? "")
        let attrDegree = (self.arrayValue.first?["credential_attrs"]["degree"].string ?? "")
        return "name: \(attrName)\ndegree: \(attrDegree)"
    }
}
