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
    @Published var logStartDate: Date?
    @Published var logNowDate: Date?
    
    private var timerTask: Task<Void, Never>?
    private let dbQueue: DatabaseQueue!
    
    init(dbQueue: DatabaseQueue = try! .default) {
        self.dbQueue = dbQueue
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
            timerTask?.cancel()
            timerTask = nil
            logStartDate = nil
        } else {
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
        try dbQueue.write { db in
            try loc.insert(db)
        }
    }
}
