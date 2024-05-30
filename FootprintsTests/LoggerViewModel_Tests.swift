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
    
    private struct NoopMotionProvider: AccelerationProvider {
        var accelerationPublisher: AccelerationPublisher {
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
    func testLoggerStateRecordInProgress() throws {
        let model = LoggerViewModel(dbQueue: try .createTemporaryDBQueue(), gpsProvider: NoopGPSProvider())
        XCTAssert(model.state == .readyToRecord)
        
        model.record()
        if case .recordingInProgress(_) = model.state {
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
            XCTFail("Unexpected record state: \(model.state)")
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
            timestamp: Date.now.timeIntervalSince1970))
        try model.recordLocation(GPSLocation(
            latitude: 0,
            longitude: 0,
            altitude: .init(value: 0, unit: .meters),
            timestamp: Date.now.timeIntervalSince1970))
        
        model.record()
        
        let updatedSession = try dbQueue.read { db in
            try SessionModel.find(db, id: session.id)
        }
        
        XCTAssert(updatedSession.count == 2)
    }
    
    func testLoggerStateRecordingComplete() throws {
        let dbQueue = try DatabaseQueue.createTemporaryDBQueue()
        try dbQueue.setupFootprintsSchema()
        let model = LoggerViewModel(dbQueue: dbQueue, gpsProvider: NoopGPSProvider())
        
        // TODO: Verify which statistics persist (provide mock data)
        model.record()
        model.record()
        
        XCTAssert(model.state == .recordingComplete)
    }
    
    func testRecordLocationDistanceUpdate() throws {
        let dbQueue = try DatabaseQueue.createTemporaryDBQueue()
        try dbQueue.setupFootprintsSchema()
        let model = LoggerViewModel(dbQueue: dbQueue, gpsProvider: NoopGPSProvider())       
        
        struct MockGPSLocation: GPSLocatable {
            var latitude: CGFloat = 0
            var longitude: CGFloat = 0
            var altitude: Measurement<UnitLength> = .init(value: 0, unit: .meters)
            var timestamp: Double = 0
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
    
    /// Verify that after finishing recording the runtime statistics are reset
    func testLoggerStateNewRecording() throws {
        let dbQueue = try DatabaseQueue.createTemporaryDBQueue()
        try dbQueue.setupFootprintsSchema()
        let model = LoggerViewModel(dbQueue: dbQueue, gpsProvider: NoopGPSProvider())       
        
        struct MockGPSLocation: GPSLocatable {
            var latitude: CGFloat = 0
            var longitude: CGFloat = 0
            var altitude: Measurement<UnitLength> = .init(value: 0, unit: .meters)
            var timestamp: Double = 0
            var speed: Double = 0
            
            func distance(from loc: GPSLocatable) -> Measurement<UnitLength> {
                return .init(value: 5, unit: .miles)
            }
        }
        
        model.record()
        try model.recordLocation(MockGPSLocation())
        model.record()
        model.record()
        
        XCTAssert(model.pointsCount == 0)
        XCTAssert(model.speed == LoggerViewModel.SPEED_UNDETERMINED)
        XCTAssert(model.distance == 0)
    }
    
    func testRecordMotion() throws {
        let dbQueue = try DatabaseQueue.createTemporaryDBQueue()
        try dbQueue.setupFootprintsSchema()
        let model = LoggerViewModel(
            dbQueue: dbQueue,
            gpsProvider: NoopGPSProvider(),
            motionProvider: NoopMotionProvider())
        
        struct MockAcceleration: Acceleration {
            var x: Double = 0
            var y: Double = 1
            var z: Double = 2
            
            var timestamp: Double = 100.0
        }
        
        model.record()
        try model.recordMotion(MockAcceleration())
        
        guard case .recordingInProgress(let stateSession) = model.state else {
            XCTFail("Record state is wrong.")
            return
        }

        model.record()
        
        let accelData = try dbQueue.read { db in
            try DeviceAccelerationModel.fetchAll(db)
        }
        
        XCTAssert(accelData.count == 1)
        XCTAssert(accelData.first?.x == 0)
        XCTAssert(accelData.first?.y == 1)
        XCTAssert(accelData.first?.z == 2)
        XCTAssert(accelData.first?.timestamp == 100)
    }
    
    /// Verify that a 5k time is hit
    func testLogger5kHit() throws {
        let dbQueue = try DatabaseQueue.createTemporaryDBQueue()
        try dbQueue.setupFootprintsSchema()
        let model = LoggerViewModel(dbQueue: dbQueue, gpsProvider: NoopGPSProvider())       
        
        struct MockGPSLocation: GPSLocatable {
            var latitude: CGFloat = 0
            var longitude: CGFloat = 0
            var altitude: Measurement<UnitLength> = .init(value: 0, unit: .meters)
            var timestamp: Double
            var speed: Double = 0
            
            let distance: Double
            
            init(distance: Double, timestamp: Double = Date.now.timeIntervalSince1970) {
                self.distance = distance
                self.timestamp = timestamp
            }
            
            func distance(from loc: GPSLocatable) -> Measurement<UnitLength> {
                return .init(value: distance, unit: .miles)
            }
        }
        
        var currentSession: SessionModel!
        // nb. distance is in km
        let loc1 = MockGPSLocation(distance: 2, timestamp: 1)
        let loc2 = MockGPSLocation(distance: 2, timestamp: 2)
        let loc3 = MockGPSLocation(distance: 2, timestamp: 3)
        let loc4 = MockGPSLocation(distance: 2, timestamp: 4)
        
        model.record()
        
        guard case .recordingInProgress(let session) = model.state else {
            XCTFail("Record state is wrong.")
            return
        }
        
        try model.recordLocation(loc1)
        currentSession = try dbQueue.read({ db in
            return try SessionModel.find(db, id: session.id)
        })
        XCTAssertNil(currentSession.fiveKTime)
        
        try model.recordLocation(loc2, prevLoc: loc1)
        currentSession = try dbQueue.read({ db in
            return try SessionModel.find(db, id: session.id)
        })
        XCTAssertNil(currentSession.fiveKTime)
        
        model.logStartDate = Date(timeIntervalSince1970: 1)
        try model.recordLocation(loc3, prevLoc: loc2)
        currentSession = try dbQueue.read({ db in
            return try SessionModel.find(db, id: session.id)
        })       
        // TODO: Inject time + verify
        // last timestamp = 3, start timestamp = 1 so 3-1 = 2 total.
        XCTAssert(currentSession.fiveKTime == 2)
        
        // Verify that the 5k time stays constant
        model.logStartDate = Date(timeIntervalSince1970: 1)
        try model.recordLocation(loc4, prevLoc: loc3)
        currentSession = try dbQueue.read({ db in
            return try SessionModel.find(db, id: session.id)
        })
        XCTAssert(currentSession.fiveKTime == 2)
    }
}
