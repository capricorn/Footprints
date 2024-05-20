//
//  LoggerViewModel.swift
//  Footprints
//
//  Created by Collin Palmer on 3/22/24.
//

import Foundation
import SwiftUI
import GRDB
import Combine

// TODO: Alternative approach to this type of inheritance
class LoggerViewModel: ObservableObject {
    enum State: Equatable {
        static func == (lhs: LoggerViewModel.State, rhs: LoggerViewModel.State) -> Bool {
            switch (lhs, rhs) {
            case (.readyToRecord, .readyToRecord):
                return true
            case (.recordingInProgress(let lhsSession), .recordingInProgress(let rhsSession)):
                return lhsSession.id == rhsSession.id
            case (.recordingComplete, .recordingComplete):
                return true
            default:
                return false
            }
        }
        
        /// State when no recording has occurred -- default state on fresh app start.
        case readyToRecord
        case recordingInProgress(session: SessionModel)
        case recordingComplete
    }
    
    static var SPEED_UNDETERMINED: Double { -1 }
    
    @Published var logStartDate: Date?
    @Published var logNowDate: Date?
    @Published var state: State = .readyToRecord
    @Published var pointsCount: Int = 0
    @Published var speed: Double = SPEED_UNDETERMINED
    /// Total distance traveled in miles.
    @Published var distance: Double = 0
    
    let locationPublisher: GPSProvider.LocationProvider
    let motionPublisher: DeviceAccelerationProvider.AccelerationPublisher
    
    private var timerTask: Task<Void, Never>?
    private let dbQueue: DatabaseQueue
    private let gpsProvider: GPSProvider
    private let motionProvider: AccelerationProvider
    private var sessionCountSubscriber: DatabaseCancellable?
    
    init(
        dbQueue: DatabaseQueue = try! .default,
        gpsProvider: GPSProvider = LocationDelegate(),
        motionProvider: AccelerationProvider = DeviceAccelerationProvider()
    ) {
        self.dbQueue = dbQueue
        self.gpsProvider = gpsProvider
        self.motionProvider = motionProvider
        
        self.locationPublisher = gpsProvider.location
        self.motionPublisher = motionProvider.accelerationPublisher
    }
    
    var recordingComplete: Bool {
        switch state {
        case .recordingComplete:
            return true
        default:
            return false
        }
    }
    
    /// `true` if a session is currently being recorded.
    var recording: Bool {
        switch state {
        case .recordingInProgress(_):
            return true
        default:
            return false
        }
    }
    
    var recordButtonForegroundColor: Color {
        recording ? .red : .black
    }
    
    /// Total run time of the logger.
    var elapsedLogTime: TimeInterval? {
        guard let logStartDate, let logNowDate else {
            return nil
        }
        
        return logNowDate.timeIntervalSince(logStartDate)
    }
    
    var runtimeLabel: String {
        let duration = elapsedLogTime?.duration ?? .zero
        return duration.formatted(.time(pattern: .hourMinuteSecond))
    }
    
    // TODO: Should actually be called when totally resetting the state
    func resetRecordingState() {
        gpsProvider.stop()
        motionProvider.stop()
        timerTask?.cancel()
        timerTask = nil
        //logStartDate = nil
        
        sessionCountSubscriber?.cancel()
        sessionCountSubscriber = nil
        
        //resetStatistics()
    }
    
    func resetStatistics() {
        pointsCount = 0
        distance = 0
        speed = LoggerViewModel.SPEED_UNDETERMINED
        logStartDate = nil
        logNowDate = nil
    }
    
    private func startRecording() {
        let session = SessionModel(id: UUID(), startTimestamp: Date.now.timeIntervalSince1970, endTimestamp: 0, count: 0)
        // TODO: Just throw / handle..?
        try! dbQueue.write { db in
            try! session.insert(db)
        }
        
        let sessionObserver = ValueObservation.tracking { db in
            try! SessionModel.find(db, id: session.id)
        }
        
        sessionCountSubscriber = sessionObserver.start(in: dbQueue, onError: { _ in }) { updatedSession in
            self.pointsCount = updatedSession.count
            self.distance = updatedSession.totalDistance
        }
        
        state = .recordingInProgress(session: session)
        gpsProvider.start()
        motionProvider.start()
        timerTask = Task.detached { @MainActor in
            while Task.isCancelled == false {
                withAnimation {
                    self.logNowDate = Date.now
                }
                try? await Task.sleep(nanoseconds: UInt64(1e9/60))
            }
        }
        logStartDate = Date.now
    }
    
    private func stopRecording(stateSession: SessionModel) {
        var session = try! dbQueue.read { db in
            try! SessionModel.find(db, id: stateSession.id)
        }
        
        try! dbQueue.write { db in
            session.endTimestamp = Date.now.timeIntervalSince1970
            try! session.save(db)
        }
        
        state = .recordingComplete
        resetRecordingState()
    }
    
    func record() {
        switch state {
        case .readyToRecord:
            startRecording()
        case .recordingInProgress(let session):
            stopRecording(stateSession: session)
        case .recordingComplete:
            // TODO: Present avg speed during the session..?
            speed = 0
            resetStatistics()
            startRecording()
        }
    }
    
    /// Record the location data to the database.
    func recordLocation(_ loc: GPSLocatable, prevLoc: GPSLocatable? = nil) throws {
        guard case .recordingInProgress(let session) = state else {
            return
        }
        
        let locEntry = GPSLocationModel.from(loc, session: session)
        var mutableSession = try dbQueue.read { db in
            try SessionModel.find(db, id: session.id)
        }
        
        var dist = 0.0
        if let prevLoc {
            dist = loc.distance(from: prevLoc).converted(to: .miles).value
        }
        
        // TODO: Need to be able to set location session id..
        try dbQueue.write { db in
            try locEntry.insert(db)
            
            mutableSession.count += 1
            mutableSession.totalDistance += dist
            
            if mutableSession.fiveKTime == nil,
                mutableSession.totalDistance >= .fiveKMiles,
                let startTimestamp = logStartDate?.timeIntervalSince1970 {
                
                // TODO: Use the first recorded entry?
                mutableSession.fiveKTime = loc.timestamp-startTimestamp
            }
            
            try mutableSession.save(db)
        }
    }
    
    func recordMotion(_ accel: Acceleration) throws {
        guard case .recordingInProgress(let stateSession) = state else {
            assertionFailure("Incorrect recording state: \(String(describing: state))")
            return
        }
        
        let accelEntry = DeviceAccelerationModel.from(accel, session: stateSession)
        try dbQueue.write { db in
            try accelEntry.insert(db)
        }
    }
    
    func requestAuthorization() {
        let authorized = (gpsProvider.authorizationStatus == .authorizedAlways || gpsProvider.authorizationStatus == .authorizedWhenInUse)
        if authorized == false {
            gpsProvider.requestAuthorization()
        }
    }
}
