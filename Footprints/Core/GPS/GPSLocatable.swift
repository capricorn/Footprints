//
//  GPSLocatable.swift
//  Footprints
//
//  Created by Collin Palmer on 4/12/24.
//

import Foundation

protocol GPSLocatable: Timestamped {
    var latitude: CGFloat { get }
    var longitude: CGFloat { get }
    var altitude: Measurement<UnitLength> { get }
    var timestamp: Float { get }
    var speed: Double { get }
    func distance(from loc: GPSLocatable) -> Measurement<UnitLength>
}
