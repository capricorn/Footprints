//
//  Acceleration.swift
//  Footprints
//
//  Created by Collin Palmer on 4/12/24.
//

import Foundation
import CoreMotion

protocol Acceleration {
    var x: Double { get }
    var y: Double { get }
    var z: Double { get }
}

extension CMAcceleration: Acceleration {}
