//
//  GPSProvider.swift
//  Footprints
//
//  Created by Collin Palmer on 3/22/24.
//

import Foundation
import Combine
import GRDB

struct GPSLocation: Identifiable, Codable, FetchableRecord, PersistableRecord {
    let id: UUID
    let latitude: CGFloat
    let longitude: CGFloat
    /// Altitude in meters.
    let altitude: Measurement<UnitLength>
    let timestamp: Float
}

protocol GPSProvider {
    var location: AnyPublisher<GPSLocation, Never> { get }
}
