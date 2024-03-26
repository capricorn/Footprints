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
        case recordingInProgress(sessionId: UUID)
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
            state = .recordingComplete
            gpsProvider.stop()
            timerTask?.cancel()
            timerTask = nil
            logStartDate = nil
        } else {
            state = .recordingInProgress(sessionId: UUID())
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
    func recordLocation(_ loc: GPSLocationModel) throws {
        guard case .recordingInProgress(let sessionId) = state else {
            assertionFailure("Incorrect recording state: \(String(describing: state))")
            return
        }
        
        // TODO: Need to be able to set location session id..
        try dbQueue.write { db in
            try loc.insert(db)
        }
    }
    
    func requestAuthorization() {
        let authorized = (gpsProvider.authorizationStatus == .authorizedAlways || gpsProvider.authorizationStatus == .authorizedWhenInUse)
        if authorized {
            gpsProvider.requestAuthorization()
        }
    }
}
