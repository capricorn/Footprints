//
//  GPSLocation.swift
//  Footprints
//
//  Created by Collin Palmer on 3/26/24.
//

import Foundation
import CoreLocation

struct GPSLocation {
    let latitude: CGFloat
    let longitude: CGFloat
    /// Altitude in meters.
    let altitude: Measurement<UnitLength>
    let timestamp: Float
    var speed: Double = 0
    
    /// Compute the distance in meters between the two points.
    func distance(from loc: GPSLocation) -> Measurement<UnitLength> {
        let loc1 = CLLocation(latitude: latitude, longitude: longitude)
        let loc2 = CLLocation(latitude: loc.latitude, longitude: loc.longitude)
        
        return .init(value: loc1.distance(from: loc2), unit: .meters)
    }
}
