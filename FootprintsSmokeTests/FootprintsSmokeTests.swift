//
//  FootprintsSmokeTests.swift
//  FootprintsSmokeTests
//
//  Created by Collin Palmer on 8/4/24.
//

import XCTest
import Combine
@testable import Footprints

final class FootprintsSmokeTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testNWSForecastAPIEndpoint() async throws {
        let loc = GPSLocation(latitude: 40.071511, longitude: -105.198932, altitude: .init(value: 0, unit: .meters), timestamp: Date.now.timeIntervalSince1970)
        let api = NWSAPI()
        guard let result = try await api.fetchForecastEndpoint(loc: loc) else {
            XCTFail("Failed to decode result to string")
            return
        }
        XCTAssert(result == URL(string:"https://api.weather.gov/gridpoints/BOU/57,77/forecast")!, "\(result)")
    }
}
