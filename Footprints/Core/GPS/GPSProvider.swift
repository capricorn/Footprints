//
//  GPSProvider.swift
//  Footprints
//
//  Created by Collin Palmer on 3/22/24.
//

import Foundation
import Combine
import GRDB
import CoreLocation

struct GPSLocation: Identifiable, Codable, FetchableRecord, PersistableRecord {
    let id: UUID
    let latitude: CGFloat
    let longitude: CGFloat
    /// Altitude in meters.
    let altitude: Measurement<UnitLength>
    let timestamp: Float
}

protocol GPSProvider {
    typealias LocationProvider = AnyPublisher<GPSLocation, Never>
    var location: LocationProvider { get }
    var authorizationStatus: CLAuthorizationStatus { get }
    
    /// Start recording location updates
    func start()
    /// Stop recording location updates
    func stop()
    
    func requestAuthorization()
}

extension GPSProvider {
    func requestAuthorization() {}
    var authorizationStatus: CLAuthorizationStatus {
        .authorizedAlways
    }
}
