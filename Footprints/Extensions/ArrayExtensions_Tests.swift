//
//  ArrayExtensions_Tests.swift
//  FootprintsTests
//
//  Created by Collin Palmer on 5/15/24.
//

import XCTest
@testable import Footprints

final class ArrayExtensions_Tests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGroupBy() throws {
        let d1 = DateBuilder()
            .year(2024)
            .month(.april)
            .day(3)
            .build()!
    
        let d2 = DateBuilder()
            .year(2024)
            .month(.april)
            .day(19)
            .build()!
    
        let d3 = DateBuilder()
            .year(2024)
            .month(.march)
            .day(3)
            .build()!
        
        let dates = [d1,d2,d3]
        
        let grouper = { (date: Date) -> Date in
            date.firstOfMonth
        }
        
        let groupedDates = dates.groupBy(grouper)
        
        XCTAssert(groupedDates.keys.count == 2)
        XCTAssert(groupedDates[d1.firstOfMonth]?.count == 2)
        XCTAssert(groupedDates[d1.firstOfMonth]?[0] == d1)
        XCTAssert(groupedDates[d3.firstOfMonth]?.count == 1)
        XCTAssert(groupedDates[d3.firstOfMonth]?[0] == d3)
    }
}
