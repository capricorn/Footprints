//
//  GPSLocationCSV.swift
//  Footprints
//
//  Created by Collin Palmer on 5/23/24.
//

import Foundation

struct GPSLocationCSV: CSVRepresentable {
    let latitude: CGFloat
    let longitude: CGFloat
    let altitude: Double
    let timestamp: Double
    
    static let headers: [String] = [ "latitude", "longitude", "altitude", "timestamp" ]
    
    static func from(_ loc: GPSLocationModel) -> GPSLocationCSV {
        return GPSLocationCSV(
            latitude: loc.latitude,
            longitude: loc.longitude,
            altitude: loc.altitude.converted(to: .miles).value,
            timestamp: loc.timestamp)
    }
}
