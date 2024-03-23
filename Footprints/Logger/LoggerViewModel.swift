//
//  LoggerViewModel.swift
//  Footprints
//
//  Created by Collin Palmer on 3/22/24.
//

import Foundation
import SwiftUI

class LoggerViewModel: ObservableObject {
    @Published var logStartDate: Date?
    
    /// `true` if a session is currently being recorded.
    var recording: Bool {
        logStartDate != nil
    }
    
    var recordButtonForegroundColor: Color {
        recording ? .red : .black
    }
    
    func record() {
        logStartDate = recording ? nil : .now
    }
}
