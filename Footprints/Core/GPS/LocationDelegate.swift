//
//  LocationDelegate.swift
//  Footprints
//
//  Created by Collin Palmer on 3/25/24.
//

import Foundation
import CoreLocation
import Combine

class LocationDelegate: NSObject, CLLocationManagerDelegate, GPSProvider {
    let locManager: CLLocationManager = CLLocationManager()
    private var locationSubject: PassthroughSubject<GPSLocation, Never> = PassthroughSubject()
    
    var location: AnyPublisher<GPSLocation, Never> {
        locationSubject.eraseToAnyPublisher()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for loc in locations {
            let gpsLoc = GPSLocation(
                id: UUID(),
                latitude: loc.coordinate.latitude,
                longitude: loc.coordinate.longitude,
                altitude: .init(value: loc.altitude, unit: .meters),
                timestamp: Float(loc.timestamp.timeIntervalSince1970))
            locationSubject.send(gpsLoc)
        }
    }
    
    override init() {
        super.init()
        self.locManager.delegate = self
    }
}
