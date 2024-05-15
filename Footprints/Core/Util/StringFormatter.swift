//
//  StringFormatter.swift
//  Footprints
//
//  Created by Collin Palmer on 5/9/24.
//

import Foundation


// TODO: Add to gist
extension Duration {
    struct MinuteSecondShortFormatStyle: FormatStyle {
        typealias FormatInput = TimeInterval
        typealias FormatOutput = String
        
        func format(_ value: FormatInput) -> String {
            let minutes = Int64(value/60)
            let seconds = String(format: "%02d", Int(value)%60)
            return "\(minutes)m \(seconds)s"
        }
    }
}

// TODO: Is this the right place..?
extension Date.FormatStyle {
    struct ShortMonthYearFormatStyle: FormatStyle {
        typealias FormatInput = Date
        typealias FormatOutput = String
        
        func format(_ value: FormatInput) -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM ''yy"

            return formatter.string(from: value)
        }
    }
}

extension FormatStyle where Self == Duration.MinuteSecondShortFormatStyle {
    static var minuteSecondShort: Duration.MinuteSecondShortFormatStyle { Duration.MinuteSecondShortFormatStyle() }
}

extension FormatStyle where Self == Date.FormatStyle {
    static var monthYearShort: Date.FormatStyle.ShortMonthYearFormatStyle { Date.FormatStyle.ShortMonthYearFormatStyle() }
}
