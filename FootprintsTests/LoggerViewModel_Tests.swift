//
//  LoggerViewModel_Tests.swift
//  FootprintsTests
//
//  Created by Collin Palmer on 3/26/24.
//

import XCTest
import Combine
import GRDB
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
    
    /// Verify that each location entry has the (current) recording session id
    func testLocationEntryHasSessionId() throws {
        let dbQueue = try DatabaseQueue.createTemporaryDBQueue()
        try dbQueue.setupFootprintsSchema()
        let model = LoggerViewModel(dbQueue: dbQueue, gpsProvider: NoopGPSProvider())
        
        model.record()
        
        var session: SessionModel!
        if case .recordingInProgress(let currentSession) = model.state {
            session = currentSession
        } else {
            XCTFail("Unexpected record state: \(model.state.debugDescription)")
        }
        
        try model.recordLocation(GPSLocation(
            latitude: 10,
            longitude: 10,
            altitude: .init(value: 5, unit: .meters),
            timestamp: 1000))
        
        try model.recordLocation(GPSLocation(
            latitude: 10,
            longitude: 10,
            altitude: .init(value: 5, unit: .meters),
            timestamp: 2000))
        
        // Verify that the locations are available via their session id
        let results = try dbQueue.read { db in
            return try GPSLocationModel
                .filter(Column("sessionId") == session.id)
                .fetchAll(db)
        }
        
        XCTAssert(results.count == 2, "\(results.count)")
    }
    
    func testRecordCreatesSession() throws {
        let dbQueue = try DatabaseQueue.createTemporaryDBQueue()
        try dbQueue.setupFootprintsSchema()
        let model = LoggerViewModel(dbQueue: dbQueue, gpsProvider: NoopGPSProvider())
        
        model.record()
        
        let sessions = try dbQueue.read { db in
            return try SessionModel.fetchAll(db)
        }
        
        XCTAssert(sessions.count == 1)
        // On initial recording, the start timestamp should be set and the
        // end timestamp should be set to 0.
        XCTAssert(sessions.first?.startTimestamp != 0)
        XCTAssert(sessions.first?.endTimestamp == 0)
        
        model.record()
        
        // Once the recording is finished the end timestamp should be updated.
        let session = try dbQueue.read { db in
            try SessionModel.find(db, id: sessions.first!.id)
        }
        
        XCTAssert(session.endTimestamp != 0)
    }
    
    func testRecordIncrementsSessionCount() throws {
        let dbQueue = try DatabaseQueue.createTemporaryDBQueue()
        try dbQueue.setupFootprintsSchema()
        let model = LoggerViewModel(dbQueue: dbQueue, gpsProvider: NoopGPSProvider())       
        
        model.record()
        
        guard case .recordingInProgress(let stateSession) = model.state else {
            XCTFail("Record state is wrong.")
            return
        }
        
        let session = try dbQueue.read { db in
            return try SessionModel.find(db, id: stateSession.id)
        }
        
        XCTAssert(session.count == 0)
        try model.recordLocation(GPSLocation(
            latitude: 0,
            longitude: 0,
            altitude: .init(value: 0, unit: .meters),
            timestamp: Float(Date.now.timeIntervalSince1970)))
        try model.recordLocation(GPSLocation(
            latitude: 0,
            longitude: 0,
            altitude: .init(value: 0, unit: .meters),
            timestamp: Float(Date.now.timeIntervalSince1970)))
        
        model.record()
        
        let updatedSession = try dbQueue.read { db in
            try SessionModel.find(db, id: session.id)
        }
        
        XCTAssert(updatedSession.count == 2)
    }
    
    func testResetRecordingState() throws {
        let dbQueue = try DatabaseQueue.createTemporaryDBQueue()
        try dbQueue.setupFootprintsSchema()
        let model = LoggerViewModel(dbQueue: dbQueue, gpsProvider: NoopGPSProvider())
        
        model.record()
        model.resetRecordingState()
        
        XCTAssert(model.recording == false)
        XCTAssert(model.pointsCount == 0)
        XCTAssert(model.logStartDate == nil)
        XCTAssert(model.distance == 0)
    }
    
    func testRecordLocationDistanceUpdate() throws {
        let dbQueue = try DatabaseQueue.createTemporaryDBQueue()
        try dbQueue.setupFootprintsSchema()
        let model = LoggerViewModel(dbQueue: dbQueue, gpsProvider: NoopGPSProvider())       
        
        struct MockGPSLocation: GPSLocatable {
            var latitude: CGFloat = 0
            var longitude: CGFloat = 0
            var altitude: Measurement<UnitLength> = .init(value: 0, unit: .meters)
            var timestamp: Float = 0
            var speed: Double = 0
            
            func distance(from loc: GPSLocatable) -> Measurement<UnitLength> {
                return .init(value: 5, unit: .miles)
            }
        }
        
        let prevLoc = MockGPSLocation()
        let newLoc = MockGPSLocation()
        
        model.record()
        try model.recordLocation(newLoc, prevLoc: prevLoc)
        try model.recordLocation(newLoc, prevLoc: prevLoc)
        
        guard case .recordingInProgress(let session) = model.state else {
            XCTFail("Record state is wrong.")
            return
        }
        
        model.record()
        
        let currentSession = try dbQueue.read({ db in
            return try SessionModel.find(db, id: session.id)
        })
        
        XCTAssert(currentSession.totalDistance == 10)
    }
}
