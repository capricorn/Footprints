//
//  ContentView.swift
//  Footprints
//
//  Created by Collin Palmer on 3/22/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @StateObject var loggerModel: LoggerViewModel = LoggerViewModel()
    let gpsProvider = LocationDelegate()
    
    var body: some View {
        LoggerView(model: loggerModel, gpsProvider: gpsProvider)
    }
}

#Preview {
    ContentView()
}
