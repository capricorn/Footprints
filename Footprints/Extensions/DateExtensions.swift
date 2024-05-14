//
//  DateExtensions.swift
//  Footprints
//
//  Created by Collin Palmer on 5/14/24.
//

import Foundation

extension Date {
    /// see: https://developer.apple.com/documentation/foundation/nsdatecomponents/1410442-weekday
    enum Weekday: Int {
        case Sunday = 1
        case Monday
        case Tuesday
        case Wednesday
        case Thursday
        case Friday
        case Saturday
    }
    
    var weekday: Weekday {
        let rawWeekday = Calendar.current.dateComponents([.weekday], from: self).weekday!
        return Weekday(rawValue: rawWeekday)!
    }
    
    var dayOfMonth: Int {
        Calendar.current.dateComponents([.day], from: self).day!
    }
    
    var monthName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        
        return formatter.string(from: self)
    }
    
    static func now(offsetByDays days: Int) -> Date {
        return Date.now.addingTimeInterval(60*60*24*Double(days))
    }
}

extension Calendar {
    var firstOfMonth: Date {
        let todayComponents = self.dateComponents([.year, .month, .day], from: Date.now)
        // TODO: Verify day=1 is in fact the first day of the month
        let firstOfMonthComponents = DateComponents(calendar: self, year: todayComponents.year, month: todayComponents.month, day: 1, hour: 0, minute: 0, second: 0)
        
        return self.date(from: firstOfMonthComponents)!
    }
}
