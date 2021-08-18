//
//  API.swift
//  TopcoderMobileApp
//
//  Created by Volkov Alexander on 8/14/21.
//  Copyright © 2021 Volkov Alexander. All rights reserved.
//

import SwiftEx83
import SwiftyJSON
import RxSwift

extension API {
    
    /// Get all challenges
    /// - Parameter searchString: the search string
    static func getAllChallenges(searchString: String?) -> Observable<[Challenge]> {
        return get(url: url("/challenges"))
    }
    
    /// Get open for registration
    /// - Parameter searchString: the search string
    static func getOpenForRegistration(searchString: String?) -> Observable<[Challenge]> {
        let now = Challenge.dateFormatter.string(from: Date())
        var params: [String: String] = ["registrationEndDateStart": now, "registrationStartDateEnd": now]
        if let string = searchString {
            params["search"] = string
        }
        return get(url: url("/challenges?" + params.toURLString()))
    }
    
    /// Get past challenges
    /// - Parameter searchString: the search string
    static func getPastChallenges(searchString: String?) -> Observable<[Challenge]> {
        let now = Challenge.dateFormatter.string(from: Date())
        var params: [String: String] = ["registrationEndDateEnd": now]
        if let string = searchString {
            params["search"] = string
        }
        return get(url: url("/challenges?" + params.toURLString()))
    }
    
    /// Get my challenges
    /// - Parameter searchString: the search string
    static func getMyChallenges(searchString: String?) -> Observable<[Challenge]> {
        guard let handle = AuthenticationUtil.handle else { return Observable.just([]) }
        
        return getProfileId(handle: handle)
            .flatMap { (id) -> Observable<[Challenge]> in
                guard let id = id else { return Observable.just([]) }
                var params: [String: String] = ["memberId": "\(id)"]
                if let string = searchString {
                    params["search"] = string
                }
                return get(url: url("/challenges?" + params.toURLString()))
        }
    }
    
    /// The full URL for given endpoint
    /// - Parameter endpoint: the endpoint
    private static func url(_ endpoint: String) -> String {
        return "\(Configuration.apiEndpoint)\(endpoint)"
    }
}
