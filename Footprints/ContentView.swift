//
//  ContentView.swift
//  Footprints
//
//  Created by Collin Palmer on 3/22/24.
//

import SwiftUI
import SwiftData
import Combine

struct ContentView: View {
    enum Navigation: String, CaseIterable, Identifiable {
        case logger
        case sessions
        
        var id: Self {
            self
        }
    }
    
    var body: some View {
        TabView {
            LoggerView()
                .tabItem {
                    Label("Logger", systemImage: "record.circle")
                }
            SessionListView()
                .tabItem {
                    Label("Sessions", systemImage: "list.bullet.rectangle")
                }
        }
    }
}

#Preview {
    ContentView()
}
