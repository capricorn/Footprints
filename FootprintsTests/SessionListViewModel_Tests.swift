//
//  SessionListViewModel_Tests.swift
//  FootprintsTests
//
//  Created by Collin Palmer on 4/18/24.
//

import XCTest
import GRDB
@testable import Footprints

final class SessionListViewModel_Tests: XCTestCase {
    private var model: SessionListViewModel!
    override func setUpWithError() throws {
        model = SessionListViewModel()
    }

    override func tearDownWithError() throws {}
    
    func testSessionSortAscendDescend() throws {
        let tmpDBQueue = try DatabaseQueue.createTemporaryDBQueue()
        
        let session1 = SessionModel(
            id: UUID(),
            startTimestamp: 0,
            endTimestamp: 0,
            count: 3)
        let session2 = SessionModel(
            id: UUID(),
            startTimestamp: 5,
            endTimestamp: 0,
            count: 3)
        let session3 = SessionModel(
            id: UUID(),
            startTimestamp: 10,
            endTimestamp: 0,
            count: 3)
        
        try tmpDBQueue.write { db in
            try session1.insert(db)
            try session2.insert(db)
            try session3.insert(db)
        }
        
        var sessions = try model.session(sort: .startDate, direction: .ascending, dbQueue: tmpDBQueue)
        
        XCTAssert(sessions.count == 3, "count: \(sessions.count)")
        XCTAssert(sessions.first?.id == session1.id)
        XCTAssert(sessions.last?.id == session3.id)
        
        // Next: verify sort order in reverse
        sessions = try model.session(sort: .startDate, direction: .descending, dbQueue: tmpDBQueue)
        
        XCTAssert(sessions.count == 3, "count: \(sessions.count)")
        XCTAssert(sessions.first?.id == session3.id)
        XCTAssert(sessions.last?.id == session1.id)
    }
}
