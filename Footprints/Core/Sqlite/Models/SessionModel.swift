//
//  Session.swift
//  Footprints
//
//  Created by Collin Palmer on 3/25/24.
//

import Foundation
import GRDB

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
}

