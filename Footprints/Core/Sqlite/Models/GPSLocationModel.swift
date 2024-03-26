//
//  GPSLocation.swift
//  Footprints
//
//  Created by Collin Palmer on 3/26/24.
//

import Foundation
import GRDB

struct GPSLocationModel: Identifiable, Codable, FetchableRecord, PersistableRecord {
    let id: UUID
    let sessionId: UUID
    let latitude: CGFloat
    let longitude: CGFloat
    /// Altitude in meters.
    let altitude: Measurement<UnitLength>
    let timestamp: Float
    
    static func from(_ loc: GPSLocation, sessionId: UUID) -> GPSLocationModel {
        return GPSLocationModel(
            id: UUID(),
            sessionId: sessionId,
            latitude: loc.latitude,
            longitude: loc.longitude,
            altitude: loc.altitude,
            timestamp: loc.timestamp)
    }
}


extension GPSLocationModel: TableRecord {
    static let databaseTableName: String = "gpsLocationModel"
}
