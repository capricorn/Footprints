//
//  GPX_Tests.swift
//  FootprintsTests
//
//  Created by Collin Palmer on 4/22/24.
//

import XCTest
import GRDB
import CoreGPX
@testable import Footprints

final class GPX_Tests: XCTestCase {
    var testBundle: Bundle!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        self.testBundle = Bundle(for: type(of: self))
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testGPXGeneration() throws {
        // TODO: Access test bundle?
        guard let dbPath = testBundle.url(forResource: "test_db", withExtension: "sqlite")?.path() else {
            XCTFail("Failed to find test db.")
            return
        }
        
        let sessionId = UUID(uuidString: "95DF25DC-32EC-4BE4-BD97-F8A1F002F931")!
        let dbQueue = try DatabaseQueue(path: dbPath)
        
        let session = try dbQueue.read { db in
            try SessionModel.find(db, id: sessionId)
        }
        
        let metadata = GPXMetadata()
        // Needs to match that of golden file
        metadata.time = Date(timeIntervalSince1970: 1713819511)
        let gpxString = try session.exportGPX(dbQueue: dbQueue, metadata: metadata)
        
        XCTAssert(gpxString != nil && gpxString?.isEmpty == false)
        
        guard let goldenGPXURL = testBundle.url(forResource: "export_gpx", withExtension: "gpx") else {
            XCTFail("Unable to locate golden gpx file.")
            return
        }
        
        let goldenGPXString = try String(contentsOf: goldenGPXURL, encoding: .ascii)
        print("sql: \(gpxString!)")
        print("golden: \(goldenGPXString)")
        // TODO: Better approach to handling line ending conversion?
        XCTAssert(gpxString!.replacingOccurrences(of: "\r\n", with: "\n") == goldenGPXString)
    }
}
