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
}
