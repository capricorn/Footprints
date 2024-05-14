//
//  CSV_Tests.swift
//  FootprintsTests
//
//  Created by Collin Palmer on 5/14/24.
//

import XCTest
import GRDB
import CodableCSV

@testable import Footprints

final class CSV_Tests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testSessionsCSVExport() throws {
        let dbQueue = try DatabaseQueue.createTemporaryDBQueue()
        try dbQueue.setupFootprintsSchema()
        
        // TODO: Fixed UUIDs
        let sessions: [SessionModel] = [
            SessionModel(id: UUID(), startTimestamp: 1, endTimestamp: 10, count: 3),
            SessionModel(id: UUID(), startTimestamp: 12, endTimestamp: 15, count: 7),
        ]
        
        try dbQueue.write { db in
            for session in sessions {
                try session.insert(db)
            }
        }
        
        let csvData = try SessionCSVTransferable.encodeSessionsCSV(dbQueue: dbQueue)
        let decoder = CSVDecoder { $0.headerStrategy = .firstLine }
        let csvSessions = try decoder.decode([SessionCSV].self, from: csvData)
        
        XCTAssert(csvSessions.count == 2)
        XCTAssert(csvSessions[0].id == sessions[0].id.uuidString)
        XCTAssert(csvSessions[1].id == sessions[1].id.uuidString)
    }
}
