//
//  SessionAccelerometerCSV.swift
//  Footprints
//
//  Created by Collin Palmer on 5/22/24.
//

import Foundation

struct SessionAccelerometerCSV: Codable {
    let x: Double
    let y: Double
    let z: Double
    let timestamp: Double
    
    enum CodingKeys: Int, CodingKey {
        case x = 0
        case y
        case z
        case timestamp
    }
    
    static let headers = [ "x", "y", "z", "timestamp" ]
    
    static func from(_ model: DeviceAccelerationModel) -> SessionAccelerometerCSV {
        SessionAccelerometerCSV(
            x: model.x,
            y: model.y,
            z: model.z,
            timestamp: Double(model.timestamp))
    }
}
