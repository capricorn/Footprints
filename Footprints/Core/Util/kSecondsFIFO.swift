//
//  kSecondsFIFO.swift
//  Footprints
//
//  Created by Collin Palmer on 4/18/24.
//

import Foundation

final class kSecondsFIFO<T: Timestamped>: PredicateFIFO<T> {
    private let seconds: Double
    
    /**
     - Parameters:
         - seconds: The time interval this FIFO contains; that is, `[Date.now-seconds,Date.now].`
     */
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

extension kSecondsFIFO where T: GPSLocatable {
    /// seconds/mi
    var pace: Double? {
        guard arr.count >= 2 else {
            return nil
        }
        
        let totalDistance = zip(arr, arr[1...])
            .map { $1.distance(from: $0).converted(to: .miles).value }
            .reduce(0, +)
        
        guard totalDistance > 0 else {
            return nil
        }
        
        let elapsedSeconds = arr.last!.timestamp - arr.first!.timestamp
        
        return (elapsedSeconds)/totalDistance
    }
}
