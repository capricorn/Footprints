//
//  kSecondsFIFO.swift
//  Footprints
//
//  Created by Collin Palmer on 4/18/24.
//

import Foundation

final class kSecondsFIFO<T: Timestamped>: PredicateFIFO<T> {
    private let seconds: Double
    
    init(_ seconds: Double) {
        self.seconds = seconds
        super.init()
        self.pred = { fifo in
            guard let newestItem = fifo.last, let oldestItem = fifo.first else {
                return false
            }
            
            return Double(newestItem.timestamp - oldestItem.timestamp) > self.seconds
        }
    }
    
    convenience init(duration: Measurement<UnitDuration>) {
        self.init(duration.converted(to: .seconds).value)
    }
}
