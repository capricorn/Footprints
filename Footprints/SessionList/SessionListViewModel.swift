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
}
