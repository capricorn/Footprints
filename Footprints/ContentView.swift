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
    @Environment(\.quickActionPublisher) var quickActionPublisher
    
    enum Navigation: String, CaseIterable, Identifiable {
        case logger
        case sessions
        
        var id: Self {
            self
        }
    }
    
    var body: some View {
        TabView {
            SessionListView()
                .tabItem {
                    Label("Sessions", systemImage: "list.bullet.rectangle")
                }
            LoggerView()
                .tabItem {
                    Label("Logger", systemImage: "record.circle")
                }
            CalendarContainerView()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar")
                }
        }
        .onReceive(quickActionPublisher) { action in
            print("Received action: \(action)")
        }
    }
}

#Preview {
    ContentView()
}
