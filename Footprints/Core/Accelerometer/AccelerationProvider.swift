//
//  AccelerationProvider.swift
//  Footprints
//
//  Created by Collin Palmer on 4/12/24.
//

import Foundation
import Combine

protocol AccelerationProvider {
    typealias AccelerationPublisher = AnyPublisher<Acceleration, Never>
    
    var accelerationPublisher: AccelerationPublisher { get }
    
    func start()
    func stop()
}
