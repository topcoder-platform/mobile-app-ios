//
//  DateExtensions.swift
//  SwiftEx
//
//  Created by Volkov Alexander on 19/10/17.
//  Updated by Alexander Volkov on 3/14/19.
//  Copyright (c) 2015-2018 Alexander Volkov. All rights reserved.
//

import Foundation

// MARK: - Shortcut methods for Date
extension Date {

    // MARK: - Days

    /// Get Date that corresponds to the start of current day.
    ///
    /// - Returns: the date
    public func beginningOfDay() -> Date {
        let calendar = Calendar.current

        let components = calendar.dateComponents([.month, .year, .day], from: self)

        return calendar.date(from: components)!
    }

    /// Get Date that corresponds to the end of current day
    ///
    /// - Returns: the date
    public func endOfDay() -> Date {
        var date = nextDayStart()
        date = date.addingTimeInterval(-1)
        return date
    }

    /// Get the next day start
    public func nextDayStart() -> Date {
        let calendar = Calendar.current

        var components = DateComponents()
        components.day = 1

        let date = calendar.date(byAdding: components, to: self.beginningOfDay())!
        return date
    }

    // MARK: - Weeks

    /// Get Date that corresponds to the start of current week
    ///
    /// - Returns: the date
    public func beginningOfWeek() -> Date {
        let calendar = Calendar.current

        let components = calendar.dateComponents([.year, .weekOfYear], from: self)

        return calendar.date(from: components)!
    }

    /// Get Date that corresponds to the end of current week
    ///
    /// - Returns: the date
    public func endOfWeek() -> Date {
        var date = nextWeek()
        date = date.addingTimeInterval(-1)
        return date
    }

    /// Get next week date.
    public func nextWeek() -> Date {
        let calendar = Calendar.current

        var components = DateComponents()
        components.weekOfYear = 1

        let date = calendar.date(byAdding: components, to: self.beginningOfWeek())!
        return date
    }

    // MARK: - Months

    /// Get previous month date.
    public func previousMonth() -> Date {
        let calendar = Calendar.current

        var components = DateComponents()
        components.day = -1

        let date = calendar.date(byAdding: components, to: self.beginningOfMonth())!
        return date
    }

    /// Get Date that corresponds to the start of current month.
    public func beginningOfMonth() -> Date {
        let calendar = Calendar.current

        let components = calendar.dateComponents([.month, .year], from: self)
        return calendar.date(from: components)!
    }

    /// Get Date that corresponds to the end of current month
    ///
    /// - Returns: the date
    public func endOfMonth() -> Date {
        var date = nextMonth()
        date = date.addingTimeInterval(-1)
        return date
    }

    /// Get next month date.
    public func nextMonth() -> Date {
        let calendar = Calendar.current

        var components = DateComponents()
        components.month = 1

        let date = calendar.date(byAdding: components, to: self.beginningOfMonth())!
        return date
    }

    // MARK: - Years

    /// Get Date that corresponds to the start of current year.
    ///
    /// - Returns: the date
    public func beginningOfYear() -> Date {
        let calendar = Calendar.current

        let components = calendar.dateComponents([.year], from: self)

        return calendar.date(from: components)!
    }

    /// Get Date that corresponds to the end of current year
    ///
    /// - Returns: the date
    public func endOfYear() -> Date {
        var date = nextYear()
        date = date.addingTimeInterval(-1)
        return date
    }


    /// Get next month date.
    public func nextYear() -> Date {
        let calendar = Calendar.current

        var components = DateComponents()
        components.year = 1

        let date = calendar.date(byAdding: components, to: self.beginningOfYear())!
        return date
    }

    // MARK: - Modification

    /// Add hours to the date
    ///
    /// - Parameter hours: the number of hours to add
    /// - Returns: changed date
    public func add(hours: Int) -> Date {
        let calendar = Calendar.current

        var components = DateComponents()
        components.hour = hours

        let date = calendar.date(byAdding: components, to: self)!
        return date
    }

    /// Add days to the date
    ///
    /// - Parameter days: the number of days to add
    /// - Returns: changed date
    public func add(days: Int) -> Date {
        let calendar = Calendar.current

        var components = DateComponents()
        components.day = days

        let date = calendar.date(byAdding: components, to: self)!
        return date
    }

    /// Add weeks to the date
    ///
    /// - Parameter weeks: the number of weeks to add
    /// - Returns: changed date
    public func add(weeks: Int) -> Date {
        let calendar = Calendar.current

        var components = DateComponents()
        components.weekdayOrdinal = weeks

        let date = calendar.date(byAdding: components, to: self)!
        return date
    }

    /// Add months to the date
    ///
    /// - parameter months: the number of months to add
    /// - returns: changed date
    public func add(months: Int) -> Date {
        let calendar = Calendar.current

        var components = DateComponents()
        components.month = months

        return calendar.date(byAdding: components, to: self)!
    }

    /// Add years to the date
    ///
    /// - Parameter years: the number of years to add
    /// - Returns: changed date
    public func add(years: Int = 1) -> Date {
        let calendar = Calendar.current

        var components = DateComponents()
        components.year = years

        return calendar.date(byAdding: components, to: self)!
    }

    /// Add minutes to the date
    ///
    /// - Parameter minutes:  the number of minutes to add
    /// - Returns: changed date
    public func add(minutes: Int) -> Date {
        let calendar = Calendar.current

        var components = DateComponents()
        components.minute = minutes

        return calendar.date(byAdding: components, to: self)!
    }

    /// Set year from given date
    ///
    /// - Parameter date: the date with given year
    /// - Returns: the date
    public func setYear(fromDate date: Date) -> Date {
        let calendar = Calendar.current
        let componentsYear = calendar.dateComponents([.year], from: date)
        var components = calendar.dateComponents([.day, .month, .year], from: self)
        components.year = componentsYear.year

        return calendar.date(from: components)!
    }

    // MARK: - Compare

    /// Compares current date with the given one down to the SECONDS.
    ///
    /// - Parameter date: date to compare or nil
    /// - Returns: true if the dates has equal years, months, days, hours, minutes and seconds.
    public func isSameDate(date: Date?) -> Bool {
        if let d = date {
            let calendar = Calendar.current
            return ComparisonResult.orderedSame == calendar.compare(self, to: d, toGranularity: .second)
        }
        return false
    }

    /// Compares current date with the given one down to the day.
    /// If date==nil, then always return false
    ///
    /// - Parameter date: the date to compare or nil
    /// - Returns: true if the dates has equal years, months, days
    public func isSameDay(_ date: Date?) -> Bool {
        if let d = date {
            let calendar = Calendar.current
            return ComparisonResult.orderedSame == calendar.compare(self, to: d, toGranularity: Calendar.Component.day)
        }
        return false
    }

    public func isSameWeek(_ date: Date?) -> Bool {
        if let d = date {
            let calendar = Calendar.current
            return ComparisonResult.orderedSame == calendar.compare(self, to: d, toGranularity: Calendar.Component.weekOfYear)
        }
        return false
    }

    /// Compares current date with the given one down to the month.
    /// If date==nil, then always return false
    ///
    /// - Parameter date: the date to compare or nil
    /// - Returns: true if the dates has equal years, months
    public func isSameMonth(_ date: Date?) -> Bool {
        if let d = date {
            let calendar = Calendar.current
            return ComparisonResult.orderedSame == calendar.compare(self, to: d, toGranularity: Calendar.Component.month)
        }
        return false
    }

    public func isSameYear(_ date: Date?) -> Bool {
        if let d = date {
            let calendar = Calendar.current
            return ComparisonResult.orderedSame == calendar.compare(self, to: d, toGranularity: Calendar.Component.year)
        }
        return false
    }

    /// Check if current date is after the given date
    ///
    /// - Parameter date: the date to check
    /// - Returns: true - if current date is after
    public func isAfter(_ date: Date) -> Bool {
        return self.compare(date) == ComparisonResult.orderedDescending
    }

    // MARK: - Time

    // MARK: - Distance calculation

    /// Check if date occured given number of days before
    ///
    /// - Parameter nDaysBefore: the tested number of days
    /// - Returns: true - if current date is N days before
    public func occuredDaysBeforeToday(_ nDaysBefore: Int) -> Bool {

        let now = Date()
        let today = now.beginningOfDay()
        var comp = DateComponents()
        comp.day = -nDaysBefore      // lets go N days back from today
        let before = Calendar.current.date(byAdding: comp, to: today)!
        if self.compare(before) == .orderedDescending {
            if self.compare(now) == .orderedAscending {
                return true
            }
        }
        return false
    }

    public func daysAgo() -> String {
        if self.occuredDaysBeforeToday(0) {
            return "Today"
        }
        else if self.occuredDaysBeforeToday(1) {
            return "Yesterday"
        }
        else if self.occuredDaysBeforeToday(7) {
            return "This week"
        }
        else if self.occuredDaysBeforeToday(14) {
            return "1 week ago"
        }
        else if self.occuredDaysBeforeToday(21) {
            return "2 weeks ago"
        }
        else {
            return "month ago"
        }
    }

    /// Get number of years since current date till now
    public func yearsSinceDate() -> Int {
        let calendar = Calendar.current
        let comp = calendar.dateComponents([Calendar.Component.year], from: self, to: Date())
        return comp.year ?? 0
    }

    /// Returns now many years, months, days is left
    ///
    /// - Parameter addZeros: true - will add zeros for months and days < 10, e.g. ("05", "years")
    /// - Returns: tuple (value, "days", "months" or "years" label), e.g. ("5", "years")
    public func left(addZeros: Bool = false) -> (String, String) {
        let calendar = Calendar.current

        let difference = calendar.dateComponents([.day, .month, .year], from: Date(), to: self)
        let days = difference.day!
        let month = difference.month!
        let year = difference.year!

        if year > 0 { return ("\(year)", (year == 1 ? "year" : "years")) }
        if month > 0 { return (addZeros ? "\(month)".addZeros() : "\(month)", (month == 1 ? "month" : "months")) }
        if days > 0 { return (addZeros ? "\(days)".addZeros() : "\(days)", (days == 1 ? "day" : "days")) }
        return ("-", "")
    }

    /// Returns now many years, months, days has passed
    ///
    /// - Parameters:
    ///   - addZeros: true - will add zeros for months and days < 10, e.g. ("05", "years")
    ///   - since: the reference date in the past
    /// - Returns: tuple (value, "days", "months" or "years" label), e.g. ("5", "years")
    public func passed(addZeros: Bool = false, since: Date = Date(), suffixes: [String]? = nil) -> (String, String) {
        let calendar = Calendar.current

        let difference = calendar.dateComponents([.minute, .hour, .day, .month, .year], from: since, to: self)
        let minute = difference.minute!
        let hour = difference.hour!
        let days = difference.day!
        let month = difference.month!
        let year = difference.year!

        let suffixes: [(String, String)] = suffixes != nil && suffixes!.count == 5
            ? suffixes!.map({($0, $0)})
            : [("year", "years"), ("month", "months"), ("day", "days"), ("hour", "hours"), ("minute", "minutes")]

        if year > 0 { return ("\(year)", (year == 1 ? suffixes[0].0 : suffixes[0].1)) }
        if month > 0 { return (addZeros ? "\(month)".addZeros() : "\(month)", (month == 1 ? suffixes[1].0 : suffixes[1].1)) }
        if days > 0 { return (addZeros ? "\(days)".addZeros() : "\(days)", (days == 1 ? suffixes[2].0 : suffixes[2].1)) }
        if hour > 0 { return (addZeros ? "\(hour)".addZeros() : "\(hour)", (hour == 1 ? suffixes[3].0 : suffixes[3].1)) }
        if minute > 0 { return (addZeros ? "\(minute)".addZeros() : "\(minute)", (minute == 1 ? suffixes[4].0 : suffixes[4].1)) }
        return ("-", "")
    }

    // MARK: - Parsers/Formatters

    /// ISO date formatter
    public static let isoFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        df.timeZone = TimeZone(secondsFromGMT: 0)
        return df
    }()

    public static let weekDay: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "EEE"
        df.timeZone = TimeZone.current
        return df
    }()

    public static let time: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "hh:mm a"
        df.timeZone = TimeZone.current
        return df
    }()

    /// ISO formatted date string
    public var isoFormat: String {
        return Date.isoFormatter.string(from: self)
    }

    /// Parse ISO date
    public static func from(iso string: String) -> Date? {
        return Date.isoFormatter.date(from: string)
    }
}
