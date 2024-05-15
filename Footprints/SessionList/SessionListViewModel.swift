//
//  SessionListViewModel.swift
//  Footprints
//
//  Created by Collin Palmer on 4/16/24.
//

import Foundation
import SwiftUI
import GRDB

class SessionListViewModel: ObservableObject {
    @Published var presentExportOptions = false
    
    enum SortDirection: String {
        static let defaultsKey = "SortDirection"
        case ascending
        case descending
        
        // TODO: Bool instead?
        func toggle() -> SortDirection {
            (self == .ascending) ? .descending : .ascending
        }
    }
    
    enum SortField: String, CaseIterable, Identifiable {
        static let defaultsKey = "SortField"
        /// Total time that the session was recorded
        case runtime
        /// Date of session start
        case startDate
        /// The total distance traveled
        case distance
        
        var id: String {
            self.rawValue
        }
        
        var label: String {
            switch self {
            case .runtime:
                "Runtime"
            case .startDate:
                "Start Date"
            case .distance:
                "Distance"
            }
        }
    }
    
    // TODO: Implement
    func session(sort: SortField, direction: SortDirection, dbQueue: DatabaseQueue) throws -> [SessionModel] {
        // TODO: Determine column name
        // TODO: Convert to an extension of the types themselves..?
        let colName = switch sort {
        case .runtime:
            // TODO: Not implemented.. (needs to be a field in sql -- assert)
            "startTimestamp"
        case .startDate:
            "startTimestamp"
        case .distance:
            "totalDistance"
        }
        
        let col = switch direction {
        case .ascending:
            Column(colName).asc
        case .descending:
            Column(colName).desc
        }
        
        return try dbQueue.read { db in
            try SessionModel
                .order(col)
                .fetchAll(db)
        }
    }
}
