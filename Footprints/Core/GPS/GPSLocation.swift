//
//  GPSLocation.swift
//  Footprints
//
//  Created by Collin Palmer on 3/26/24.
//

import Foundation
import CoreLocation

protocol GPSLocatable {
    var latitude: CGFloat { get }
    var longitude: CGFloat { get }
    var altitude: Measurement<UnitLength> { get }
    var timestamp: Float { get }
    var speed: Double { get }
    func distance(from loc: GPSLocatable) -> Measurement<UnitLength>
}

struct GPSLocation: GPSLocatable {
    let latitude: CGFloat
    let longitude: CGFloat
    /// Altitude in meters.
    let altitude: Measurement<UnitLength>
    let timestamp: Float
    var speed: Double = 0
    
    /// Compute the distance in meters between the two points.
    func distance(from loc: GPSLocatable) -> Measurement<UnitLength> {
        let loc1 = CLLocation(latitude: latitude, longitude: longitude)
        let loc2 = CLLocation(latitude: loc.latitude, longitude: loc.longitude)
        
        return .init(value: loc1.distance(from: loc2), unit: .meters)
    }
}
