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

extension FormatStyle where Self == Duration.MinuteSecondShortFormatStyle {
    static var minuteSecondShort: Duration.MinuteSecondShortFormatStyle { Duration.MinuteSecondShortFormatStyle() }
}
