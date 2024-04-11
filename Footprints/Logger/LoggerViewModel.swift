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
    
    @Published var logStartDate: Date?
    @Published var logNowDate: Date?
    @Published var state: State? = nil
    
    let locationPublisher: GPSProvider.LocationProvider
    
    private var timerTask: Task<Void, Never>?
    private let dbQueue: DatabaseQueue
    private let gpsProvider: GPSProvider
    
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
    
    func record() {
        if recording {
            if case .recordingInProgress(let session) = state {
                var session = session
                try! dbQueue.write { db in
                    session.endTimestamp = Float(Date.now.timeIntervalSince1970)
                    try! session.save(db)
                }
            } else {
                assertionFailure("Expected state == .recordingInProgress")
            }
            
            state = .recordingComplete
            gpsProvider.stop()
            timerTask?.cancel()
            timerTask = nil
            logStartDate = nil
        } else {
            let session = SessionModel(id: UUID(), startTimestamp: Float(Date.now.timeIntervalSince1970), endTimestamp: 0, count: 0)
            // TODO: Just throw / handle..?
            try! dbQueue.write { db in
                try! session.insert(db)
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
    func recordLocation(_ loc: GPSLocation) throws {
        guard case .recordingInProgress(let session) = state else {
            assertionFailure("Incorrect recording state: \(String(describing: state))")
            return
        }
        
        let locEntry = GPSLocationModel.from(loc, session: session)
        // TODO: Need to be able to set location session id..
        try dbQueue.write { db in
            try locEntry.insert(db)
        }
    }
    
    func requestAuthorization() {
        let authorized = (gpsProvider.authorizationStatus == .authorizedAlways || gpsProvider.authorizationStatus == .authorizedWhenInUse)
        if authorized == false {
            gpsProvider.requestAuthorization()
        }
    }
}
