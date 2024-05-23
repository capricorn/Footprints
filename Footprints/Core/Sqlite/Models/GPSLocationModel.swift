//
//  GPSLocation.swift
//  Footprints
//
//  Created by Collin Palmer on 3/26/24.
//

import Foundation
import GRDB
import CoreGPX

struct GPSLocationModel: Identifiable, Codable, FetchableRecord, PersistableRecord {
    let id: UUID
    let sessionId: UUID
    let latitude: CGFloat
    let longitude: CGFloat
    /// Altitude in meters.
    let altitude: Measurement<UnitLength>
    let timestamp: Double
    
    static func from(_ loc: GPSLocatable, session: SessionModel) -> GPSLocationModel {
        return GPSLocationModel(
            id: UUID(),
            sessionId: session.id,
            latitude: loc.latitude,
            longitude: loc.longitude,
            altitude: loc.altitude,
            timestamp: loc.timestamp)
    }
    
    var trackpoint: GPXTrackPoint {
        let point = GPXTrackPoint(latitude: latitude, longitude: longitude)
        // TODO: Use timezone associated with time?
        point.time = Date(timeIntervalSince1970: TimeInterval(timestamp))
        
        return point
    }
}


extension GPSLocationModel: TableRecord {
    static let databaseTableName: String = "gpsLocationModel"
}

extension GPSLocationModel: CSVRepresentable {
    static let headers: [String] = GPSLocationCSV.headers
}
