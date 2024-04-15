//
//  TimeExtensions.swift
//  Footprints
//
//  Created by Collin Palmer on 4/15/24.
//

import Foundation

extension TimeInterval {
    var duration: Duration {
        Duration(secondsComponent: Int64(self), attosecondsComponent: 0)
    }
}
