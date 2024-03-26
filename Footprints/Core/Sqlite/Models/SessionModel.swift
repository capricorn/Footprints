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
    let startTimestamp: Float
    let endTimestamp: Float
}
