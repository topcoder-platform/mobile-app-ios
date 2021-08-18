//
//  Challenge.swift
//  TopcoderMobileApp
//
//  Created by Volkov Alexander on 8/14/21.
//  Copyright © 2021 Volkov Alexander. All rights reserved.
//

import Foundation

/// Model for a challenge
struct Challenge: Decodable, Identifiable {

    /// date formatters for the API response
    static var dateFormatter: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        f.locale = Locale(identifier: "UTC")
        return f
    }
    static var dateFormatterShort: DateFormatter {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        f.locale = Locale(identifier: "UTC")
        return f
    }
    
    // The fields
    var title: String { name ?? "-" }
    var prize: Int { overview?.totalPrizes ?? 0 }
    var ends: Date? {
        if let date = Challenge.dateFormatter.date(from: endDate ?? "") {
            return date
        }
        else if let date = Challenge.dateFormatterShort.date(from: endDate ?? "") {
            return date
        }
        return nil
    }
    
    var id: String = UUID().uuidString
    var created: String?
    var endDate: String?
    var description: String? = ""
    let name: String?
    var numOfRegistrants: Int? = 0
    var numOfSubmissions: Int? = 0

    var overview: ChallengeOverview?
    var phases: [ChallengePhase]? = []
    var tags: [String]?
    var type: String?
    var track: String?
    var challengeType: ChallengeType? {
        ChallengeTrack(rawValue: track ?? "")?.toType()
    }
    
    var registrationEndDate: String?
    var registrationEndDateDate: Date? {
        if let date = Challenge.dateFormatter.date(from: registrationEndDate ?? "") {
            return date
        }
        else if let date = Challenge.dateFormatterShort.date(from: registrationEndDate ?? "") {
            return date
        }
        return nil
    }
    
    /// true - if registration is passed, false - else
    var passed: Bool {
        guard let date = registrationEndDateDate else { return true }
        return !date.isAfter(Date())
    }
    
    /// The time remains for registration
    var registerRemains: TimeInterval? {
        guard let e = registrationEndDateDate else { return nil }
        return e.timeIntervalSinceNow
    }
    
    /// The time remains for registration as string
    var registerRemainsString: String? {
        guard let e = registrationEndDateDate else { return nil }
        return e.remains()
    }
    
    /// the next dead line
    var nextDeadLine: String {
        return "Registration" // TODO add logic
    }
    
    var events: [ChallengeEvent]?
    
    var prizeSets: [ChallengePrizeSet]?
    
    /// the prizes for competitors
    var devPrizes: [Int] {
        prizeSets?.first(where: {$0.type == "placement"})?.prizes.map({$0.value}) ?? []
    }
}

/// `prizeSets`
struct ChallengePrizeSet: Decodable {
    
    let type: String
    let prizes: [ChallengePrize]
}

/// `prizes`
struct ChallengePrize: Decodable {
    
    let type: String
    let value: Int
}

/// `phases`
struct ChallengePhase: Decodable {
    // not used
}

/// `overview`
struct ChallengeOverview: Decodable {
    var totalPrizes: Int?
}

/// `events`
struct ChallengeEvent: Decodable {
    
    var id: Int?
    var key: String?
    var name: String?
}


/// `track`
enum ChallengeTrack: String, Decodable {
    case development = "Development", qualityAssurance = "Quality Assurance", design = "Design"
    
    func toType() -> ChallengeType {
        switch self {
        case .development: return .code
        case .design: return .design
        case .qualityAssurance: return .qa
        }
    }
}

extension Date {
    
    /// How many time remains
    /// - Parameter since: since date
    public func remains(since: Date = Date()) -> String {
        let calendar = Calendar.current
        
        let difference = calendar.dateComponents([.minute, .hour, .day], from: since, to: self)
        let minute = difference.minute!
        let hour = difference.hour!
        let days = difference.day!
        var strs = [String]()
        if days > 0 { strs.append("\(days)d") }
        if hour > 0 { strs.append("\(hour)h") }
        if minute > 0 && days == 0 { strs.append("\(minute)m") }
        let str = strs.joined(separator: " ")
        if str.isEmpty {
            return "0m"
        }
        return str
    }
}
