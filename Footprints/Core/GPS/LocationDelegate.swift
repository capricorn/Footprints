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
    
    private let locManager: CLLocationManager = CLLocationManager()
    private let locationSubject: PassthroughSubject<GPSLocation, Never> = PassthroughSubject()
    
    var location: AnyPublisher<GPSLocation, Never> {
        locationSubject.eraseToAnyPublisher()
    }
    
    // TODO: Setup publisher? (otherwise no live refresh)
    // NB. Could also specify as a publisher itself
    var authorizationStatus: CLAuthorizationStatus {
        self.locManager.authorizationStatus
    }
    
    override init() {
        super.init()
        self.locManager.distanceFilter = kCLDistanceFilterNone
        self.locManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        self.locManager.delegate = self
        self.locManager.allowsBackgroundLocationUpdates = true
        self.locManager.showsBackgroundLocationIndicator = true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for loc in locations {
            let gpsLoc = GPSLocation(
                latitude: loc.coordinate.latitude,
                longitude: loc.coordinate.longitude,
                altitude: .init(value: loc.altitude, unit: .meters),
                timestamp: Float(loc.timestamp.timeIntervalSince1970))
            print("Sending gps location")
            locationSubject.send(gpsLoc)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to receive location updates: \(error)")
    }
    
    func start() {
        locManager.startUpdatingLocation()
    }
    
    func stop() {
        locManager.stopUpdatingLocation()
    }
    
    func requestAuthorization() {
        locManager.requestAlwaysAuthorization()
    }
}
