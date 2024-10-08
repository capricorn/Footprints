//
//  CoreUtil_Tests.swift
//  FootprintsTests
//
//  Created by Collin Palmer on 4/18/24.
//

import XCTest
@testable import Footprints

final class CoreUtil_Tests: XCTestCase {

    override func setUpWithError() throws {}
    override func tearDownWithError() throws {}
    
    func testkSecondsFIFO() throws {
        struct MockLocation: GPSLocatable {
            var latitude: CGFloat = 0
            var longitude: CGFloat = 0
            var altitude: Measurement<UnitLength> = .init(value: 0, unit: .meters)
            var timestamp: Double = 0
            var speed: Double = 0
            
            func distance(from loc: Footprints.GPSLocatable) -> Measurement<UnitLength> {
                return .init(value: 0, unit: .meters)
            }
        }
        
        var loc1 = MockLocation()
        loc1.timestamp = 0
        
        var loc2 = MockLocation()
        loc2.timestamp = 4
        
        var loc3 = MockLocation()
        loc3.timestamp = 7
        
        var loc4 = MockLocation()
        loc4.timestamp = 11
        
        let fifo = kSecondsFIFO<MockLocation>(duration: .init(value: 10, unit: .seconds))
        fifo.push(loc1)
        fifo.push(loc2)
        fifo.push(loc3)
        fifo.push(loc4)
        
        XCTAssert(fifo.arr.count == 3)
        XCTAssert(fifo.arr.first?.timestamp == 4)
        XCTAssert(fifo.arr.last?.timestamp == 11)
    }
    
    func testkSecondsFIFOPace() throws {
        struct MockLocation: GPSLocatable {
            var latitude: CGFloat = 0
            var longitude: CGFloat = 0
            var altitude: Measurement<UnitLength> = .init(value: 0, unit: .meters)
            var timestamp: Double = 0
            var speed: Double = 0
            
            func distance(from loc: Footprints.GPSLocatable) -> Measurement<UnitLength> {
                return .init(value: 5, unit: .miles)
            }
        }
        
        var loc1 = MockLocation()
        loc1.timestamp = 0
        var loc2 = MockLocation()
        loc2.timestamp = 1
        var loc3 = MockLocation()
        loc3.timestamp = 3
        
        let fifo = kSecondsFIFO<MockLocation>(5)
        fifo.push(loc1)
        fifo.push(loc2)
        fifo.push(loc3)
        
        // 3 seconds total / 10 mi total
        XCTAssert(fifo.pace == 0.3)
    }
}
