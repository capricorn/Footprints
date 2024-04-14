//
//  LoggerViewModel.swift
//  Footprints
//
//  Created by Collin Palmer on 3/22/24.
//

import Foundation
import SwiftUI
import GRDB

class LoggerViewModel: ObservableObject {
    enum State {
        case recordingInProgress(session: SessionModel)
        case recordingComplete
    }
    
    static let SPEED_UNDETERMINED: Double = -1
    
    @Published var logStartDate: Date?
    @Published var logNowDate: Date?
    @Published var state: State? = nil
    @Published var pointsCount: Int = 0
    @Published var speed: Double = SPEED_UNDETERMINED
    /// Total distance traveled in miles.
    @Published var distance: Double = 0
    
    let locationPublisher: GPSProvider.LocationProvider
    
    private var timerTask: Task<Void, Never>?
    private let dbQueue: DatabaseQueue
    private let gpsProvider: GPSProvider
    private var sessionCountSubscriber: DatabaseCancellable?
    
    init(dbQueue: DatabaseQueue = try! .default, gpsProvider: GPSProvider = LocationDelegate()) {
        self.dbQueue = dbQueue
        self.gpsProvider = gpsProvider
        self.locationPublisher = gpsProvider.location
    }
    
    /// `true` if a session is currently being recorded.
    var recording: Bool {
        logStartDate != nil
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
        guard let elapsedLogTime else {
            return "--"
        }
        
        let duration = Duration(secondsComponent: Int64(elapsedLogTime), attosecondsComponent: 0)
        return duration.formatted(.time(pattern: .hourMinuteSecond))
    }
    
    // TODO: Should actually be called when totally resetting the state
    func resetRecordingState() {
        gpsProvider.stop()
        timerTask?.cancel()
        timerTask = nil
        logStartDate = nil
        
        sessionCountSubscriber?.cancel()
        sessionCountSubscriber = nil
        pointsCount = 0
        distance = 0
    }
    
    func record() {
        if recording {
            if case .recordingInProgress(let stateSession) = state {
                var session = try! dbQueue.read { db in
                    try! SessionModel.find(db, id: stateSession.id)
                }
                
                try! dbQueue.write { db in
                    session.endTimestamp = Float(Date.now.timeIntervalSince1970)
                    try! session.save(db)
                }
            } else {
                assertionFailure("Expected state == .recordingInProgress")
            }
            
            state = .recordingComplete
            resetRecordingState()
        } else {
            let session = SessionModel(id: UUID(), startTimestamp: Float(Date.now.timeIntervalSince1970), endTimestamp: 0, count: 0)
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
            timerTask = Task.detached { @MainActor in
                while Task.isCancelled == false {
                    self.logNowDate = Date.now
                    try? await Task.sleep(nanoseconds: UInt64(1e9/60))
                }
            }
            logStartDate = Date.now
        }
    }
    
    /// Record the location data to the database.
    func recordLocation(_ loc: GPSLocatable, prevLoc: GPSLocatable? = nil) throws {
        guard case .recordingInProgress(let session) = state else {
            assertionFailure("Incorrect recording state: \(String(describing: state))")
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
            try mutableSession.save(db)
        }
    }
    
    func requestAuthorization() {
        let authorized = (gpsProvider.authorizationStatus == .authorizedAlways || gpsProvider.authorizationStatus == .authorizedWhenInUse)
        if authorized == false {
            gpsProvider.requestAuthorization()
        }
    }
}
