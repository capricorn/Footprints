//
//  APNLiveActivityNotification.swift
//  Footprints
//
//  Created by Collin Palmer on 8/7/24.
//

import Foundation

class APNLiveActivityNotification: Codable {
    let aps: APNAPS
    let sessionId: UUID
}

class APNAPS: Codable {
    let contentAvailable: Int
    
    enum CodingKeys: String, CodingKey {
        case contentAvailable = "content-available"
    }
}
