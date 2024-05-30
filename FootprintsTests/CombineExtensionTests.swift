//
//  CombineExtensionTests.swift
//  FootprintsTests
//
//  Created by Collin Palmer on 4/11/24.
//

import XCTest
import Combine
@testable import Footprints

final class CombineExtensionTests: XCTestCase {

    override func setUpWithError() throws {}
    override func tearDownWithError() throws {}
    
    func testOldNewPublisher() throws {
        let testSubject = PassthroughSubject<Int, Never>()
        let expectation = XCTestExpectation()
        var firstPass = true
        
        let subscriber = testSubject
            .eraseToAnyPublisher()
            .cachePrevious()
            .sink { old, new in
                if firstPass {
                    XCTAssert(old == nil)
                    XCTAssert(new == 1)
                    firstPass = false
                } else {
                    XCTAssert(old == 1)
                    XCTAssert(new == 3)
                    expectation.fulfill()
                }
            }
        
        testSubject.send(1)
        testSubject.send(3)
        wait(for: [expectation], timeout: 3)
    }
    
    func testTimeBuffer() throws {
        let expectation = XCTestExpectation()
        
        let bufferPublisher = Timer
            .publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .map { _ in Int.random(in: 0...10) }
            .buffer(seconds: 3)
            .autoconnect()
            .sink(receiveValue: { values in
                print("Values: \(values)")
                expectation.fulfill()
            })
        
        
        wait(for: [expectation], timeout: 5)
    }
}
