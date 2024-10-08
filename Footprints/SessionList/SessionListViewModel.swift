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
        
        var order: SortOrder {
            switch self {
            case .ascending:
                return .forward
            case .descending:
                return .reverse
            }
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
        
        func comparator(sortDirection: SortDirection) -> KeyPathComparator<SessionModel> {
            switch self {
            case .runtime:
                return KeyPathComparator(\.totalLogTime, order: sortDirection.order)
            case .startDate:
                return KeyPathComparator(\.startDate, order: sortDirection.order)
            case .distance:
                return KeyPathComparator(\.totalDistance, order: sortDirection.order)
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
    
    func deleteSessionsFromList(sessions: [SessionModel], indices: IndexSet, dbQueue: DatabaseQueue) throws {
        // TODO: Prompt on deletion
        let sessionIds = indices.map { sessions[$0].id }
        print("Deleting sessions with ids: \(sessionIds)")
        _ = try dbQueue.write { db in
            try SessionModel.deleteAll(db, ids: sessionIds)
        }
    }
}
