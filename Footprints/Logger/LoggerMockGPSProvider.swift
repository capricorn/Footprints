//
//  LoggerMockGPSProvider.swift
//  Footprints
//
//  Created by Collin Palmer on 3/24/24.
//

import Foundation
import Combine

class LoggerMockGPSProvider: GPSProvider, ObservableObject {
    @Published var logging: Bool = false
    
    private var locSubject: PassthroughSubject<GPSLocation, Never> = PassthroughSubject()
    private var gpsTask: Task<Void, Never>?
    
    var location: AnyPublisher<GPSLocation, Never> {
        locSubject.eraseToAnyPublisher()
    }
    
    func start() {
        gpsTask = Task.detached {
            while Task.isCancelled == false {
                self.locSubject.send(GPSLocation(
                    id: UUID(), 
                    sessionId: UUID(),  // TODO
                    latitude: 0,
                    longitude: 0,
                    altitude: .init(value: 0, unit: .meters),
                    timestamp: Float(Date.now.timeIntervalSince1970)))
                
                try? await Task.sleep(nanoseconds: UInt64(1e9))
            }
        }
        logging = true
    }
    
    func stop() {
        gpsTask?.cancel()
        gpsTask = nil
        logging = false
    }
}
