//
//  LoggerViewModel_Tests.swift
//  FootprintsTests
//
//  Created by Collin Palmer on 3/26/24.
//

import XCTest
import Combine
@testable import Footprints

final class LoggerViewModel_Tests: XCTestCase {
    private struct NoopGPSProvider: GPSProvider {
        var location: LocationProvider {
            PassthroughSubject().eraseToAnyPublisher()
        }
        
        func start() {}
        func stop() {}
    }

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    /// Verify the logger 'record' state machine follows the correct state transitions.
    func testLoggerState() throws {
        let model = LoggerViewModel(dbQueue: try .createTemporaryDBQueue(), gpsProvider: NoopGPSProvider())
        XCTAssert(model.state == nil)
        
        model.record()
        if case .recordingInProgress(_) = model.state {
        } else {
            XCTFail("Bad state: \(model.state)")
        }
        
        model.record()
        if case .recordingComplete = model.state {
        } else {
            XCTFail("Bad state: \(model.state)")
        }
    }
}
