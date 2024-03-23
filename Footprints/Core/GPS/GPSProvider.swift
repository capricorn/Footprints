//
//  GPSProvider.swift
//  Footprints
//
//  Created by Collin Palmer on 3/22/24.
//

import Foundation
import Combine

struct GPSLocation {
    let latitude: CGFloat
    let longitude: CGFloat
    /// Altitude in meters.
    let altitude: Measurement<UnitLength>
}

protocol GPSProvider {
    var location: AnyPublisher<GPSLocation, Never> { get }
}

