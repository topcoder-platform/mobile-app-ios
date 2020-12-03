//
//  DataSource.swift
//  EvernymApp
//
//  Created by Volkov Alexander on 12/3/20.
//  Copyright © 2020 Volkov Alexander. All rights reserved.
//

import SwiftEx83
import SwiftyJSON
import RxSwift

extension RestServiceApi {
    
    /// Get invitation content by requesting URL
    /// - Parameter url: the URL from QR code
    static func getInvitation(url: URL) -> Observable<JSON> {
        return request(.get, url: url)
    }
}
