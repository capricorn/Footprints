//
//  Session.swift
//  Footprints
//
//  Created by Collin Palmer on 3/25/24.
//

import Foundation
import GRDB
import CoreGPX
import CoreTransferable

struct SessionModel: Identifiable, Codable, FetchableRecord, PersistableRecord {
    let id: UUID
    var startTimestamp: Double
    var endTimestamp: Double
    var count: Int
    var totalDistance: Double = 0.0
    
    var totalLogTime: TimeInterval? {
        guard endTimestamp > 0 else {
            return nil
        }
        
        return TimeInterval(endTimestamp - startTimestamp)
    }
    
    /// min/mi
    var pace: Double? {
        guard let totalLogTime, totalDistance > 0 else {
            return nil
        }
        
        return totalLogTime/totalDistance
    }
    
    private func buildGPX(dbQueue: DatabaseQueue, metadata: GPXMetadata=GPXMetadata()) throws -> GPXRoot {
        // TODO: Cursor approach if large
        let root = GPXRoot(creator: Bundle.main.bundleIdentifier!)
        let trackpoints = try dbQueue.read { db in
            try GPSLocationModel
                .filter(Column("sessionId") == self.id)
                .fetchAll(db)
                .map { $0.trackpoint }
        }
        
        // TODO: Setup metadata
        //var metadata = GPXMetadata()
        let track = GPXTrack()
        let trackSegment = GPXTrackSegment()
        
        trackSegment.add(trackpoints: trackpoints)
        track.add(trackSegment: trackSegment)
        root.add(track: track)
        root.metadata = metadata
        
        return root
    }
    
    func exportGPX(dbQueue: DatabaseQueue, metadata: GPXMetadata=GPXMetadata()) throws -> String? {
        let root = try buildGPX(dbQueue: dbQueue, metadata: metadata)
        return root.gpx()
    }
    
    func exportGPXToURL(
        dbQueue: DatabaseQueue,
        saveAt: URL,
        filename: String?=nil,
        metadata: GPXMetadata=GPXMetadata()
    ) throws -> URL {
        let filename = filename ?? "\(self.id.uuidString)"
        let gpxURL = saveAt.appending(component: filename + ".gpx")
        
        let root = try buildGPX(dbQueue: dbQueue, metadata: metadata)
        try root.outputToFile(saveAt: saveAt, fileName: filename)
        
        return gpxURL
    }
}
