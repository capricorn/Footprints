//
//  SessionCSV.swift
//  Footprints
//
//  Created by Collin Palmer on 5/14/24.
//

import Foundation

struct SessionCSV: Codable {
    let id: String
    let startTimestamp: Double
    let endTimestamp: Double
    let count: Int
    let totalDistance: Double
    let fiveKTime: Double?
    
    enum CodingKeys: Int, CodingKey {
        case id = 0
        case startTimestamp
        case endTimestamp
        case count
        case totalDistance
        case fiveKTime
    }
    
    static let headers = [ "id", "startTimestamp", "endTimestamp", "count", "totalDistance", "fiveKTime"]
    
    static func from(_ model: SessionModel) -> SessionCSV {
        SessionCSV(
            id: model.id.uuidString,
            startTimestamp: model.startTimestamp,
            endTimestamp: model.endTimestamp,
            count: model.count,
            totalDistance: model.totalDistance,
            fiveKTime: model.fiveKTime)
    }
}
