//
//  GPSProvider.swift
//  Footprints
//
//  Created by Collin Palmer on 3/22/24.
//

import Foundation
import Combine
import CoreLocation

protocol GPSProvider {
    typealias LocationProvider = AnyPublisher<GPSLocation, Never>
    var location: LocationProvider { get }
    var authorizationStatus: CLAuthorizationStatus { get }
    
    /// Start recording location updates
    func start()
    /// Stop recording location updates
    func stop()
    
    func requestAuthorization()
    // TODO: Should throw with timeout
    func fetchCurrentLocation() async -> GPSLocation?
}

extension GPSProvider {
    func requestAuthorization() {}
    var authorizationStatus: CLAuthorizationStatus {
        .authorizedAlways
    }
    
    func fetchCurrentLocation() async -> GPSLocation? {
        return nil
    }
    
    func start() {}
    func stop() {}
}
