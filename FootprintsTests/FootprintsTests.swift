//
//  FootprintsTests.swift
//  FootprintsTests
//
//  Created by Collin Palmer on 3/22/24.
//

import XCTest
import CoreLocation
@testable import Footprints

final class FootprintsTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLocationDelegateLocationPublisher() async throws {
        let model = LocationDelegate()
        let expectation = XCTestExpectation()
        let subscriber = model.location.sink { loc in
            print("Received location: \(loc)")
            expectation.fulfill()
        }
        
        model.locationManager(CLLocationManager(), didUpdateLocations: [CLLocation(latitude: 0, longitude: 0)])
        await fulfillment(of: [expectation], timeout: 3)
    }
}
