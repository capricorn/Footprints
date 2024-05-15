//
//  DateBuilder.swift
//  Footprints
//
//  Created by Collin Palmer on 5/15/24.
//

import Foundation

class DateBuilder {
    private var year: Int?
    private var month: Int?
    private var day: Int?
    private var hour: Int?
    private var minute: Int?
    private var second: Int?
    
    enum Month: Int {
        case january = 1
        case february
        case march
        case april
        case may
        case june
        case july
        case august
        case september
        case october
        case november
        case december
    }
    
    /// If year/month/day is not specified it defaults to the `Date.now` equivalent value.
    /// hour/min/sec all default to zero (that is, midnight.)
    func build() -> Date? {
        let now = Date.now
        let nowComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: now)
        
        let builderComponents = DateComponents(
            calendar: Calendar.current,
            year: year ?? nowComponents.year,
            month: month ?? nowComponents.month,
            day: day ?? nowComponents.day,
            hour: hour ?? 0,
            minute: minute ?? 0,
            second: second ?? 0)
    
        return Calendar.current.date(from: builderComponents)
    }
    
    func year(_ year: Int) -> DateBuilder {
        self.year = year
        return self
    }
    
    func month(_ month: Int) -> DateBuilder {
        self.month = month
        return self
    }
    
    func month(_ month: Month) -> DateBuilder {
        self.month = month.rawValue
        return self
    }
    
    func day(_ day: Int) -> DateBuilder {
        self.day = day
        return self
    }
    
    func hour(_ hour: Int) -> DateBuilder {
        self.hour = hour
        return self
    }
    
    func minute(_ minute: Int) -> DateBuilder {
        self.minute = minute
        return self
    }
    
    func second(_ second: Int) -> DateBuilder {
        self.second = second
        return self
    }
}
