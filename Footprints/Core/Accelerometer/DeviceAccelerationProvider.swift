//
//  DeviceAccelerationProvider.swift
//  Footprints
//
//  Created by Collin Palmer on 4/12/24.
//

import Foundation
import Combine
import CoreMotion

class DeviceAccelerationProvider: AccelerationProvider {
    private let accelSubject = PassthroughSubject<Acceleration, Never>()
    private let manager = CMMotionManager()
    private let queue = OperationQueue()
    
    var accelerationPublisher: AccelerationPublisher {
        accelSubject.eraseToAnyPublisher()
    }
    
    init() {
        manager.accelerometerUpdateInterval = 1/3
    }
    
    func start() {
        manager.startAccelerometerUpdates(to: queue, withHandler: { data, error in
            guard let data else {
                return
            }
            
            // TODO: Include timestamp
            let accel = data.acceleration
            let deviceAccel = DeviceAcceleration(x: accel.x, y: accel.y, z: accel.z, timestamp: Float(data.timestamp))
            
            self.accelSubject.send(deviceAccel)
        })
    }
    
    func stop() {
        manager.stopAccelerometerUpdates()
    }
}
