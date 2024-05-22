//
//  DeviceAccelerationModel.swift
//  Footprints
//
//  Created by Collin Palmer on 4/12/24.
//

import Foundation
import GRDB

struct DeviceAccelerationModel: Identifiable, Codable, FetchableRecord, PersistableRecord {
    var id: UUID
    var sessionId: UUID
    var timestamp: Float
    var x: Double
    var y: Double
    var z: Double
    
    static func from(_ accel: Acceleration, session: SessionModel) -> DeviceAccelerationModel {
        DeviceAccelerationModel(
            id: UUID(),
            sessionId: session.id,
            timestamp: accel.timestamp,
            x: accel.x,
            y: accel.y,
            z: accel.z)
    }
}

extension DeviceAccelerationModel: CSVRepresentable {
    static let headers = [ "x", "y", "z", "timestamp" ]
}
