//
//  GPSLocation.swift
//  Footprints
//
//  Created by Collin Palmer on 3/26/24.
//

import Foundation

struct GPSLocation {
    let latitude: CGFloat
    let longitude: CGFloat
    /// Altitude in meters.
    let altitude: Measurement<UnitLength>
    let timestamp: Float
}
