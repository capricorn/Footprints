//
//  Session.swift
//  Footprints
//
//  Created by Collin Palmer on 3/25/24.
//

import Foundation
import GRDB
import CoreGPX

struct SessionModel: Identifiable, Codable, FetchableRecord, PersistableRecord {
    let id: UUID
    var startTimestamp: Float
    var endTimestamp: Float
    var count: Int
    var totalDistance: Double = 0.0
    
    var totalLogTime: TimeInterval? {
        guard endTimestamp > 0 else {
            return nil
        }
        
        return TimeInterval(endTimestamp - startTimestamp)
    }
    
    func exportGPX(db: Database, metadata: GPXMetadata=GPXMetadata()) throws -> String? {
        // TODO: Cursor approach if large
        let root = GPXRoot(creator: Bundle.main.bundleIdentifier!)
        let trackpoints = try GPSLocationModel
            .filter(Column("sessionId") == self.id)
            .fetchAll(db)
            .map { $0.trackpoint }
        
        // TODO: Setup metadata
        //var metadata = GPXMetadata()
        let track = GPXTrack()
        let trackSegment = GPXTrackSegment()
        
        trackSegment.add(trackpoints: trackpoints)
        track.add(trackSegment: trackSegment)
        root.add(track: track)
        root.metadata = metadata

        return root.gpx()
    }
}

